import 'package:flutter/material.dart';
import '../../../domain/entities/item.dart';
import '../../blocs/item/item_bloc.dart';
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
  int _currentPage = 0;
  int _itemsPerPage = 50; // Начальная пачка
  bool _isLoadingMore = false;
  bool _hasMore = true;
  List<ItemEntity> _items = [];

  @override
  void initState() {
    super.initState();
    _loadItems(0, _itemsPerPage);
  }

  Future<void> _loadItems(int offset, int limit) async {
    if (_isLoadingMore || !_hasMore) return;

    setState(() => _isLoadingMore = true);

    try {
      final bloc = getIt<ItemBloc>();
      bloc.add(GetItemsByCategory(
        categoryId: widget.categoryId,
        offset: offset,
        limit: limit,
      ));

      // Слушаем состояние BLoC для обновления UI
      bloc.stream.listen((state) {
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Категория: ${widget.categoryName}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _loadItems(0, _itemsPerPage),
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
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ItemDetailScreen(item: item),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: _hasMore && !_isLoadingMore
          ? FloatingActionButton.extended(
              onPressed: () => _loadItems(_items.length, _itemsPerPage),
              icon: const Icon(Icons.add),
              label: const Text('Загрузить ещё'),
            )
          : null,
    );
  }
}

/// Карточка элемента с постером и информацией.
class ItemCard extends StatelessWidget {
  final ItemEntity item;
  final VoidCallback onTap;

  const ItemCard({super.key, required this.item, required this.onTap});

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
