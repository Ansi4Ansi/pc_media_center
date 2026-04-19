import '../../presentation/blocs/category/category_bloc.dart';
import '../../domain/usecases/categories/add_category.dart' as cat_uc;
import '../../domain/usecases/categories/update_category.dart' as cat_uc;
import '../../domain/usecases/categories/delete_category.dart' as cat_uc;
import 'package:get_it/get_it.dart';

import '../../data/database/app_database.dart';
import '../../data/datasources/local/local_data_source.dart';
import '../../data/repositories/category_repository_impl.dart';
import '../../data/repositories/item_repository_impl.dart';
import '../../domain/repositories/category_repository.dart';
import '../../domain/repositories/item_repository.dart';
import '../../domain/usecases/categories/add_category.dart';
import '../../domain/usecases/categories/delete_category.dart';
import '../../domain/usecases/categories/get_categories.dart';
import '../../domain/usecases/categories/update_category.dart';
import '../../domain/usecases/items/add_item.dart';
import '../../domain/usecases/items/delete_item.dart';
import '../../domain/usecases/items/get_items_by_category.dart';
import '../../domain/usecases/items/search_items.dart';
import '../../domain/usecases/items/update_item.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  // Database
  final db = AppDatabase();
  getIt.registerSingleton<AppDatabase>(db);

  // Data sources
  final localDataSource = LocalDataSource(db);
  getIt.registerSingleton<LocalDataSource>(localDataSource);

  // Repositories
  getIt.registerLazySingleton<CategoryRepository>(
      () => CategoryRepositoryImpl(getIt<LocalDataSource>()));
  getIt.registerLazySingleton<ItemRepository>(
      () => ItemRepositoryImpl(getIt<LocalDataSource>()));

  // Use cases — Categories
  getIt.registerFactory(() => GetCategories(getIt<CategoryRepository>()));
  getIt.registerFactory(() => cat_uc.AddCategory(getIt<CategoryRepository>()));
  getIt.registerFactory(() => cat_uc.UpdateCategory(getIt<CategoryRepository>()));
  getIt.registerFactory(() => cat_uc.DeleteCategory(getIt<CategoryRepository>()));

  // Use cases — Items
  getIt.registerFactory(() => GetItemsByCategory(getIt<ItemRepository>()));
  getIt.registerFactory(() => AddItem(getIt<ItemRepository>()));
  getIt.registerFactory(() => UpdateItem(getIt<ItemRepository>()));
  getIt.registerFactory(() => DeleteItem(getIt<ItemRepository>()));
  getIt.registerFactory(() => SearchItems(getIt<ItemRepository>()));

  // BLoC
  getIt.registerLazySingleton<CategoryBloc>(() => CategoryBloc(getIt<CategoryRepository>()));

  // Item BLoC
  getIt.registerLazySingleton<ItemBloc>(() => ItemBloc(getIt<GetItemsByCategory>()));
}
