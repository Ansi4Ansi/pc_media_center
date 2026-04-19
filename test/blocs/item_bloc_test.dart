import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pc_media_center/domain/entities/item.dart';
import 'package:pc_media_center/domain/usecases/items/add_item.dart';
import 'package:pc_media_center/domain/usecases/items/get_item_by_id.dart';
import 'package:pc_media_center/domain/usecases/items/update_item.dart';
import 'package:pc_media_center/presentation/blocs/item/item_bloc.dart';
import 'package:pc_media_center/presentation/blocs/item/item_event.dart';
import 'package:pc_media_center/presentation/blocs/item/item_state.dart';

import '../helpers/test_helpers.dart';

class MockGetItemById extends Mock implements GetItemById {}

class MockAddItem extends Mock implements AddItem {}

class MockUpdateItem extends Mock implements UpdateItem {}

void main() {
  late MockGetItemsByCategory mockGetItemsByCategory;
  late MockGetItemById mockGetItemById;
  late MockAddItem mockAddItem;
  late MockUpdateItem mockUpdateItem;
  late ItemBloc itemBloc;

  setUpAll(() {
    registerFallbackValue(ItemType.movie);
    registerFallbackValue(testItem);
  });

  setUp(() {
    mockGetItemsByCategory = MockGetItemsByCategory();
    mockGetItemById = MockGetItemById();
    mockAddItem = MockAddItem();
    mockUpdateItem = MockUpdateItem();
    itemBloc = ItemBloc(
      mockGetItemsByCategory,
      getItemById: mockGetItemById,
      addItem: mockAddItem,
      updateItem: mockUpdateItem,
    );
  });

  tearDown(() {
    itemBloc.close();
  });

  group('ItemBloc', () {
    group('GetItemsByCategory', () {
      blocTest<ItemBloc, ItemState>(
        'emits [ItemLoaded] when GetItemsByCategory succeeds with items',
        build: () {
          when(() => mockGetItemsByCategory(
                categoryId: any(named: 'categoryId'),
                offset: any(named: 'offset'),
                limit: any(named: 'limit'),
              )).thenAnswer((_) async => testItems);
          return itemBloc;
        },
        act: (bloc) => bloc.add(const GetItemsByCategoryEvent(categoryId: 1)),
        expect: () => [
          isA<ItemLoaded>().having(
            (state) => state.items,
            'items',
            testItems,
          ),
        ],
        verify: (_) {
          verify(() => mockGetItemsByCategory(
                categoryId: 1,
                offset: 0,
                limit: 50,
              )).called(1);
        },
      );

      blocTest<ItemBloc, ItemState>(
        'emits [ItemEmpty] when GetItemsByCategory returns empty list',
        build: () {
          when(() => mockGetItemsByCategory(
                categoryId: any(named: 'categoryId'),
                offset: any(named: 'offset'),
                limit: any(named: 'limit'),
              )).thenAnswer((_) async => []);
          return itemBloc;
        },
        act: (bloc) => bloc.add(const GetItemsByCategoryEvent(categoryId: 1)),
        expect: () => [
          isA<ItemEmpty>(),
        ],
        verify: (_) {
          verify(() => mockGetItemsByCategory(
                categoryId: 1,
                offset: 0,
                limit: 50,
              )).called(1);
        },
      );

      blocTest<ItemBloc, ItemState>(
        'emits [ItemError] when GetItemsByCategory fails',
        build: () {
          when(() => mockGetItemsByCategory(
                categoryId: any(named: 'categoryId'),
                offset: any(named: 'offset'),
                limit: any(named: 'limit'),
              )).thenThrow(Exception('Failed to load items'));
          return itemBloc;
        },
        act: (bloc) => bloc.add(const GetItemsByCategoryEvent(categoryId: 1)),
        expect: () => [
          isA<ItemError>().having(
            (state) => state.message,
            'message',
            contains('Failed to load items'),
          ),
        ],
        verify: (_) {
          verify(() => mockGetItemsByCategory(
                categoryId: 1,
                offset: 0,
                limit: 50,
              )).called(1);
        },
      );

      blocTest<ItemBloc, ItemState>(
        'uses custom offset and limit parameters',
        build: () {
          when(() => mockGetItemsByCategory(
                categoryId: any(named: 'categoryId'),
                offset: any(named: 'offset'),
                limit: any(named: 'limit'),
              )).thenAnswer((_) async => [testItem]);
          return itemBloc;
        },
        act: (bloc) => bloc.add(const GetItemsByCategoryEvent(
          categoryId: 1,
          offset: 10,
          limit: 20,
        )),
        expect: () => [
          isA<ItemLoaded>().having(
            (state) => state.items.length,
            'items count',
            1,
          ),
        ],
        verify: (_) {
          verify(() => mockGetItemsByCategory(
                categoryId: 1,
                offset: 10,
                limit: 20,
              )).called(1);
        },
      );

      blocTest<ItemBloc, ItemState>(
        'handles pagination with offset and limit correctly',
        build: () {
          when(() => mockGetItemsByCategory(
                categoryId: any(named: 'categoryId'),
                offset: any(named: 'offset'),
                limit: any(named: 'limit'),
              )).thenAnswer((invocation) async {
            final offset = invocation.namedArguments[#offset] as int;
            final limit = invocation.namedArguments[#limit] as int;
            // Simulate pagination - return items based on offset and limit
            if (offset >= testItems.length) {
              return [];
            }
            return testItems.skip(offset).take(limit).toList();
          });
          return itemBloc;
        },
        act: (bloc) async {
          // First page
          bloc.add(const GetItemsByCategoryEvent(
            categoryId: 1,
            offset: 0,
            limit: 1,
          ));
          await bloc.stream.first;
          // Second page
          bloc.add(const GetItemsByCategoryEvent(
            categoryId: 1,
            offset: 1,
            limit: 1,
          ));
        },
        expect: () => [
          isA<ItemLoaded>().having(
            (state) => state.items.length,
            'first page items count',
            1,
          ),
          isA<ItemLoaded>().having(
            (state) => state.items.length,
            'second page items count',
            1,
          ),
        ],
      );

      blocTest<ItemBloc, ItemState>(
        'emits [ItemEmpty] when pagination exceeds available items',
        build: () {
          when(() => mockGetItemsByCategory(
                categoryId: any(named: 'categoryId'),
                offset: any(named: 'offset'),
                limit: any(named: 'limit'),
              )).thenAnswer((_) async => []);
          return itemBloc;
        },
        act: (bloc) => bloc.add(const GetItemsByCategoryEvent(
          categoryId: 1,
          offset: 100,
          limit: 50,
        )),
        expect: () => [
          isA<ItemEmpty>(),
        ],
      );
    });

    group('LoadItemForEdit', () {
      blocTest<ItemBloc, ItemState>(
        'emits [ItemFormLoading, ItemFormLoaded] when LoadItemForEdit succeeds',
        build: () {
          when(() => mockGetItemById(any())).thenAnswer((_) async => testItem);
          return itemBloc;
        },
        act: (bloc) => bloc.add(const LoadItemForEditEvent(1)),
        expect: () => [
          isA<ItemFormLoading>(),
          isA<ItemFormLoaded>().having(
            (state) => state.item,
            'item',
            testItem,
          ),
        ],
        verify: (_) {
          verify(() => mockGetItemById(1)).called(1);
        },
      );

      blocTest<ItemBloc, ItemState>(
        'emits [ItemFormLoading, ItemFormError] when LoadItemForEdit fails',
        build: () {
          when(() => mockGetItemById(any()))
              .thenThrow(Exception('Failed to load item'));
          return itemBloc;
        },
        act: (bloc) => bloc.add(const LoadItemForEditEvent(1)),
        expect: () => [
          isA<ItemFormLoading>(),
          isA<ItemFormError>().having(
            (state) => state.message,
            'message',
            contains('Failed to load item'),
          ),
        ],
      );
    });

    group('SaveItem', () {
      blocTest<ItemBloc, ItemState>(
        'emits [ItemFormLoading, ItemSaved] when creating new item succeeds',
        build: () {
          when(() => mockAddItem(
                categoryId: any(that: isNotNull, named: 'categoryId'),
                title: any(that: isNotNull, named: 'title'),
                description: any(named: 'description'),
                launchPath: any(named: 'launchPath'),
                posterPath: any(named: 'posterPath'),
                year: any(named: 'year'),
                itemType: any(that: isNotNull, named: 'itemType'),
              )).thenAnswer((_) async => 1);
          return itemBloc;
        },
        act: (bloc) => bloc.add(const SaveItemEvent(
          categoryId: 1,
          title: 'New Item',
          description: 'Description',
          launchPath: '/path/to/file',
          posterPath: '/path/to/poster',
          year: 2024,
          itemType: ItemType.movie,
        )),
        expect: () => [
          isA<ItemFormLoading>(),
          isA<ItemSaved>(),
        ],
        verify: (_) {
          verify(() => mockAddItem(
                categoryId: 1,
                title: 'New Item',
                description: 'Description',
                launchPath: '/path/to/file',
                posterPath: '/path/to/poster',
                year: 2024,
                itemType: ItemType.movie,
              )).called(1);
        },
      );

      blocTest<ItemBloc, ItemState>(
        'emits [ItemFormLoading, ItemSaved] when updating existing item succeeds',
        build: () {
          when(() => mockGetItemById(any(that: isNotNull)))
              .thenAnswer((_) async => testItem);
          when(() => mockUpdateItem(any(that: isNotNull)))
              .thenAnswer((_) async {});
          return itemBloc;
        },
        act: (bloc) => bloc.add(const SaveItemEvent(
          itemId: 1,
          categoryId: 2,
          title: 'Updated Item',
          description: 'Updated Description',
          launchPath: '/new/path',
          posterPath: '/new/poster',
          year: 2025,
          itemType: ItemType.tvShow,
        )),
        expect: () => [
          isA<ItemFormLoading>(),
          isA<ItemSaved>(),
        ],
        verify: (_) {
          verify(() => mockGetItemById(1)).called(1);
          verify(() => mockUpdateItem(any(that: isNotNull))).called(1);
        },
      );

      blocTest<ItemBloc, ItemState>(
        'emits [ItemFormLoading, ItemFormError] when save fails',
        build: () {
          when(() => mockAddItem(
                categoryId: any(that: isNotNull, named: 'categoryId'),
                title: any(that: isNotNull, named: 'title'),
                description: any(named: 'description'),
                launchPath: any(named: 'launchPath'),
                posterPath: any(named: 'posterPath'),
                year: any(named: 'year'),
                itemType: any(that: isNotNull, named: 'itemType'),
              )).thenThrow(Exception('Failed to save item'));
          return itemBloc;
        },
        act: (bloc) => bloc.add(const SaveItemEvent(
          categoryId: 1,
          title: 'New Item',
          itemType: ItemType.movie,
        )),
        expect: () => [
          isA<ItemFormLoading>(),
          isA<ItemFormError>().having(
            (state) => state.message,
            'message',
            contains('Failed to save item'),
          ),
        ],
      );
    });
  });
}
