import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pc_media_center/presentation/screens/home/home_screen.dart';
import 'package:pc_media_center/presentation/blocs/category/category_bloc.dart';
import 'package:pc_media_center/domain/entities/category.dart';
import 'package:pc_media_center/domain/repositories/category_repository.dart';

class MockCategoryRepository extends Mock implements CategoryRepository {}

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
        MaterialApp(
          home: HomeScreen(categoryBloc: categoryBloc),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.edit), findsNWidgets(2));
    });

    testWidgets('tapping edit icon opens edit dialog', (tester) async {
      when(() => mockCategoryRepository.getCategories()).thenAnswer((_) async => testCategories);

      await tester.pumpWidget(
        MaterialApp(
          home: HomeScreen(categoryBloc: categoryBloc),
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
        MaterialApp(
          home: HomeScreen(categoryBloc: categoryBloc),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.edit).first);
      await tester.pumpAndSettle();

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller?.text, 'Фильмы');
    });

    testWidgets('saving valid new name calls updateCategory', (tester) async {
      when(() => mockCategoryRepository.getCategories()).thenAnswer((_) async => testCategories);
      when(() => mockCategoryRepository.getCategoryById(1)).thenAnswer((_) async => testCategories[0]);
      when(() => mockCategoryRepository.updateCategory(any())).thenAnswer((_) async => true);

      await tester.pumpWidget(
        MaterialApp(
          home: HomeScreen(categoryBloc: categoryBloc),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.edit).first);
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Новое название');
      await tester.pump();

      await tester.tap(find.text('Сохранить'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      verify(() => mockCategoryRepository.updateCategory(any())).called(1);
    });

    testWidgets('cancel button closes dialog without changes', (tester) async {
      when(() => mockCategoryRepository.getCategories()).thenAnswer((_) async => testCategories);

      await tester.pumpWidget(
        MaterialApp(
          home: HomeScreen(categoryBloc: categoryBloc),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.edit).first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Отмена'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Редактировать категорию'), findsNothing);
      verifyNever(() => mockCategoryRepository.updateCategory(any()));
    });

    testWidgets('empty name shows error and does not save', (tester) async {
      when(() => mockCategoryRepository.getCategories()).thenAnswer((_) async => testCategories);

      await tester.pumpWidget(
        MaterialApp(
          home: HomeScreen(categoryBloc: categoryBloc),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.edit).first);
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '');
      await tester.pump();

      await tester.tap(find.text('Сохранить'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Название не может быть пустым'), findsOneWidget);
      verifyNever(() => mockCategoryRepository.updateCategory(any()));
    });

    testWidgets('duplicate name shows error and does not save', (tester) async {
      when(() => mockCategoryRepository.getCategories()).thenAnswer((_) async => testCategories);

      await tester.pumpWidget(
        MaterialApp(
          home: HomeScreen(categoryBloc: categoryBloc),
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
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Категория с таким названием уже существует'), findsOneWidget);
      verifyNever(() => mockCategoryRepository.updateCategory(any()));
    });

    testWidgets('same name as current closes dialog without dispatching', (tester) async {
      when(() => mockCategoryRepository.getCategories()).thenAnswer((_) async => testCategories);

      await tester.pumpWidget(
        MaterialApp(
          home: HomeScreen(categoryBloc: categoryBloc),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.edit).first);
      await tester.pumpAndSettle();

      // Just tap save without changing
      await tester.tap(find.text('Сохранить'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Should close dialog without dispatching
      expect(find.text('Редактировать категорию'), findsNothing);
      verifyNever(() => mockCategoryRepository.updateCategory(any()));
    });
  });
}
