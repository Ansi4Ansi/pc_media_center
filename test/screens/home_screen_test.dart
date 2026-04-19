import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pc_media_center/presentation/screens/home/home_screen.dart';
import 'package:pc_media_center/presentation/blocs/category/category_bloc.dart';
import 'package:pc_media_center/presentation/blocs/category/category_state.dart';
import 'package:pc_media_center/presentation/blocs/category/category_event.dart';
import 'package:pc_media_center/domain/entities/category.dart';
import 'package:pc_media_center/domain/repositories/category_repository.dart';

class MockCategoryRepository extends Mock implements CategoryRepository {}

class FakeCategoryEntity extends Fake implements CategoryEntity {}

void main() {
  late MockCategoryRepository mockCategoryRepository;
  final getIt = GetIt.instance;

  setUpAll(() {
    registerFallbackValue(FakeCategoryEntity());
  });

  setUp(() {
    mockCategoryRepository = MockCategoryRepository();
    
    // Register mock in getIt
    if (getIt.isRegistered<CategoryBloc>()) {
      getIt.unregister<CategoryBloc>();
    }
    getIt.registerFactory<CategoryBloc>(() => CategoryBloc(mockCategoryRepository));
  });

  tearDown(() {
    if (getIt.isRegistered<CategoryBloc>()) {
      getIt.unregister<CategoryBloc>();
    }
  });

  group('HomeScreen Category Edit', () {
    final testCategories = [
      CategoryEntity(
        id: 1,
        name: 'Фильмы',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      CategoryEntity(
        id: 2,
        name: 'Игры',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    testWidgets('edit icon is visible on category cards', (tester) async {
      when(() => mockCategoryRepository.getCategories()).thenAnswer((_) async => testCategories);

      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.edit), findsNWidgets(2));
    });

    testWidgets('tapping edit icon opens edit dialog', (tester) async {
      when(() => mockCategoryRepository.getCategories()).thenAnswer((_) async => testCategories);

      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.edit).first);
      await tester.pumpAndSettle();

      expect(find.text('Редактировать категорию'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('edit dialog has current category name pre-filled', (tester) async {
      when(() => mockCategoryRepository.getCategories()).thenAnswer((_) async => testCategories);

      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.edit).first);
      await tester.pumpAndSettle();

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller?.text, 'Фильмы');
    });

    testWidgets('saving valid new name dispatches UpdateCategoryEvent', (tester) async {
      when(() => mockCategoryRepository.getCategories()).thenAnswer((_) async => testCategories);
      when(() => mockCategoryRepository.getCategoryById(1)).thenAnswer((_) async => testCategories[0]);
      when(() => mockCategoryRepository.updateCategory(any())).thenAnswer((_) async => true);

      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.edit).first);
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Новое название');
      await tester.pump();

      await tester.tap(find.text('Сохранить'));
      await tester.pump();

      verify(() => mockCategoryRepository.updateCategory(any())).called(1);
    });

    testWidgets('cancel button closes dialog without changes', (tester) async {
      when(() => mockCategoryRepository.getCategories()).thenAnswer((_) async => testCategories);

      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.edit).first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Отмена'));
      await tester.pump();

      expect(find.text('Редактировать категорию'), findsNothing);
      verifyNever(() => mockCategoryRepository.updateCategory(any()));
    });

    testWidgets('empty name shows error and does not save', (tester) async {
      when(() => mockCategoryRepository.getCategories()).thenAnswer((_) async => testCategories);

      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.edit).first);
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '');
      await tester.pump();

      await tester.tap(find.text('Сохранить'));
      await tester.pump();

      expect(find.text('Название не может быть пустым'), findsOneWidget);
      verifyNever(() => mockCategoryRepository.updateCategory(any()));
    });

    testWidgets('duplicate name shows error and does not save', (tester) async {
      when(() => mockCategoryRepository.getCategories()).thenAnswer((_) async => testCategories);

      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Edit first category and try to name it like the second
      await tester.tap(find.byIcon(Icons.edit).first);
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Игры');
      await tester.pump();

      await tester.tap(find.text('Сохранить'));
      await tester.pump();

      expect(find.text('Категория с таким названием уже существует'), findsOneWidget);
      verifyNever(() => mockCategoryRepository.updateCategory(any()));
    });

    testWidgets('same name as current does not dispatch event', (tester) async {
      when(() => mockCategoryRepository.getCategories()).thenAnswer((_) async => testCategories);

      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.edit).first);
      await tester.pumpAndSettle();

      // Just tap save without changing
      await tester.tap(find.text('Сохранить'));
      await tester.pump();

      // Should close dialog without dispatching
      expect(find.text('Редактировать категорию'), findsNothing);
      verifyNever(() => mockCategoryRepository.updateCategory(any()));
    });

    testWidgets('tapping category card navigates to category screen', (tester) async {
      when(() => mockCategoryRepository.getCategories()).thenAnswer((_) async => testCategories);

      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Tap on the category card itself (not the edit/delete buttons)
      await tester.tap(find.text('Фильмы'));
      await tester.pumpAndSettle();

      // Should navigate to CategoryScreen
      expect(find.text('Категория: Фильмы'), findsOneWidget);
    });
  });
}
