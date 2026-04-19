import '../../../domain/entities/item.dart';
import '../../../data/repositories/item_repository_impl.dart';

abstract class GetItemsByCategory {
  Future<List<ItemEntity>> call({
    required int categoryId,
    int offset = 0,
    int limit = 50,
  });
}

class GetItemsByCategoryImpl implements GetItemsByCategory {
  final ItemRepositoryImpl _itemRepository;

  GetItemsByCategoryImpl(this._itemRepository);

  @override
  Future<List<ItemEntity>> call({
    required int categoryId,
    int offset = 0,
    int limit = 50,
  }) async {
    // Получаем все элементы категории
    final allItems = await _itemRepository.getItemsByCategory(categoryId);
    
    // Применяем пагинацию
    final start = offset + 1; // offset (0-based)
    final end = start + limit;
    
    if (end > allItems.length) {
      // Если элементов меньше, чем нужно — возвращаем всё, что осталось
      return allItems.skip(start).toList();
    }
    
    return allItems.skip(start).take(limit).toList();
  }
}
