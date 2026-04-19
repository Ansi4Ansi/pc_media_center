import 'package:mocktail/mocktail.dart';
import 'package:pc_media_center/domain/entities/category.dart';
import 'package:pc_media_center/domain/entities/item.dart';
import 'package:pc_media_center/domain/repositories/category_repository.dart';
import 'package:pc_media_center/domain/repositories/item_repository.dart';
import 'package:pc_media_center/domain/usecases/items/get_items_by_category.dart';
import 'package:pc_media_center/domain/usecases/items/get_item_by_id.dart';
import 'package:pc_media_center/domain/usecases/items/add_item.dart';
import 'package:pc_media_center/domain/usecases/items/update_item.dart';
import 'package:pc_media_center/domain/usecases/items/delete_item.dart';

// Repository mocks
class MockCategoryRepository extends Mock implements CategoryRepository {}

class MockItemRepository extends Mock implements ItemRepository {}

// Use case mocks
class MockGetItemsByCategory extends Mock implements GetItemsByCategory {}

class MockGetItemById extends Mock implements GetItemById {}

class MockAddItem extends Mock implements AddItem {}

class MockUpdateItem extends Mock implements UpdateItem {}

class MockDeleteItem extends Mock implements DeleteItem {}

// Test data
final testDateTime = DateTime(2024, 1, 1);

final testCategory = CategoryEntity(
  id: 1,
  name: 'Test Category',
  icon: 'test_icon',
  sortOrder: 0,
  isMovieType: false,
  scanPaths: '/test/path',
  fileExtensions: '.mp4,.avi',
  createdAt: testDateTime,
  updatedAt: testDateTime,
);

final testCategory2 = CategoryEntity(
  id: 2,
  name: 'Test Category 2',
  icon: 'test_icon_2',
  sortOrder: 1,
  isMovieType: true,
  scanPaths: '/movies',
  fileExtensions: '.mkv,.mp4',
  createdAt: testDateTime,
  updatedAt: testDateTime,
);

final testCategories = [testCategory, testCategory2];

final testItem = ItemEntity(
  id: 1,
  name: 'Test Item',
  title: 'Test Title',
  description: 'Test Description',
  posterPath: '/local/poster.jpg',
  posterUrl: 'https://example.com/poster.jpg',
  createdAt: testDateTime,
  categoryId: 1,
  launchPath: '/path/to/item',
  launchArgs: '--fullscreen',
  itemType: ItemType.movie,
  year: 2024,
  rating: 8.5,
  externalId: 'ext-123',
  metadataJson: '{}',
  sortOrder: 0,
  isFavorite: false,
);

final testItem2 = ItemEntity(
  id: 2,
  name: 'Test Item 2',
  title: 'Test Title 2',
  description: 'Test Description 2',
  createdAt: testDateTime,
  categoryId: 1,
  launchPath: '/path/to/item2',
  itemType: ItemType.tvShow,
  year: 2023,
  rating: 7.5,
  externalId: 'ext-456',
  metadataJson: '{}',
  sortOrder: 1,
  isFavorite: true,
);

final testItems = [testItem, testItem2];
