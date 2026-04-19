import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pc_media_center/domain/entities/category.dart';
import 'package:pc_media_center/presentation/blocs/category/category_bloc.dart';
import 'package:pc_media_center/presentation/blocs/category/category_event.dart';
import 'package:pc_media_center/presentation/blocs/category/category_state.dart';

import '../helpers/test_helpers.dart';

class FakeCategoryEntity extends Fake implements CategoryEntity {}

void main() {
  late MockCategoryRepository mockCategoryRepository;
  late CategoryBloc categoryBloc;

  setUpAll(() {
    registerFallbackValue(FakeCategoryEntity());
  });

  setUp(() {
    mockCategoryRepository = MockCategoryRepository();
    categoryBloc = CategoryBloc(mockCategoryRepository);
  });

  tearDown(() {
    categoryBloc.close();
  });

  group('CategoryBloc', () {
    group('LoadCategories', () {
      blocTest<CategoryBloc, CategoryState>(
        'emits [CategoryLoading, CategoryLoaded] when LoadCategories succeeds',
        build: () {
          when(() => mockCategoryRepository.getCategories())
              .thenAnswer((_) async => testCategories);
          return categoryBloc;
        },
        act: (bloc) => bloc.add(LoadCategories()),
        expect: () => [
          isA<CategoryLoading>(),
          isA<CategoryLoaded>().having(
            (state) => state.categories,
            'categories',
            testCategories,
          ),
        ],
        verify: (_) {
          verify(() => mockCategoryRepository.getCategories()).called(1);
        },
      );

      blocTest<CategoryBloc, CategoryState>(
        'emits [CategoryLoading, CategoryError] when LoadCategories fails',
        build: () {
          when(() => mockCategoryRepository.getCategories())
              .thenThrow(Exception('Failed to load categories'));
          return categoryBloc;
        },
        act: (bloc) => bloc.add(LoadCategories()),
        expect: () => [
          isA<CategoryLoading>(),
          isA<CategoryError>().having(
            (state) => state.message,
            'message',
            contains('Failed to load categories'),
          ),
        ],
        verify: (_) {
          verify(() => mockCategoryRepository.getCategories()).called(1);
        },
      );
    });

    group('AddCategoryEvent', () {
      blocTest<CategoryBloc, CategoryState>(
        'emits CategoryLoaded with reloaded categories when AddCategoryEvent succeeds',
        setUp: () {
          when(() => mockCategoryRepository.getCategories())
              .thenAnswer((_) async => testCategories);
          when(() => mockCategoryRepository.addCategory(
                name: any(named: 'name'),
                isMovieType: any(named: 'isMovieType'),
                scanPaths: any(named: 'scanPaths'),
                fileExtensions: any(named: 'fileExtensions'),
              )).thenAnswer((_) async => 3);
        },
        build: () => categoryBloc,
        act: (bloc) => bloc.add(AddCategoryEvent(
          name: 'New Category',
          isMovieType: true,
          scanPaths: '/movies',
          fileExtensions: '.mkv',
        )),
        expect: () => [
          isA<CategoryLoaded>().having(
            (state) => state.categories.length,
            'categories count',
            2,
          ),
        ],
        verify: (_) {
          verify(() => mockCategoryRepository.addCategory(
                name: 'New Category',
                isMovieType: true,
                scanPaths: '/movies',
                fileExtensions: '.mkv',
              )).called(1);
          verify(() => mockCategoryRepository.getCategories()).called(1);
        },
      );

      blocTest<CategoryBloc, CategoryState>(
        'emits CategoryError when AddCategoryEvent has empty name',
        build: () => categoryBloc,
        act: (bloc) => bloc.add(AddCategoryEvent(name: '')),
        expect: () => [
          isA<CategoryError>().having(
            (state) => state.message,
            'message',
            'Название категории обязательно',
          ),
        ],
      );

      blocTest<CategoryBloc, CategoryState>(
        'emits CategoryError when AddCategoryEvent fails',
        setUp: () {
          when(() => mockCategoryRepository.addCategory(
                name: any(named: 'name'),
                isMovieType: any(named: 'isMovieType'),
                scanPaths: any(named: 'scanPaths'),
                fileExtensions: any(named: 'fileExtensions'),
              )).thenThrow(Exception('Failed to add category'));
        },
        build: () => categoryBloc,
        act: (bloc) => bloc.add(AddCategoryEvent(name: 'New Category')),
        expect: () => [
          isA<CategoryError>().having(
            (state) => state.message,
            'message',
            contains('Failed to add category'),
          ),
        ],
      );
    });

    group('DeleteCategoryEvent', () {
      blocTest<CategoryBloc, CategoryState>(
        'emits CategoryLoaded with reloaded categories when DeleteCategoryEvent succeeds',
        setUp: () {
          when(() => mockCategoryRepository.getCategories())
              .thenAnswer((_) async => [testCategory2]); // Return only 1 category after delete
          when(() => mockCategoryRepository.deleteCategory(1))
              .thenAnswer((_) async {});
        },
        build: () => categoryBloc,
        act: (bloc) => bloc.add(DeleteCategoryEvent(1)),
        expect: () => [
          isA<CategoryLoaded>().having(
            (state) => state.categories.length,
            'categories count',
            1,
          ),
        ],
        verify: (_) {
          verify(() => mockCategoryRepository.deleteCategory(1)).called(1);
          verify(() => mockCategoryRepository.getCategories()).called(1);
        },
      );

      blocTest<CategoryBloc, CategoryState>(
        'emits CategoryError when DeleteCategoryEvent fails',
        setUp: () {
          when(() => mockCategoryRepository.deleteCategory(any()))
              .thenThrow(Exception('Failed to delete category'));
        },
        build: () => categoryBloc,
        act: (bloc) => bloc.add(DeleteCategoryEvent(1)),
        expect: () => [
          isA<CategoryError>().having(
            (state) => state.message,
            'message',
            contains('Failed to delete category'),
          ),
        ],
      );
    });

    group('UpdateCategoryEvent', () {
      blocTest<CategoryBloc, CategoryState>(
        'emits CategoryLoaded with reloaded categories when UpdateCategoryEvent succeeds',
        setUp: () {
          when(() => mockCategoryRepository.getCategoryById(1))
              .thenAnswer((_) async => testCategory);
          when(() => mockCategoryRepository.getCategories())
              .thenAnswer((_) async => testCategories);
          when(() => mockCategoryRepository.updateCategory(any()))
              .thenAnswer((_) async {});
        },
        build: () => categoryBloc,
        act: (bloc) => bloc.add(UpdateCategoryEvent(
          categoryId: 1,
          name: 'Updated Category',
          isMovieType: true,
        )),
        expect: () => [
          isA<CategoryLoaded>().having(
            (state) => state.categories.length,
            'categories count',
            2,
          ),
        ],
        verify: (_) {
          verify(() => mockCategoryRepository.getCategoryById(1)).called(1);
          verify(() => mockCategoryRepository.updateCategory(any())).called(1);
          verify(() => mockCategoryRepository.getCategories()).called(1);
        },
      );

      blocTest<CategoryBloc, CategoryState>(
        'emits CategoryError when UpdateCategoryEvent fails',
        setUp: () {
          when(() => mockCategoryRepository.getCategoryById(1))
              .thenAnswer((_) async => testCategory);
          when(() => mockCategoryRepository.updateCategory(any()))
              .thenThrow(Exception('Failed to update category'));
        },
        build: () => categoryBloc,
        act: (bloc) => bloc.add(UpdateCategoryEvent(
          categoryId: 1,
          name: 'Updated',
        )),
        expect: () => [
          isA<CategoryError>().having(
            (state) => state.message,
            'message',
            contains('Failed to update category'),
          ),
        ],
      );
    });
  });
}
