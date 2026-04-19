import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pc_media_center/presentation/screens/home/home_screen.dart';
import 'package:pc_media_center/presentation/blocs/category/category_bloc.dart';
import 'package:pc_media_center/presentation/blocs/category/category_event.dart';
import 'package:pc_media_center/presentation/blocs/category/category_state.dart';
import 'package:pc_media_center/domain/entities/category.dart';
import 'package:pc_media_center/domain/repositories/category_repository.dart';

class MockCategoryBloc extends MockBloc<CategoryEvent, CategoryState> implements CategoryBloc {}
class MockCategoryRepository extends Mock implements CategoryRepository {}
class FakeCategoryEvent extends Fake implements CategoryEvent {}

void main() {
  late MockCategoryBloc mockCategoryBloc;

  setUpAll(() {
    registerFallbackValue(FakeCategoryEvent());
  });

  setUp(() {
    mockCategoryBloc = MockCategoryBloc();
    // Stub close() to return Future.value()
    when(() => mockCategoryBloc.close()).thenAnswer((_) => Future.value());
  });

  tearDown(() {
    mockCategoryBloc.close();
  });

  Widget createTestableWidget(Widget child) {
    return MaterialApp(
      home: BlocProvider<CategoryBloc>.value(
        value: mockCategoryBloc,
        child: child,
      ),
    );
  }

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
      when(() => mockCategoryBloc.state).thenReturn(CategoryLoaded(categories: testCategories));
      whenListen(
        mockCategoryBloc,
        Stream.fromIterable([CategoryLoaded(categories: testCategories)]),
      );

      await tester.pumpWidget(
        createTestableWidget(const HomeScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.edit), findsNWidgets(2));
    });

    testWidgets('tapping edit icon opens edit dialog', (tester) async {
      when(() => mockCategoryBloc.state).thenReturn(CategoryLoaded(categories: testCategories));
      whenListen(
        mockCategoryBloc,
        Stream.fromIterable([CategoryLoaded(categories: testCategories)]),
      );

      await tester.pumpWidget(
        createTestableWidget(const HomeScreen()),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.edit).first);
      await tester.pumpAndSettle();

      expect(find.text('Редактировать категорию'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('edit dialog has current category name pre-filled', (tester) async {
      when(() => mockCategoryBloc.state).thenReturn(CategoryLoaded(categories: testCategories));
      whenListen(
        mockCategoryBloc,
        Stream.fromIterable([CategoryLoaded(categories: testCategories)]),
      );

      await tester.pumpWidget(
        createTestableWidget(const HomeScreen()),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.edit).first);
      await tester.pumpAndSettle();

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller?.text, 'Фильмы');
    });

    testWidgets('saving valid new name calls updateCategory', (tester) async {
      when(() => mockCategoryBloc.state).thenReturn(CategoryLoaded(categories: testCategories));
      whenListen(
        mockCategoryBloc,
        Stream.fromIterable([CategoryLoaded(categories: testCategories)]),
      );

      await tester.pumpWidget(
        createTestableWidget(const HomeScreen()),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.edit).first);
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Новое название');
      await tester.pump();

      await tester.tap(find.text('Сохранить'));
      await tester.pumpAndSettle();

      verify(() => mockCategoryBloc.add(any(that: isA<UpdateCategoryEvent>()))).called(1);
    });

    testWidgets('cancel button closes dialog without changes', (tester) async {
      when(() => mockCategoryBloc.state).thenReturn(CategoryLoaded(categories: testCategories));
      whenListen(
        mockCategoryBloc,
        Stream.fromIterable([CategoryLoaded(categories: testCategories)]),
      );

      await tester.pumpWidget(
        createTestableWidget(const HomeScreen()),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.edit).first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Отмена'));
      await tester.pumpAndSettle();

      expect(find.text('Редактировать категорию'), findsNothing);
      verifyNever(() => mockCategoryBloc.add(any(that: isA<UpdateCategoryEvent>())));
    });

    testWidgets('empty name shows error and does not save', (tester) async {
      when(() => mockCategoryBloc.state).thenReturn(CategoryLoaded(categories: testCategories));
      whenListen(
        mockCategoryBloc,
        Stream.fromIterable([CategoryLoaded(categories: testCategories)]),
      );

      await tester.pumpWidget(
        createTestableWidget(const HomeScreen()),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.edit).first);
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '');
      await tester.pump();

      await tester.tap(find.text('Сохранить'));
      await tester.pumpAndSettle();

      expect(find.text('Название не может быть пустым'), findsOneWidget);
      verifyNever(() => mockCategoryBloc.add(any(that: isA<UpdateCategoryEvent>())));
    });

    testWidgets('duplicate name shows error and does not save', (tester) async {
      when(() => mockCategoryBloc.state).thenReturn(CategoryLoaded(categories: testCategories));
      whenListen(
        mockCategoryBloc,
        Stream.fromIterable([CategoryLoaded(categories: testCategories)]),
      );

      await tester.pumpWidget(
        createTestableWidget(const HomeScreen()),
      );
      await tester.pumpAndSettle();

      // Edit first category and try to name it like the second
      await tester.tap(find.byIcon(Icons.edit).first);
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Игры');
      await tester.pump();

      await tester.tap(find.text('Сохранить'));
      await tester.pumpAndSettle();

      expect(find.text('Категория с таким названием уже существует'), findsOneWidget);
      verifyNever(() => mockCategoryBloc.add(any(that: isA<UpdateCategoryEvent>())));
    });

    testWidgets('same name as current closes dialog without dispatching', (tester) async {
      when(() => mockCategoryBloc.state).thenReturn(CategoryLoaded(categories: testCategories));
      whenListen(
        mockCategoryBloc,
        Stream.fromIterable([CategoryLoaded(categories: testCategories)]),
      );

      await tester.pumpWidget(
        createTestableWidget(const HomeScreen()),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.edit).first);
      await tester.pumpAndSettle();

      // Just tap save without changing
      await tester.tap(find.text('Сохранить'));
      await tester.pumpAndSettle();

      // Should close dialog without dispatching
      expect(find.text('Редактировать категорию'), findsNothing);
      verifyNever(() => mockCategoryBloc.add(any(that: isA<UpdateCategoryEvent>())));
    });
  });
}
