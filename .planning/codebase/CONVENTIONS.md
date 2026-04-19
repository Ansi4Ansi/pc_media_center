# Coding Conventions

**Analysis Date:** 2026-04-19

## Overview

This Flutter/Dart project follows Clean Architecture principles with BLoC state management. The codebase adheres to standard Dart and Flutter conventions enforced through `flutter_lints`.

## Naming Conventions

### Files
- **Snake_case**: All Dart files use `snake_case.dart`
- **Naming by layer**:
  - Entities: `item.dart`, `category.dart` (lib/domain/entities/)
  - Models: `item_model.dart` (lib/data/models/)
  - BLoCs: `item_bloc.dart` (lib/presentation/blocs/item/)
  - Events: `item_event.dart` (lib/presentation/blocs/item/)
  - States: `item_state.dart` (lib/presentation/blocs/item/)
  - Screens: `home_screen.dart`, `item_detail_screen.dart` (lib/presentation/screens/)
  - Widgets: `item_card.dart`, `category_card.dart` (lib/presentation/widgets/)
  - Tables: `items_table.dart` (lib/data/database/tables/)
  - DAOs: `items_dao.dart` (lib/data/database/daos/)

### Classes
- **PascalCase** for all class names
- Suffix conventions:
  - Entities: `*Entity` (e.g., `ItemEntity`, `CategoryEntity`)
  - BLoCs: `*Bloc` (e.g., `ItemBloc`, `CategoryBloc`)
  - States: `*State` abstract class with concrete implementations
  - Events: `*Event` abstract class with concrete implementations
  - Repositories: `*Repository` interface + `*RepositoryImpl` implementation
  - Use Cases: `*UseCase` or descriptive action name (e.g., `GetItemsByCategory`)
  - Extension methods: `*Mapper`, `*Extension` (e.g., `ItemModelMapper`, `ItemTypeExtension`)

```dart
// Entity
class ItemEntity extends Equatable { ... }

// BLoC
class ItemBloc extends Bloc<ItemEvent, ItemState> { ... }

// Repository
abstract class ItemRepository { ... }
class ItemRepositoryImpl implements ItemRepository { ... }

// Extension
extension ItemModelMapper on Item { ... }
```

### Functions & Methods
- **camelCase** for all methods and functions
- Private methods prefixed with underscore: `_onLoadCategories`, `_parseItemType`
- Event handlers in BLoCs: `_on[EventName]` pattern

```dart
Future<void> _onLoadCategories(LoadCategories event, Emitter<CategoryState> emit) async { ... }
static ItemType _parseItemType(String type) { ... }
```

### Variables & Properties
- **camelCase** for all variables
- **Leading underscore** for private class members
- **Final** by default, mutable only when necessary
- Nullable types use `?` suffix: `String? posterUrl`

```dart
final String id;
final String? posterUrl;
final List<String> launchArgs;
String? _newCategoryName;  // Private
```

### Constants
- **camelCase** for local constants within methods
- **k-prefixed** for global constants (not currently used)
- Default values in constructors use `const` where applicable

```dart
this.offset = 0,
this.limit = 50,
this.launchArgs = const [],
```

## Code Style

### Formatting
- **Tool**: `dart format` enforced through `flutter_lints`
- **Line length**: Default (80 characters recommended)
- **Trailing commas**: Used in multi-line collections and parameter lists
- **Indentation**: 2 spaces

### Linting
- **Configuration**: `analysis_options.yaml`
- **Base rules**: `package:flutter_lints/flutter.yaml`
- **Run**: `flutter analyze`

```yaml
# analysis_options.yaml
include: package:flutter_lints/flutter.yaml
linter:
  rules:
    # Uncomment to customize
    # avoid_print: false
    # prefer_single_quotes: true
```

## Import Organization

### Order
1. Dart SDK imports
2. Flutter SDK imports
3. Third-party package imports
4. Local project imports (using relative paths)

```dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:drift/drift.dart';

import '../../../domain/entities/item.dart';
import '../../../domain/usecases/items/get_items_by_category.dart';
```

### Path Aliases
- **Relative paths** used throughout: `../../../domain/entities/item.dart`
- No `package:` prefix for local imports within lib/

## Architecture Patterns

### Clean Architecture Layers

**Domain Layer** (`lib/domain/`):
- Pure Dart, no Flutter dependencies
- Entities define core data structures
- Repository interfaces (abstract classes)
- Use cases encapsulate business logic

```dart
// lib/domain/entities/item.dart
class ItemEntity extends Equatable {
  final String id;
  final String title;
  // ...
}

// lib/domain/repositories/item_repository.dart
abstract class ItemRepository {
  Future<List<ItemEntity>> getItemsByCategory(int categoryId);
}
```

**Data Layer** (`lib/data/`):
- Models for external data mapping
- Repository implementations
- Data sources (local/remote)
- Database tables and DAOs

```dart
// lib/data/models/item_model.dart
extension ItemModelMapper on Item {
  ItemEntity toEntity() { ... }
}
```

**Presentation Layer** (`lib/presentation/`):
- BLoCs for state management
- Screens (page-level widgets)
- Reusable widgets

```dart
// lib/presentation/blocs/item/item_bloc.dart
class ItemBloc extends Bloc<ItemEvent, ItemState> { ... }
```

### BLoC Pattern

**Event Definition**:
```dart
// lib/presentation/blocs/item/item_event.dart
abstract class ItemEvent extends Equatable {
  const ItemEvent();
  @override
  List<Object> get props => [];
}

class GetItemsByCategory extends ItemEvent {
  final String categoryId;
  final int offset;
  final int limit;

  const GetItemsByCategory({
    required this.categoryId,
    this.offset = 0,
    this.limit = 50,
  });

  @override
  List<Object> get props => [categoryId, offset, limit];
}
```

**State Definition**:
```dart
// lib/presentation/blocs/item/item_state.dart
abstract class ItemState extends Equatable {
  const ItemState();
  @override
  List<Object> get props => [];
}

class ItemLoaded extends ItemState {
  final List<ItemEntity> items;
  const ItemLoaded({required this.items});
  @override
  List<Object> get props => [items];
}
```

**BLoC Implementation**:
```dart
class ItemBloc extends Bloc<ItemEvent, ItemState> {
  final GetItemsByCategory _getItemsByCategory;

  ItemBloc(this._getItemsByCategory) : super(const ItemInitial()) {
    on<GetItemsByCategory>(_onGetItemsByCategory);
  }

  Future<void> _onGetItemsByCategory(
    GetItemsByCategory event,
    Emitter<ItemState> emit,
  ) async {
    // Implementation
  }
}
```

### Extension Methods for Mapping
- Use extensions for type conversion between layers
- Naming: `[Source]To[Target]Mapper` or `[Type]Mapper`

```dart
// lib/data/models/item_model.dart
extension ItemModelMapper on Item {
  ItemEntity toEntity() => ItemEntity(...);
}

extension ItemTypeExtension on ItemType {
  String toDbString() { ... }
}
```

## Error Handling

### Try-Catch Pattern
- Wrap external calls in try-catch
- Emit error states in BLoCs
- Return error messages as strings

```dart
try {
  emit(const CategoryLoading());
  final categories = await categoryRepository.getCategories();
  emit(CategoryLoaded(categories: categories));
} catch (e) {
  emit(CategoryError(message: e.toString()));
}
```

### Input Validation
- Validate in BLoC before calling repository
- Emit error state for validation failures

```dart
if (event.name.isEmpty) {
  emit(CategoryError(message: 'Название категории обязательно'));
  return;
}
```

## Dependency Injection

### get_it Pattern
- Singleton for databases and data sources
- Lazy singleton for repositories
- Factory for use cases
- Lazy singleton for BLoCs

```dart
// lib/core/di/injection.dart
final getIt = GetIt.instance;

getIt.registerSingleton<AppDatabase>(db);
getIt.registerLazySingleton<CategoryRepository>(
    () => CategoryRepositoryImpl(getIt<LocalDataSource>()));
getIt.registerFactory(() => GetCategories(getIt<CategoryRepository>()));
getIt.registerLazySingleton<CategoryBloc>(() => CategoryBloc(...));
```

### Import Alias for Namespace Conflicts
- Use `as` to disambiguate same-named classes

```dart
import '../../domain/usecases/categories/add_category.dart' as cat_uc;
import '../../domain/usecases/categories/update_category.dart' as cat_uc;

getIt.registerFactory(() => cat_uc.AddCategory(getIt<CategoryRepository>()));
```

## Documentation

### Doc Comments
- Use `///` for public API documentation
- Russian language used for internal widget documentation
- English for public interfaces

```dart
/// Карточка элемента с постером и информацией.
class ItemCard extends StatelessWidget { ... }
```

### Comments
- Inline comments in Russian for business logic
- Minimal comments, prefer self-documenting code

```dart
// Применяем пагинацию
final start = offset + 1;
```

## Enums

- Define related to entities
- Use extension methods for serialization

```dart
// lib/domain/entities/item.dart
enum ItemType { movie, tvShow, episode }

// Extension for database serialization
extension ItemTypeExtension on ItemType {
  String toDbString() { ... }
}
```

## Database (Drift)

### Table Definition
- Use `*Table` suffix for clarity (though not in class name)
- Drift DSL for column definitions

```dart
// lib/data/database/tables/items_table.dart
class Items extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get categoryId => integer().references(Categories, #id)();
  TextColumn get title => text()();
  // ...
}
```

### DAO Pattern
- Use Drift's `@DriftAccessor`
- Part directive for generated code

```dart
// lib/data/database/daos/items_dao.dart
part 'items_dao.g.dart';

@DriftAccessor(tables: [Items])
class ItemsDao extends DatabaseAccessor<AppDatabase> with _$ItemsDaoMixin {
  ItemsDao(super.db);
  // ...
}
```

## Widgets

### StatelessWidget Pattern
- Use `const` constructor when possible
- Required parameters marked with `required`
- Key parameter passed to super

```dart
class ItemCard extends StatelessWidget {
  final ItemEntity item;
  final VoidCallback onTap;

  const ItemCard({super.key, required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) { ... }
}
```

### StatefulWidget Pattern
- Separate State class
- Use `widget` to access widget properties from state

```dart
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> { ... }
```

## Type Safety

### Null Safety
- Dart 3.x null safety enabled
- Prefer non-nullable with defaults
- Use `?` for truly optional fields

```dart
final String title;              // Required
final String? description;       // Optional
final ItemType itemType;         // Required with default
```

### Generics
- Use explicit generic types
- Equatable for value equality in entities and states

```dart
class ItemBloc extends Bloc<ItemEvent, ItemState> { ... }

class ItemEntity extends Equatable { ... }
```

---

*Convention analysis: 2026-04-19*
