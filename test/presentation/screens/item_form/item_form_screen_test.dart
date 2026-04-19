import 'dart:async';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pc_media_center/domain/entities/category.dart';
import 'package:pc_media_center/domain/entities/item.dart';
import 'package:pc_media_center/presentation/blocs/category/category_bloc.dart';
import 'package:pc_media_center/presentation/blocs/category/category_event.dart';
import 'package:pc_media_center/presentation/blocs/category/category_state.dart';
import 'package:pc_media_center/presentation/blocs/item/item_bloc.dart';
import 'package:pc_media_center/presentation/blocs/item/item_event.dart';
import 'package:pc_media_center/presentation/blocs/item/item_state.dart';
import 'package:pc_media_center/presentation/screens/item_form/item_form_screen.dart';
import 'package:pc_media_center/presentation/widgets/file_picker_button.dart';

import '../../../helpers/test_helpers.dart';

class MockItemBloc extends MockBloc<ItemEvent, ItemState> implements ItemBloc {}

class MockCategoryBloc extends MockBloc<CategoryEvent, CategoryState>
    implements CategoryBloc {}

class FakeItemEvent extends Fake implements ItemEvent {}
class FakeItemState extends Fake implements ItemState {}
class FakeCategoryEvent extends Fake implements CategoryEvent {}
class FakeCategoryState extends Fake implements CategoryState {}

void main() {
  late MockItemBloc mockItemBloc;
  late MockCategoryBloc mockCategoryBloc;

  setUpAll(() {
    registerFallbackValue(FakeItemEvent());
    registerFallbackValue(FakeItemState());
    registerFallbackValue(FakeCategoryEvent());
    registerFallbackValue(FakeCategoryState());
  });

  setUp(() {
    mockItemBloc = MockItemBloc();
    mockCategoryBloc = MockCategoryBloc();

    // Default states
    when(() => mockItemBloc.state).thenReturn(const ItemInitial());
    when(() => mockCategoryBloc.state)
        .thenReturn(CategoryLoaded(categories: testCategories));
    
    // Stub stream for both blocs - this is required for BlocProvider
    when(() => mockItemBloc.stream)
        .thenAnswer((_) => Stream.value(const ItemInitial()));
    when(() => mockCategoryBloc.stream)
        .thenAnswer((_) => Stream.value(CategoryLoaded(categories: testCategories)));
  });

  tearDown(() {
    mockItemBloc.close();
    mockCategoryBloc.close();
  });

  Widget createWidgetUnderTest({
    String? itemId,
    int? initialCategoryId,
  }) {
    return MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider<ItemBloc>.value(value: mockItemBloc),
          BlocProvider<CategoryBloc>.value(value: mockCategoryBloc),
        ],
        child: ItemFormScreen(
          itemId: itemId,
          initialCategoryId: initialCategoryId,
        ),
      ),
    );
  }

  // Helper to create widget with a navigator stack for testing navigation
  Widget createWidgetWithNavigator({
    String? itemId,
    int? initialCategoryId,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => MultiBlocProvider(
                      providers: [
                        BlocProvider<ItemBloc>.value(value: mockItemBloc),
                        BlocProvider<CategoryBloc>.value(value: mockCategoryBloc),
                      ],
                      child: ItemFormScreen(
                        itemId: itemId,
                        initialCategoryId: initialCategoryId,
                      ),
                    ),
                  ),
                );
              },
              child: const Text('Open Form'),
            ),
          ),
        ),
      ),
    );
  }

  group('ItemFormScreen - Create Mode', () {
    testWidgets('displays "Добавить элемент" title in create mode',
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.text('Добавить элемент'), findsOneWidget);
    });

    testWidgets('displays all form fields', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.text('Название'), findsOneWidget);
      expect(find.text('Описание'), findsOneWidget);
      expect(find.text('Год'), findsOneWidget);
      expect(find.byType(FilePickerButton), findsNWidgets(2));
    });

    testWidgets('displays add and cancel buttons', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.text('Добавить'), findsOneWidget);
      expect(find.text('Отмена'), findsOneWidget);
    });

    testWidgets('shows validation error for empty title', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // Scroll to make the button visible
      await tester.ensureVisible(find.text('Добавить'));
      await tester.pump();

      // Tap add button without entering any data
      await tester.tap(find.text('Добавить'));
      await tester.pump();

      expect(find.text('Название обязательно'), findsOneWidget);
    });

    testWidgets('dispatches LoadCategories on init', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // Verify LoadCategories was dispatched
      verify(() => mockCategoryBloc.add(any(that: isA<LoadCategories>())))
          .called(1);
    });

    testWidgets('navigates back on cancel', (tester) async {
      await tester.pumpWidget(createWidgetWithNavigator());
      await tester.pump();

      // Open the form
      await tester.tap(find.text('Open Form'));
      await tester.pumpAndSettle();

      // Verify form is open
      expect(find.byType(ItemFormScreen), findsOneWidget);

      // Scroll to make the cancel button visible and tap it
      await tester.ensureVisible(find.text('Отмена'));
      await tester.pump();
      await tester.tap(find.text('Отмена'));
      await tester.pumpAndSettle();

      // Should pop the route - ItemFormScreen should be gone
      expect(find.byType(ItemFormScreen), findsNothing);
    });
  });

  group('ItemFormScreen - Edit Mode', () {
    testWidgets('displays "Редактировать элемент" title in edit mode',
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(itemId: '1'));
      await tester.pump();

      expect(find.text('Редактировать элемент'), findsOneWidget);
    });

    testWidgets('dispatches LoadItemForEditEvent on init', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(itemId: '1'));
      await tester.pump();

      verify(() => mockItemBloc.add(const LoadItemForEditEvent(1))).called(1);
    });

    testWidgets('shows loading indicator while loading', (tester) async {
      // Set up state and stream with loading state
      when(() => mockItemBloc.state).thenReturn(const ItemFormLoading());
      when(() => mockItemBloc.stream)
          .thenAnswer((_) => Stream.value(const ItemFormLoading()));

      await tester.pumpWidget(createWidgetUnderTest(itemId: '1'));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays save button in edit mode', (tester) async {
      // Set up state and stream with loaded state
      when(() => mockItemBloc.state).thenReturn(ItemFormLoaded(item: testItem));
      when(() => mockItemBloc.stream)
          .thenAnswer((_) => Stream.value(ItemFormLoaded(item: testItem)));

      await tester.pumpWidget(createWidgetUnderTest(itemId: '1'));
      await tester.pump();

      expect(find.text('Сохранить'), findsOneWidget);
    });
  });

  group('ItemFormScreen - Bloc States', () {
    testWidgets('navigates back on ItemSaved', (tester) async {
      // Create a broadcast controller to allow multiple listeners
      final controller = StreamController<ItemState>.broadcast();
      
      when(() => mockItemBloc.stream).thenAnswer((_) => controller.stream);
      when(() => mockItemBloc.state).thenReturn(const ItemInitial());

      await tester.pumpWidget(createWidgetWithNavigator());
      await tester.pump();

      // Open the form
      await tester.tap(find.text('Open Form'));
      await tester.pumpAndSettle();

      // Verify form is open
      expect(find.byType(ItemFormScreen), findsOneWidget);

      // Now emit the ItemSaved state
      controller.add(const ItemSaved());
      await tester.pump();
      await tester.pumpAndSettle();

      // Should navigate back - ItemFormScreen should be gone
      expect(find.byType(ItemFormScreen), findsNothing);
      
      await controller.close();
    });
  });
}
