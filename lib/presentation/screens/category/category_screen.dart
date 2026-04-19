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

  // Scanner related
  final DirectoryScanner _scanner = DirectoryScanner();
  Completer<void>? _scanCancellationToken;

  @override
  void initState() {
    super.initState();
    // Defer initial load to after first frame when BlocProvider is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadItems(context, 0, _itemsPerPage);
    });
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

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<ItemBloc>(),
      child: Builder(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Категория: ${widget.categoryName}'),
              actions: [
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
            ),
            body: _items.isEmpty
                ? Center(child: CircularProgressIndicator())
                : GridView.builder(
                    padding: const EdgeInsets.all(8),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                    ),
                    itemCount: _items.length,
                    itemBuilder: (context, index) {
                      final item = _items[index];
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
                  ),
            floatingActionButton: _hasMore && !_isLoadingMore
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

  @override
  void dispose() {
    _subscription?.cancel();
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
    final result = await FilePicker.platform.getDirectoryPath();
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
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: item.posterUrl != null
                  ? Image.network(
                      item.posterUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          child: const Icon(Icons.movie),
                        );
                      },
                    )
                  : Container(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      child: const Icon(Icons.movie),
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
    );
  }
}
