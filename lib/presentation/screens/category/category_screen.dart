import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/injection.dart';
import '../../../core/services/directory_scanner.dart';
import '../../../domain/entities/item.dart';
import '../../blocs/item/item_bloc.dart';
import '../../blocs/item/item_event.dart';
import '../../blocs/item/item_state.dart';
import '../../widgets/scan_progress_dialog.dart';
import '../item_detail/item_detail_screen.dart';

/// Экран отображения элементов категории с ленивой загрузкой.
class CategoryScreen extends StatefulWidget {
  const CategoryScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  final String categoryId;
  final String categoryName;

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  StreamSubscription? _subscription;
  final int _itemsPerPage = 50; // Начальная пачка
  bool _isLoadingMore = false;
  bool _hasMore = true;
  final List<ItemEntity> _items = [];

  // Search related
  bool _isSearching = false;
  String _searchQuery = '';
  Timer? _debounceTimer;
  final TextEditingController _searchController = TextEditingController();

  // Scanner related
  final DirectoryScanner _scanner = DirectoryScanner();
  Completer<void>? _scanCancellationToken;
  bool _initialLoadDone = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _loadItems(BuildContext context, int offset, int limit) async {
    if (_isLoadingMore || !_hasMore) return;

    setState(() => _isLoadingMore = true);

    try {
      final bloc = context.read<ItemBloc>();
      bloc.add(GetItemsByCategoryEvent(
        categoryId: int.parse(widget.categoryId),
        offset: offset,
        limit: limit,
      ));

      // Слушаем состояние BLoC для обновления UI
      _subscription?.cancel(); // Cancel any existing subscription
      _subscription = bloc.stream.listen((state) {
        if (state is ItemLoaded) {
          setState(() {
            _items.addAll(state.items);
            _hasMore = state.items.length >= limit;
          });
        } else if (state is ItemEmpty && offset > 0) {
          // Если вернулось 0 элементов и это не первая загрузка — больше нет
          setState(() => _hasMore = false);
        }
      });
    } finally {
      if (mounted) {
        setState(() => _isLoadingMore = false);
      }
    }
  }

  /// Get filtered items based on search query
  List<ItemEntity> get _filteredItems {
    if (_searchQuery.isEmpty) return _items;
    final lowerQuery = _searchQuery.toLowerCase();
    return _items.where((item) {
      final titleMatch = item.title.toLowerCase().contains(lowerQuery);
      final descMatch = item.description.toLowerCase().contains(lowerQuery);
      return titleMatch || descMatch;
    }).toList();
  }

  /// Handle search input with debounce
  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() => _searchQuery = query);
      }
    });
  }

  /// Toggle search mode
  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchQuery = '';
        _searchController.clear();
      }
    });
  }

  /// Clear search
  void _clearSearch() {
    _searchController.clear();
    setState(() => _searchQuery = '');
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<ItemBloc>(),
      child: Builder(
        builder: (context) {
          // Trigger initial load once BlocProvider is available
          if (!_initialLoadDone) {
            _initialLoadDone = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _loadItems(context, 0, _itemsPerPage);
            });
          }
          return Scaffold(
            appBar: AppBar(
              title: _isSearching
                  ? TextField(
                      controller: _searchController,
                      autofocus: true,
                      decoration: const InputDecoration(
                        hintText: 'Поиск...',
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: Colors.white70),
                      ),
                      style: const TextStyle(color: Colors.white),
                      onChanged: _onSearchChanged,
                    )
                  : Text('Категория: ${widget.categoryName}'),
              actions: [
                if (_isSearching) ...[
                  if (_searchQuery.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: _clearSearch,
                      tooltip: 'Очистить',
                    ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: _toggleSearch,
                    tooltip: 'Закрыть поиск',
                  ),
                ] else ...[
                  IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: _toggleSearch,
                    tooltip: 'Поиск',
                  ),
                  IconButton(
                    icon: const Icon(Icons.folder_open),
                    onPressed: () => _scanDirectory(context),
                    tooltip: 'Сканировать папку',
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () => _loadItems(context, 0, _itemsPerPage),
                    tooltip: 'Обновить',
                  ),
                ],
              ],
            ),
            body: _buildBody(),
            floatingActionButton: _hasMore && !_isLoadingMore && !_isSearching
                ? FloatingActionButton.extended(
                    onPressed: () => _loadItems(context, _items.length, _itemsPerPage),
                    icon: const Icon(Icons.add),
                    label: const Text('Загрузить ещё'),
                  )
                : null,
          );
        },
      ),
    );
  }

  Widget _buildBody() {
    if (_items.isEmpty && _isLoadingMore) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_filteredItems.isEmpty && _searchQuery.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'Ничего не найдено',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Попробуйте изменить запрос',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    if (_filteredItems.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_open, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Нет элементов',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemCount: _filteredItems.length,
      itemBuilder: (context, index) {
        final item = _filteredItems[index];
        return ItemCard(
          item: item,
          index: index,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ItemDetailScreen(itemId: item.id),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _debounceTimer?.cancel();
    _searchController.dispose();
    _cancelScan();
    super.dispose();
  }

  /// Cancel ongoing scan
  void _cancelScan() {
    if (_scanCancellationToken != null && !_scanCancellationToken!.isCompleted) {
      _scanner.cancelScan(_scanCancellationToken!);
    }
  }

  /// Show extension picker dialog
  Future<List<String>?> _showExtensionPickerDialog(BuildContext context) async {
    final selectedExtensions = <String>[];
    final commonExtensions = {
      'Видео': ['.mp4', '.mkv', '.avi', '.mov', '.wmv'],
      'Аудио': ['.mp3', '.flac', '.wav', '.aac'],
      'Программы': ['.exe', '.app', '.sh', '.bat'],
    };

    final result = await showDialog<List<String>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Выберите расширения файлов'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final category in commonExtensions.entries) ...[
                    Text(
                      category.key,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    Wrap(
                      spacing: 8,
                      children: [
                        for (final ext in category.value)
                          FilterChip(
                            label: Text(ext),
                            selected: selectedExtensions.contains(ext),
                            onSelected: (selected) {
                              setDialogState(() {
                                if (selected) {
                                  selectedExtensions.add(ext);
                                } else {
                                  selectedExtensions.remove(ext);
                                }
                              });
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Отмена'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(selectedExtensions),
                child: const Text('Сканировать'),
              ),
            ],
          );
        },
      ),
    );

    return result;
  }

  /// Scan directory and add items
  Future<void> _scanDirectory(BuildContext context) async {
    // Pick directory
    final result = await FilePicker.getDirectoryPath();
    if (result == null) return;

    // Show extension picker
    final extensions = await _showExtensionPickerDialog(context);
    if (extensions == null || extensions.isEmpty) return;

    // Create cancellation token
    _scanCancellationToken = _scanner.createCancellationToken();

    // Show progress dialog and start scan
    final scanOptions = ScanOptions(
      extensions: extensions,
      recursive: true,
    );

    if (!context.mounted) return;

    // Show scan progress dialog
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ScanProgressDialog(
        scanStream: _scanner.scanDirectory(
          result,
          scanOptions,
          cancellationToken: _scanCancellationToken,
        ),
        onComplete: (progress) {
          // Scan completed, now create items
          if (progress.filesFound > 0 && context.mounted) {
            _createItemsFromScan(context, result, extensions);
          }
        },
        onCancel: _cancelScan,
      ),
    );
  }

  /// Create items from scanned files
  Future<void> _createItemsFromScan(
    BuildContext context,
    String directoryPath,
    List<String> extensions,
  ) async {
    if (!context.mounted) return;

    final bloc = context.read<ItemBloc>();
    final categoryId = int.parse(widget.categoryId);

    // Scan synchronously to get all files
    final scanOptions = ScanOptions(
      extensions: extensions,
      recursive: true,
    );
    final scannedFiles = _scanner.scanDirectorySync(directoryPath, scanOptions);

    if (scannedFiles.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Файлы не найдены')),
        );
      }
      return;
    }

    // Create item data from scanned files
    final items = scannedFiles.map((file) {
      return CreateItemData(
        title: file.metadata.title,
        launchPath: file.path,
        year: file.metadata.year,
        itemType: ItemType.movie, // Default to movie, can be customized
        description: '',
      );
    }).toList();

    // Dispatch batch create event
    bloc.add(BatchCreateItemsEvent(
      items: items,
      categoryId: categoryId,
    ));

    // Show success message
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Добавлено ${items.length} элементов')),
      );
    }
  }
}

/// Карточка элемента с постером и информацией.
class ItemCard extends StatelessWidget {
  final ItemEntity item;
  final VoidCallback onTap;
  final int index;

  const ItemCard({super.key, required this.item, required this.onTap, required this.index});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                    child: item.posterUrl != null
                        ? Image.network(
                            item.posterUrl!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Theme.of(context).colorScheme.primaryContainer,
                                child: const Icon(Icons.movie),
                              );
                            },
                          )
                        : Container(
                            color: Theme.of(context).colorScheme.primaryContainer,
                            child: const Center(child: Icon(Icons.movie, size: 48)),
                          ),
                  ),
                  Positioned(
                    right: 8,
                    bottom: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                item.title,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}