import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../../presentation/blocs/category/category_bloc.dart';
import '../../presentation/blocs/item/item_bloc.dart';
import '../../domain/usecases/categories/add_category.dart' as cat_uc;
import '../../domain/usecases/categories/update_category.dart' as cat_uc;
import '../../domain/usecases/categories/delete_category.dart' as cat_uc;
import '../../data/database/app_database.dart';
import '../../data/datasources/local/local_data_source.dart';
import '../../data/datasources/remote/tmdb_api.dart';
import '../../data/datasources/remote/kinopoisk_api.dart';
import '../../data/repositories/category_repository_impl.dart';
import '../../data/repositories/item_repository_impl.dart';
import '../../data/repositories/search_repository_impl.dart';
import '../../domain/repositories/category_repository.dart';
import '../../domain/repositories/item_repository.dart';
import '../../domain/repositories/search_repository.dart';
import '../../domain/usecases/categories/get_categories.dart';
import '../../domain/usecases/items/add_item.dart';
import '../../domain/usecases/items/delete_item.dart';
import '../../domain/usecases/items/get_item_by_id.dart';
import '../../domain/usecases/items/get_items_by_category.dart';
import '../../domain/usecases/items/search_items.dart';
import '../../domain/usecases/items/update_item.dart';
import '../../core/services/directory_scanner.dart';
import '../../core/services/launcher_service.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  // Database
  final db = AppDatabase();
  getIt.registerSingleton<AppDatabase>(db);

  // Data sources
  final localDataSource = LocalDataSource(db);
  getIt.registerSingleton<LocalDataSource>(localDataSource);

  // HTTP Client (Dio) - Singleton with timeout configuration
  getIt.registerLazySingleton<Dio>(() {
    final dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 10),
      sendTimeout: const Duration(seconds: 5),
    ));
    return dio;
  });

  // API Clients
  getIt.registerLazySingleton<TMDbApiClient>(
    () => TMDbApiClient(
      apiKey: const String.fromEnvironment('TMDB_API_KEY'),
      localCache: getIt<LocalDataSource>(),
      dio: getIt<Dio>(),
    ),
  );
  getIt.registerLazySingleton<KinopoiskApiClient>(
    () => KinopoiskApiClient(
      apiKey: const String.fromEnvironment('KINOPOISK_API_KEY'),
      localCache: getIt<LocalDataSource>(),
      dio: getIt<Dio>(),
    ),
  );

  // Repositories
  getIt.registerLazySingleton<CategoryRepository>(
      () => CategoryRepositoryImpl(getIt<LocalDataSource>()));
  getIt.registerLazySingleton<ItemRepository>(
      () => ItemRepositoryImpl(getIt<LocalDataSource>()));
  getIt.registerLazySingleton<SearchRepository>(
    () => SearchRepositoryImpl(
      getIt<TMDbApiClient>(),
      getIt<KinopoiskApiClient>(),
      getIt<LocalDataSource>(),
    ),
  );

  // Use cases — Categories
  getIt.registerFactory(() => GetCategories(getIt<CategoryRepository>()));
  getIt.registerFactory(() => cat_uc.AddCategory(getIt<CategoryRepository>()));
  getIt.registerFactory(() => cat_uc.UpdateCategory(getIt<CategoryRepository>()));
  getIt.registerFactory(() => cat_uc.DeleteCategory(getIt<CategoryRepository>()));

  // Use cases — Items
  getIt.registerFactory<GetItemsByCategory>(
    () => GetItemsByCategoryImpl(getIt<ItemRepository>()),
  );
  getIt.registerFactory(() => AddItem(getIt<ItemRepository>()));
  getIt.registerFactory(() => UpdateItem(getIt<ItemRepository>()));
  getIt.registerFactory(() => DeleteItem(getIt<ItemRepository>()));
  getIt.registerFactory(() => SearchItems(getIt<ItemRepository>()));
  getIt.registerFactory(() => GetItemById(getIt<ItemRepository>()));

  // Services
  getIt.registerLazySingleton<LauncherService>(LauncherService.create);
  getIt.registerLazySingleton<DirectoryScanner>(() => DirectoryScanner());

  // BLoC
  getIt.registerLazySingleton<CategoryBloc>(() => CategoryBloc(getIt<CategoryRepository>()));

  // Item BLoC
  getIt.registerFactory<ItemBloc>(() => ItemBloc(
        getIt<GetItemsByCategory>(),
        getItemById: getIt<GetItemById>(),
        deleteItem: getIt<DeleteItem>(),
      ));
}
