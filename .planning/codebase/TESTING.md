# Testing Patterns

**Analysis Date:** 2026-04-19

## Test Framework

**Runner:**
- **flutter_test** (from Flutter SDK) - Primary testing framework
- **bloc_test** (^10.0.0) - Testing utilities for BLoC pattern
- **mocktail** (^1.0.4) - Mocking library for Dart

**Run Commands:**
```bash
flutter test              # Run all tests
flutter test --coverage   # Run tests with coverage
flutter analyze           # Static analysis
flutter format --set-exit-if-changed .  # Format verification
```

## Test File Organization

**Location:**
- All tests live in `test/` directory
- Co-located by feature not implemented (currently single test file)

**Naming:**
- `*_test.dart` suffix for test files
- Current: `test/widget_test.dart`

**Structure:**
```
test/
└── widget_test.dart      # Placeholder smoke test
```

## Current Test State

The project currently has minimal test coverage with only a placeholder test:

```dart
// test/widget_test.dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Placeholder — will be replaced with real tests
    expect(true, isTrue);
  });
}
```

## Recommended Testing Patterns

### Unit Test Pattern

**Use Case Testing:**
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pc_media_center/domain/entities/item.dart';
import 'package:pc_media_center/domain/repositories/item_repository.dart';
import 'package:pc_media_center/domain/usecases/items/get_items_by_category.dart';

class MockItemRepository extends Mock implements ItemRepository {}

void main() {
  late GetItemsByCategory useCase;
  late MockItemRepository mockRepository;

  setUp(() {
    mockRepository = MockItemRepository();
    useCase = GetItemsByCategoryImpl(mockRepository);
  });

  group('GetItemsByCategory', () {
    final tItems = [
      ItemEntity(
        id: '1',
        name: 'Test Movie',
        title: 'Test Movie',
        categoryId: 1,
        createdAt: DateTime.now(),
      ),
    ];

    test('should return paginated items from repository', () async {
      // Arrange
      when(() => mockRepository.getItemsByCategory(1))
          .thenAnswer((_) async => tItems);

      // Act
      final result = await useCase(categoryId: 1, offset: 0, limit: 10);

      // Assert
      expect(result, equals(tItems));
      verify(() => mockRepository.getItemsByCategory(1)).called(1);
    });
  });
}
```

### BLoC Testing Pattern

**Using bloc_test:**
```dart
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pc_media_center/domain/entities/item.dart';
import 'package:pc_media_center/domain/usecases/items/get_items_by_category.dart';
import 'package:pc_media_center/presentation/blocs/item/item_bloc.dart';
import 'package:pc_media_center/presentation/blocs/item/item_event.dart';
import 'package:pc_media_center/presentation/blocs/item/item_state.dart';

class MockGetItemsByCategory extends Mock implements GetItemsByCategory {}

void main() {
  late MockGetItemsByCategory mockGetItems;
  late ItemBloc bloc;

  setUp(() {
    mockGetItems = MockGetItemsByCategory();
    bloc = ItemBloc(mockGetItems);
  });

  tearDown(() => bloc.close());

  group('ItemBloc', () {
    final tItems = [
      ItemEntity(
        id: '1',
        name: 'Test',
        title: 'Test',
        categoryId: 1,
        createdAt: DateTime.now(),
      ),
    ];

    blocTest<ItemBloc, ItemState>(
      'emits [ItemLoading, ItemLoaded] when GetItemsByCategory succeeds',
      build: () {
        when(() => mockGetItems(
          categoryId: any(named: 'categoryId'),
          offset: any(named: 'offset'),
          limit: any(named: 'limit'),
        )).thenAnswer((_) async => tItems);
        return bloc;
      },
      act: (bloc) => bloc.add(const GetItemsByCategory(
        categoryId: '1',
        offset: 0,
        limit: 50,
      )),
      expect: () => [
        ItemLoaded(items: tItems),
      ],
    );

    blocTest<ItemBloc, ItemState>(
      'emits [ItemLoading, ItemEmpty] when no items found',
      build: () {
        when(() => mockGetItems(
          categoryId: any(named: 'categoryId'),
          offset: any(named: 'offset'),
          limit: any(named: 'limit'),
        )).thenAnswer((_) async => []);
        return bloc;
      },
      act: (bloc) => bloc.add(const GetItemsByCategory(
        categoryId: '1',
        offset: 0,
        limit: 50,
      )),
      expect: () => [
        ItemEmpty(),
      ],
    );

    blocTest<ItemBloc, ItemState>(
      'emits [ItemLoading, ItemError] when repository throws',
      build: () {
        when(() => mockGetItems(
          categoryId: any(named: 'categoryId'),
          offset: any(named: 'offset'),
          limit: any(named: 'limit'),
        )).thenThrow(Exception('Network error'));
        return bloc;
      },
      act: (bloc) => bloc.add(const GetItemsByCategory(
        categoryId: '1',
        offset: 0,
        limit: 50,
      )),
      expect: () => [
        ItemError(message: 'Exception: Network error'),
      ],
    );
  });
}
```

### Repository Testing Pattern

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pc_media_center/data/datasources/local/local_data_source.dart';
import 'package:pc_media_center/data/models/item_model.dart';
import 'package:pc_media_center/data/repositories/item_repository_impl.dart';
import 'package:pc_media_center/domain/entities/item.dart';

class MockLocalDataSource extends Mock implements LocalDataSource {}

void main() {
  late ItemRepositoryImpl repository;
  late MockLocalDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockLocalDataSource();
    repository = ItemRepositoryImpl(mockDataSource);
  });

  group('getItemsByCategory', () {
    final tDbItems = <Item>[];  // Drift model items
    final tCategoryId = 1;

    test('should return list of ItemEntity from data source', () async {
      // Arrange
      when(() => mockDataSource.getItemsByCategory(tCategoryId))
          .thenAnswer((_) async => tDbItems);

      // Act
      final result = await repository.getItemsByCategory(tCategoryId);

      // Assert
      verify(() => mockDataSource.getItemsByCategory(tCategoryId));
      expect(result, isA<List<ItemEntity>>());
    });
  });
}
```

### Widget Testing Pattern

```dart
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pc_media_center/domain/entities/category.dart';
import 'package:pc_media_center/presentation/blocs/category/category_bloc.dart';
import 'package:pc_media_center/presentation/blocs/category/category_event.dart';
import 'package:pc_media_center/presentation/blocs/category/category_state.dart';
import 'package:pc_media_center/presentation/screens/home/home_screen.dart';

class MockCategoryBloc extends MockBloc<CategoryEvent, CategoryState>
    implements CategoryBloc {}

void main() {
  late MockCategoryBloc mockBloc;

  setUp(() {
    mockBloc = MockCategoryBloc();
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: BlocProvider<CategoryBloc>.value(
        value: mockBloc,
        child: const HomeScreen(),
      ),
    );
  }

  testWidgets('renders loading indicator when state is CategoryLoading',
      (tester) async {
    when(() => mockBloc.state).thenReturn(CategoryLoading());

    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('renders categories list when state is CategoryLoaded',
      (tester) async {
    final categories = [
      CategoryEntity(
        id: 1,
        name: 'Movies',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
    when(() => mockBloc.state)
        .thenReturn(CategoryLoaded(categories: categories));

    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.text('Movies'), findsOneWidget);
  });
}
```

### Entity Testing Pattern

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:pc_media_center/domain/entities/item.dart';

void main() {
  group('ItemEntity', () {
    test('should be equal when properties match', () {
      final date = DateTime.now();
      final item1 = ItemEntity(
        id: '1',
        name: 'Test',
        title: 'Test',
        createdAt: date,
      );
      final item2 = ItemEntity(
        id: '1',
        name: 'Test',
        title: 'Test',
        createdAt: date,
      );

      expect(item1, equals(item2));
    });

    test('should have correct default values', () {
      final item = ItemEntity(
        id: '1',
        name: 'Test',
        createdAt: DateTime.now(),
      );

      expect(item.categoryId, equals(0));
      expect(item.title, equals(''));
      expect(item.itemType, equals(ItemType.movie));
      expect(item.isFavorite, isFalse);
    });
  });
}
```

## Mocking Strategy

### Mocktail Setup

**Register Fallback Values:**
```dart
import 'package:mocktail/mocktail.dart';

class FakeItemEntity extends Fake implements ItemEntity {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeItemEntity());
  });
}
```

### What to Mock

**Mock:**
- Repositories in use case tests
- Use cases in BLoC tests
- Data sources in repository tests
- BLoCs in widget tests
- External services (API, database)

**Don't Mock:**
- Entity objects (use real instances)
- Value objects
- Simple data classes

## Test Data Management

### Fixtures

Create fixture files for reusable test data:

```dart
// test/fixtures/item_fixtures.dart
import 'package:pc_media_center/domain/entities/item.dart';

class ItemFixtures {
  static ItemEntity movie({String? id, String? title}) {
    return ItemEntity(
      id: id ?? '1',
      name: title ?? 'Test Movie',
      title: title ?? 'Test Movie',
      categoryId: 1,
      itemType: ItemType.movie,
      createdAt: DateTime(2024, 1, 1),
    );
  }

  static List<ItemEntity> movieList({int count = 3}) {
    return List.generate(
      count,
      (i) => movie(id: '$i', title: 'Movie $i'),
    );
  }
}
```

## Coverage Setup

**Generate Coverage Report:**
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

**Coverage Tools:**
- `lcov` - Coverage data collection
- `genhtml` - HTML report generation
- VS Code Flutter extension - In-editor coverage visualization

**Recommended Coverage Targets:**
- Domain layer: 90%+ (business logic)
- Data layer: 70%+ (repositories)
- Presentation layer: 60%+ (BLoCs)
- Widgets: 40%+ (critical user flows)

## CI/CD Test Execution

### GitHub Actions Pattern

```yaml
# .github/workflows/test.yml
name: Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.24.0'
          channel: 'stable'
      
      - name: Get dependencies
        run: flutter pub get
      
      - name: Analyze
        run: flutter analyze
      
      - name: Format check
        run: flutter format --set-exit-if-changed .
      
      - name: Run tests
        run: flutter test --coverage
      
      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          file: coverage/lcov.info
```

## Testing Hierarchy

### Test Types

**Unit Tests:**
- Location: `test/unit/`
- Scope: Individual classes/functions
- Dependencies: Mocked
- Speed: Fast (< 100ms per test)
- Examples: Use cases, entity logic, extension methods

**Widget Tests:**
- Location: `test/widget/`
- Scope: Individual widgets/screens
- Dependencies: BLoCs mocked
- Speed: Medium (100-500ms per test)
- Examples: Screen rendering, user interactions

**Integration Tests:**
- Location: `integration_test/`
- Scope: Feature flows
- Dependencies: Real (database, repositories)
- Speed: Slow (> 1s per test)
- Examples: End-to-end scenarios

## Test Naming Conventions

### Descriptive Names
```dart
// Good
'emits [CategoryLoading, CategoryLoaded] when LoadCategories succeeds'
'returns empty list when repository has no items'
'calls deleteCategory with correct id when DeleteCategoryEvent received'

// Avoid
'test bloc'
'it works'
'empty test'
```

### Group Structure
```dart
group('CategoryBloc', () {
  group('LoadCategories', () { ... });
  group('AddCategoryEvent', () { ... });
  group('DeleteCategoryEvent', () { ... });
});
```

## Async Testing

```dart
test('should complete async operation', () async {
  when(() => mockRepo.fetchData()).thenAnswer((_) async => data);
  
  final result = await useCase.call();
  
  expect(result, equals(expected));
});

// For streams
expectLater(
  bloc.stream,
  emitsInOrder([State1, State2]),
);
```

## Golden File Testing

```dart
// test/goldens/home_screen_test.dart
testWidgets('home screen matches golden file', (tester) async {
  await tester.pumpWidget(const App());
  await tester.pumpAndSettle();
  
  await expectLater(
    find.byType(HomeScreen),
    matchesGoldenFile('goldens/home_screen.png'),
  );
});
```

---

*Testing analysis: 2026-04-19*
