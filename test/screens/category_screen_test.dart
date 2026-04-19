import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pc_media_center/presentation/screens/category/category_screen.dart';
import 'package:pc_media_center/presentation/blocs/item/item_bloc.dart';
import 'package:pc_media_center/presentation/blocs/item/item_state.dart';
import 'package:pc_media_center/presentation/blocs/item/item_event.dart';
import 'package:pc_media_center/domain/entities/item.dart';

class MockItemBloc extends Mock implements ItemBloc {}

class FakeItemEvent extends Fake implements ItemEvent {}

void main() {
  late MockItemBloc mockItemBloc;

  setUpAll(() {
    registerFallbackValue(FakeItemEvent());
  });

  setUp(() {
    mockItemBloc = MockItemBloc();
    when(() => mockItemBloc.state).thenReturn(const ItemInitial());
    when(() => mockItemBloc.stream).thenAnswer((_) => Stream.value(const ItemInitial()));
    when(() => mockItemBloc.close()).thenAnswer((_) async {});
  });

  tearDown(() async {
    await mockItemBloc.close();
  });

  group('CategoryScreen Search', () {
    testWidgets('search icon is visible in app bar', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<ItemBloc>.value(
            value: mockItemBloc,
            child: const CategoryScreen(
              categoryId: '1',
              categoryName: 'Test Category',
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('tapping search icon opens search field', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<ItemBloc>.value(
            value: mockItemBloc,
            child: const CategoryScreen(
              categoryId: '1',
              categoryName: 'Test Category',
            ),
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.byIcon(Icons.search));
      await tester.pump();

      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('search field has clear button', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<ItemBloc>.value(
            value: mockItemBloc,
            child: const CategoryScreen(
              categoryId: '1',
              categoryName: 'Test Category',
            ),
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.byIcon(Icons.search));
      await tester.pump();

      await tester.enterText(find.byType(TextField), 'test');
      await tester.pump(const Duration(milliseconds: 350)); // Wait for debounce

      expect(find.byIcon(Icons.clear), findsOneWidget);
    });

    testWidgets('clear button clears search text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<ItemBloc>.value(
            value: mockItemBloc,
            child: const CategoryScreen(
              categoryId: '1',
              categoryName: 'Test Category',
            ),
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.byIcon(Icons.search));
      await tester.pump();

      await tester.enterText(find.byType(TextField), 'test');
      await tester.pump(const Duration(milliseconds: 350)); // Wait for debounce

      expect(find.byIcon(Icons.clear), findsOneWidget);

      await tester.tap(find.byIcon(Icons.clear));
      await tester.pump();

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller?.text, isEmpty);
    });

    testWidgets('search filters items by title', (tester) async {
      final items = [
        ItemEntity(
          id: 1,
          name: 'Movie One',
          title: 'Movie One',
          description: 'Description one',
          launchPath: '/path/one',
          createdAt: DateTime.now(),
        ),
        ItemEntity(
          id: 2,
          name: 'Movie Two',
          title: 'Movie Two',
          description: 'Description two',
          launchPath: '/path/two',
          createdAt: DateTime.now(),
        ),
      ];

      when(() => mockItemBloc.state).thenReturn(ItemLoaded(items: items));
      when(() => mockItemBloc.stream).thenAnswer((_) => Stream.value(ItemLoaded(items: items)));

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<ItemBloc>.value(
            value: mockItemBloc,
            child: const CategoryScreen(
              categoryId: '1',
              categoryName: 'Test Category',
            ),
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.byIcon(Icons.search));
      await tester.pump();

      await tester.enterText(find.byType(TextField), 'One');
      await tester.pump(const Duration(milliseconds: 350));

      expect(find.text('Movie One'), findsOneWidget);
      expect(find.text('Movie Two'), findsNothing);
    });

    testWidgets('search filters items by description', (tester) async {
      final items = [
        ItemEntity(
          id: 1,
          name: 'Movie One',
          title: 'Movie One',
          description: 'Action movie',
          launchPath: '/path/one',
          createdAt: DateTime.now(),
        ),
        ItemEntity(
          id: 2,
          name: 'Movie Two',
          title: 'Movie Two',
          description: 'Comedy movie',
          launchPath: '/path/two',
          createdAt: DateTime.now(),
        ),
      ];

      when(() => mockItemBloc.state).thenReturn(ItemLoaded(items: items));
      when(() => mockItemBloc.stream).thenAnswer((_) => Stream.value(ItemLoaded(items: items)));

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<ItemBloc>.value(
            value: mockItemBloc,
            child: const CategoryScreen(
              categoryId: '1',
              categoryName: 'Test Category',
            ),
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.byIcon(Icons.search));
      await tester.pump();

      await tester.enterText(find.byType(TextField), 'Action');
      await tester.pump(const Duration(milliseconds: 350));

      expect(find.text('Movie One'), findsOneWidget);
      expect(find.text('Movie Two'), findsNothing);
    });

    testWidgets('case insensitive search works', (tester) async {
      final items = [
        ItemEntity(
          id: 1,
          name: 'MOVIE TITLE',
          title: 'MOVIE TITLE',
          description: 'Description',
          launchPath: '/path/one',
          createdAt: DateTime.now(),
        ),
      ];

      when(() => mockItemBloc.state).thenReturn(ItemLoaded(items: items));
      when(() => mockItemBloc.stream).thenAnswer((_) => Stream.value(ItemLoaded(items: items)));

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<ItemBloc>.value(
            value: mockItemBloc,
            child: const CategoryScreen(
              categoryId: '1',
              categoryName: 'Test Category',
            ),
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.byIcon(Icons.search));
      await tester.pump();

      await tester.enterText(find.byType(TextField), 'movie title');
      await tester.pump(const Duration(milliseconds: 350));

      expect(find.text('MOVIE TITLE'), findsOneWidget);
    });

    testWidgets('no results message shown when search has no matches', (tester) async {
      final items = [
        ItemEntity(
          id: 1,
          name: 'Movie One',
          title: 'Movie One',
          description: 'Description',
          launchPath: '/path/one',
          createdAt: DateTime.now(),
        ),
      ];

      when(() => mockItemBloc.state).thenReturn(ItemLoaded(items: items));
      when(() => mockItemBloc.stream).thenAnswer((_) => Stream.value(ItemLoaded(items: items)));

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<ItemBloc>.value(
            value: mockItemBloc,
            child: const CategoryScreen(
              categoryId: '1',
              categoryName: 'Test Category',
            ),
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.byIcon(Icons.search));
      await tester.pump();

      await tester.enterText(find.byType(TextField), 'NonExistent');
      await tester.pump(const Duration(milliseconds: 350));

      expect(find.text('Ничего не найдено'), findsOneWidget);
      expect(find.byIcon(Icons.search_off), findsOneWidget);
    });

    testWidgets('search mode can be exited', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<ItemBloc>.value(
            value: mockItemBloc,
            child: const CategoryScreen(
              categoryId: '1',
              categoryName: 'Test Category',
            ),
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.byIcon(Icons.search));
      await tester.pump();

      expect(find.byType(TextField), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();

      expect(find.byType(TextField), findsNothing);
      expect(find.text('Категория: Test Category'), findsOneWidget);
    });
  });
}