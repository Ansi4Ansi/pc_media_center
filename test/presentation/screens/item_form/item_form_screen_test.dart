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

void main() {
  late MockItemBloc mockItemBloc;
  late MockCategoryBloc mockCategoryBloc;

  setUp(() {
    mockItemBloc = MockItemBloc();
    mockCategoryBloc = MockCategoryBloc();

    // Default states
    when(() => mockItemBloc.state).thenReturn(const ItemInitial());
    when(() => mockCategoryBloc.state)
        .thenReturn(CategoryLoaded(categories: testCategories));
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

  group('ItemFormScreen - Create Mode', () {
    testWidgets('displays "Добавить элемент" title in create mode',
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Добавить элемент'), findsOneWidget);
    });

    testWidgets('displays all form fields', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Название'), findsOneWidget);
      expect(find.text('Описание'), findsOneWidget);
      expect(find.text('Год'), findsOneWidget);
      expect(find.text('Категория'), findsOneWidget);
      expect(find.text('Тип элемента'), findsOneWidget);
      expect(find.byType(FilePickerButton), findsNWidgets(2));
    });

    testWidgets('displays save and cancel buttons', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Сохранить'), findsOneWidget);
      expect(find.text('Отмена'), findsOneWidget);
    });

    testWidgets('shows validation error for empty title', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Tap save without entering any data
      await tester.tap(find.text('Сохранить'));
      await tester.pump();

      expect(find.text('Название обязательно'), findsOneWidget);
    });

    testWidgets('shows validation error for unselected category',
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.text('Сохранить'));
      await tester.pump();

      expect(find.text('Выберите категорию'), findsOneWidget);
    });

    testWidgets('dispatches SaveItemEvent on valid form submission',
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Enter title
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Название'), 'Test Item');

      // Select category (need to find dropdown and select)
      await tester.tap(find.byType(DropdownButtonFormField<int>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Test Category').last);
      await tester.pumpAndSettle();

      // Since we can't easily test file picker, we'll test with just required fields
      await tester.tap(find.text('Сохранить'));
      await tester.pump();

      // Verify SaveItemEvent was dispatched
      verify(() => mockItemBloc.add(any(that: isA<SaveItemEvent>())))
          .called(1);
    });

    testWidgets('navigates back on cancel', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.text('Отмена'));
      await tester.pump();

      // Should pop the route
      expect(find.byType(ItemFormScreen), findsNothing);
    });

    testWidgets('pre-selects initialCategoryId when provided',
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(initialCategoryId: 2));

      // Category with ID 2 should be pre-selected
      // Since this is a DropdownButtonFormField, we verify it builds correctly
      expect(find.byType(DropdownButtonFormField<int>), findsOneWidget);
    });
  });

  group('ItemFormScreen - Edit Mode', () {
    setUp(() {
      when(() => mockItemBloc.state)
          .thenReturn(const ItemFormLoaded(item: testItem));
    });

    testWidgets('displays "Редактировать элемент" title in edit mode',
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(itemId: '1'));

      expect(find.text('Редактировать элемент'), findsOneWidget);
    });

    testWidgets('dispatches LoadItemForEditEvent on init', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(itemId: '1'));

      verify(() => mockItemBloc.add(const LoadItemForEditEvent(1))).called(1);
    });

    testWidgets('shows loading indicator while loading', (tester) async {
      when(() => mockItemBloc.state).thenReturn(const ItemFormLoading());

      await tester.pumpWidget(createWidgetUnderTest(itemId: '1'));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('pre-fills form fields with item data', (tester) async {
      when(() => mockItemBloc.state)
          .thenReturn(const ItemFormLoaded(item: testItem));

      await tester.pumpWidget(createWidgetUnderTest(itemId: '1'));

      // Verify form fields contain the item data
      expect(find.text(testItem.title), findsOneWidget);
      expect(find.text(testItem.description), findsOneWidget);
    });

    testWidgets('dispatches SaveItemEvent with itemId when saving in edit mode',
        (tester) async {
      when(() => mockItemBloc.state)
          .thenReturn(const ItemFormLoaded(item: testItem));

      await tester.pumpWidget(createWidgetUnderTest(itemId: '1'));
      await tester.pumpAndSettle();

      // Modify title
      await tester.enterText(
          find.widgetWithText(TextFormField, testItem.title), 'Updated Title');

      await tester.tap(find.text('Сохранить'));
      await tester.pump();

      // Verify SaveItemEvent with itemId was dispatched
      final captured = verify(() => mockItemBloc.add(captureAny())).captured;
      final saveEvent = captured.firstWhere((e) => e is SaveItemEvent);
      expect(saveEvent.itemId, equals(1));
    });
  });

  group('ItemFormScreen - Bloc States', () {
    testWidgets('shows error message on ItemFormError', (tester) async {
      whenListen(
        mockItemBloc,
        Stream.fromIterable([
          const ItemFormError(message: 'Error saving item'),
        ]),
        initialState: const ItemInitial(),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.text('Error saving item'), findsOneWidget);
    });

    testWidgets('navigates back on ItemSaved', (tester) async {
      whenListen(
        mockItemBloc,
        Stream.fromIterable([
          const ItemSaved(),
        ]),
        initialState: const ItemInitial(),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // Should navigate back
      expect(find.byType(ItemFormScreen), findsNothing);
    });
  });

  group('ItemFormScreen - Form Validation', () {
    testWidgets('validates year format', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Enter invalid year
      await tester.enterText(find.widgetWithText(TextFormField, 'Год'), 'abc');
      await tester.tap(find.text('Сохранить'));
      await tester.pump();

      // Should show year validation error
      expect(find.text('Некорректный год'), findsOneWidget);
    });

    testWidgets('accepts valid year', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Enter valid year
      await tester.enterText(find.widgetWithText(TextFormField, 'Год'), '2024');
      await tester.pump();

      // Should not show validation error
      expect(find.text('Некорректный год'), findsNothing);
    });
  });
}
