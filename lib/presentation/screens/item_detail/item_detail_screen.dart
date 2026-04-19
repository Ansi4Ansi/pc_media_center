import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/injection.dart';
import '../../../core/services/launcher_service.dart';
import '../../../domain/entities/item.dart';
import '../../blocs/item/item_bloc.dart';
import '../../blocs/item/item_event.dart';
import '../../blocs/item/item_state.dart';
import '../item_form/item_form_screen.dart';

/// Экран детальной информации об элементе.
class ItemDetailScreen extends StatefulWidget {
  const ItemDetailScreen({
    super.key,
    required this.itemId,
    this.itemBloc,
    this.launcherService,
  });

  final int itemId;
  final ItemBloc? itemBloc;
  final LauncherService? launcherService;

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  late ItemBloc _itemBloc;
  late LauncherService _launcherService;

  @override
  void initState() {
    super.initState();
    _itemBloc = widget.itemBloc ?? getIt<ItemBloc>();
    _launcherService = widget.launcherService ?? getIt<LauncherService>();
    _loadItem();
  }

  void _loadItem() {
    _itemBloc.add(GetItemByIdEvent(itemId: widget.itemId));
  }

  @override
  void dispose() {
    if (widget.itemBloc == null) {
      _itemBloc.close();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _itemBloc,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Детали'),
          actions: [
            BlocBuilder<ItemBloc, ItemState>(
              builder: (context, state) {
                if (state is SingleItemLoaded) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton.icon(
                        onPressed: () => _onEditPressed(context, state.item),
                        icon: const Icon(Icons.edit),
                        label: const Text('Редактировать'),
                      ),
                      TextButton.icon(
                        onPressed: () => _onDeletePressed(context),
                        icon: const Icon(Icons.delete),
                        label: const Text('Удалить'),
                        style: TextButton.styleFrom(
                          foregroundColor: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
        body: BlocConsumer<ItemBloc, ItemState>(
          listener: (context, state) {
            if (state is ItemDeleted) {
              Navigator.of(context).pop();
            }
          },
          builder: (context, state) {
            if (state is ItemInitial || state is ItemEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is ItemError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      state.message,
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _loadItem,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Повторить'),
                    ),
                  ],
                ),
              );
            }

            if (state is SingleItemLoaded) {
              return _ItemDetailContent(
                item: state.item,
                launcherService: _launcherService,
              );
            }

            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  void _onEditPressed(BuildContext context, ItemEntity item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ItemFormScreen(itemId: item.id.toString()),
      ),
    );
  }

  void _onDeletePressed(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Подтверждение удаления'),
        content: const Text('Вы уверены, что хотите удалить этот элемент?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _itemBloc.add(DeleteItemEvent(itemId: widget.itemId));
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
  }
}

class _ItemDetailContent extends StatelessWidget {
  final ItemEntity item;
  final LauncherService launcherService;

  const _ItemDetailContent({
    required this.item,
    required this.launcherService,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Poster
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: item.posterUrl != null
                  ? Image.network(
                      item.posterUrl!,
                      height: 300,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildPlaceholder(context);
                      },
                    )
                  : _buildPlaceholder(context),
            ),
          ),
          const SizedBox(height: 24),

          // Title
          Text(
            item.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),

          // Year and Rating
          Row(
            children: [
              if (item.year > 0) ...[
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  item.year.toString(),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(width: 16),
              ],
              if (item.rating > 0) ...[
                Icon(
                  Icons.star,
                  size: 16,
                  color: Colors.amber,
                ),
                const SizedBox(width: 4),
                Text(
                  item.rating.toString(),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),

          // Description
          if (item.description.isNotEmpty) ...[
            Text(
              'Описание',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              item.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
          ],

          // File path
          Text(
            'Путь к файлу',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.folder_open,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item.launchPath,
                    style: Theme.of(context).textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Launch button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _launchFile(context),
              icon: const Icon(Icons.play_arrow),
              label: const Text('Запустить'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      height: 300,
      width: 200,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(
        Icons.movie,
        size: 64,
      ),
    );
  }

  Future<void> _launchFile(BuildContext context) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Запуск...'),
        duration: Duration(seconds: 1),
      ),
    );

    final result = await launcherService.launch(
      item.launchPath,
      arguments: item.launchArgs,
    );

    if (!result.success && context.mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Ошибка'),
          content: Text(result.errorMessage ?? 'Не удалось запустить файл'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }
}
