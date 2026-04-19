import '../../database/app_database.dart';
import '../../database/daos/categories_dao.dart';
import '../../database/daos/items_dao.dart';

class LocalDataSource {
  final CategoriesDao _categoriesDao;
  final ItemsDao _itemsDao;
  final AppDatabase _db;

  LocalDataSource(this._db)
      : _categoriesDao = _db.categoriesDao,
        _itemsDao = _db.itemsDao;

  // Categories
  Future<List<Category>> getAllCategories() =>
      _categoriesDao.getAllCategories();

  Stream<List<Category>> watchAllCategories() =>
      _categoriesDao.watchAllCategories();

  Future<Category> getCategoryById(int id) =>
      _categoriesDao.getCategoryById(id);

  Future<int> insertCategory(CategoriesCompanion category) =>
      _categoriesDao.insertCategory(category);

  Future<bool> updateCategory(CategoriesCompanion category) =>
      _categoriesDao.updateCategory(category);

  Future<int> deleteCategory(int id) =>
      _categoriesDao.deleteCategory(id);

  // Items
  Future<List<Item>> getItemsByCategory(int categoryId) =>
      _itemsDao.getItemsByCategory(categoryId);

  Stream<List<Item>> watchItemsByCategory(int categoryId) =>
      _itemsDao.watchItemsByCategory(categoryId);

  Future<Item> getItemById(int id) => _itemsDao.getItemById(id);

  Future<List<Item>> searchItems(String query) =>
      _itemsDao.searchItems(query);

  Future<List<Item>> searchItemsInCategory(int categoryId, String query) =>
      _itemsDao.searchItemsInCategory(categoryId, query);

  Future<int> insertItem(ItemsCompanion item) =>
      _itemsDao.insertItem(item);

  Future<bool> updateItem(ItemsCompanion item) =>
      _itemsDao.updateItem(item);

  Future<int> deleteItem(int id) => _itemsDao.deleteItem(id);

  Future<List<Item>> getItemsByLaunchPath(String launchPath) =>
      _itemsDao.getItemsByLaunchPath(launchPath);

  // Settings
  Future<String?> getSetting(String key) => _db.getSetting(key);

  Future<void> setSetting(String key, String value) =>
      _db.setSetting(key, value);
}
