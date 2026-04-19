import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pc_media_center/presentation/blocs/item/item_bloc.dart';
import 'package:pc_media_center/presentation/blocs/item/item_event.dart';
import 'package:pc_media_center/presentation/blocs/item/item_state.dart';

import '../helpers/test_helpers.dart';

void main() {
  late MockGetItemsByCategory mockGetItemsByCategory;
  late ItemBloc itemBloc;

  setUp(() {
    mockGetItemsByCategory = MockGetItemsByCategory();
    itemBloc = ItemBloc(mockGetItemsByCategory);
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
  });
}
