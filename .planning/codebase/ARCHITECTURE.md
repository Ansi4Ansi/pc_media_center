# Architecture

**Analysis Date:** 2025-04-19

## Pattern Overview

**Overall:** Clean Architecture + BLoC Pattern

**Key Characteristics:**
- Layered architecture with clear separation of concerns
- Domain-driven design with entities, use cases, and repositories
- Unidirectional data flow using BLoC state management
- Dependency injection via service locator pattern (GetIt)
- Repository pattern for data access abstraction

## Layers

### Presentation Layer
**Purpose:** UI rendering and user interaction handling
**Location:** `lib/presentation/`
**Contains:**
- Screens (Flutter widgets representing full pages)
- Widgets (reusable UI components)
- BLoC components (business logic components managing state)

**Responsibilities:**
- Render UI based on state
- Handle user events and dispatch to BLoCs
- Display loading, error, and success states

**Depends on:** Domain layer (entities, use cases)
**Used by:** Framework (Flutter runApp)

**Key Files:**
- `lib/presentation/screens/home/home_screen.dart` - Main dashboard
- `lib/presentation/blocs/category/category_bloc.dart` - Category state management
- `lib/presentation/blocs/item/item_bloc.dart` - Item state management
- `lib/presentation/widgets/common/category_card.dart` - Reusable category widget
- `lib/presentation/widgets/common/item_card.dart` - Reusable item widget

### Domain Layer
**Purpose:** Core business logic, independent of frameworks
**Location:** `lib/domain/`
**Contains:**
- Entities (business objects with identity)
- Repository interfaces (contracts for data access)
- Use cases (application-specific business rules)

**Responsibilities:**
- Define business entities and their behavior
- Specify repository contracts (what operations are available)
- Orchestrate business operations via use cases
- Pure Dart, no Flutter dependencies

**Depends on:** Nothing (innermost layer)
**Used by:** Data layer, Presentation layer

**Key Files:**
- `lib/domain/entities/item.dart` - Item entity with properties
- `lib/domain/entities/category.dart` - Category entity
- `lib/domain/repositories/item_repository.dart` - Item repository interface
- `lib/domain/repositories/category_repository.dart` - Category repository interface
- `lib/domain/usecases/items/get_items_by_category.dart` - Pagination use case
- `lib/domain/usecases/items/add_item.dart` - Add item use case
- `lib/domain/usecases/categories/get_categories.dart` - Fetch categories use case

### Data Layer
**Purpose:** Data access and persistence implementation
**Location:** `lib/data/`
**Contains:**
- Repository implementations
- Data sources (local database, remote APIs)
- Data models (database row representations)
- Database configuration (Drift ORM)

**Responsibilities:**
- Implement repository interfaces
- Manage local persistence (SQLite via Drift)
- Handle remote API calls (TMDB, Kinopoisk)
- Map between database models and domain entities

**Depends on:** Domain layer
**Used by:** Domain layer (via repository interfaces), Dependency Injection

**Key Files:**
- `lib/data/repositories/item_repository_impl.dart` - Item repository implementation
- `lib/data/repositories/category_repository_impl.dart` - Category repository implementation
- `lib/data/database/app_database.dart` - Drift database configuration
- `lib/data/database/tables/items_table.dart` - Item database schema
- `lib/data/database/tables/categories_table.dart` - Category database schema
- `lib/data/datasources/local/local_data_source.dart` - Local data operations
- `lib/data/datasources/remote/tmdb_api.dart` - TMDB API client
- `lib/data/datasources/remote/kinopoisk_api.dart` - Kinopoisk API client

### App Layer
**Purpose:** Application configuration and composition root
**Location:** `lib/app/`
**Contains:**
- App widget configuration
- Router/navigation setup
- Theme definitions

**Responsibilities:**
- Configure MaterialApp
- Set up routing (go_router)
- Define app themes

**Key Files:**
- `lib/app/app.dart` - Root App widget
- `lib/app/router.dart` - GoRouter configuration
- `lib/app/theme/app_theme.dart` - Theme factory
- `lib/app/theme/light_theme.dart` - Light theme definition
- `lib/app/theme/dark_theme.dart` - Dark theme definition

### Core Layer
**Purpose:** Cross-cutting concerns and infrastructure
**Location:** `lib/core/`
**Contains:**
- Dependency injection configuration
- Utility classes
- Constants

**Key Files:**
- `lib/core/di/injection.dart` - GetIt service locator setup

### Localization Layer
**Purpose:** Internationalization support
**Location:** `lib/l10n/`
**Contains:**
- ARB translation files
- Generated localization classes

**Key Files:**
- `lib/l10n/generated/app_localizations.dart` - Generated localization
- `lib/l10n/generated/app_localizations_ru.dart` - Russian translations
- `lib/l10n/generated/app_localizations_en.dart` - English translations

## Data Flow

### Item Fetch Flow:
1. **UI triggers:** `BlocProvider` creates `ItemBloc` on screen init
2. **Event dispatch:** Screen dispatches `GetItemsByCategory` event with pagination params
3. **BLoC processes:** `ItemBloc` calls `GetItemsByCategory` use case
4. **Use case executes:** Applies pagination logic and calls `ItemRepository`
5. **Repository fetches:** `ItemRepositoryImpl` delegates to `LocalDataSource`
6. **DAO queries:** `ItemsDao` executes SQL query via Drift
7. **Mapping:** Results mapped from `Item` (DB model) to `ItemEntity` (domain)
8. **State emission:** BLoC emits `ItemLoaded` state with entities
9. **UI rebuild:** `BlocBuilder` receives state and renders items

### Category CRUD Flow:
1. **User action:** User clicks "Add Category" → dialog shown
2. **Event dispatch:** `AddCategoryEvent` dispatched to `CategoryBloc`
3. **Validation:** BLoC validates input (non-empty check)
4. **Repository call:** `CategoryRepository.addCategory()` called
5. **Persistence:** `LocalDataSource.insertCategory()` executes INSERT
6. **State update:** BLoC emits `CategoryLoaded` with updated list
7. **UI refresh:** ListView rebuilds with new category

### External API Flow (Metadata Search):
1. **Trigger:** User searches for movie metadata
2. **API call:** `TMDbApiClient` makes HTTP GET request via Dio
3. **Caching:** Response cached via `LocalDataSource.cache()`
4. **Error handling:** Errors caught and wrapped in exceptions
5. **UI feedback:** Results displayed or error shown

## State Management

**Approach:** BLoC (Business Logic Component) Pattern

**Implementation:** flutter_bloc package

**BLoCs:**
- `CategoryBloc` - Manages category list state
  - States: `CategoryInitial`, `CategoryLoading`, `CategoryLoaded`, `CategoryError`
  - Events: `LoadCategories`, `AddCategoryEvent`, `UpdateCategoryEvent`, `DeleteCategoryEvent`
  - Singleton registered in DI

- `ItemBloc` - Manages item list within category
  - States: `ItemInitial`, `ItemLoading`, `ItemLoaded`, `ItemEmpty`, `ItemError`
  - Events: `GetItemsByCategory`, `AddItem`, `UpdateItem`, `DeleteItem`
  - Supports pagination (offset/limit)

**State Characteristics:**
- Immutable (extends Equatable)
- Serializable where needed
- Clear state transitions

## Service Layer Organization

**Dependency Injection:** GetIt (service locator pattern)

**Registration Pattern:**
- Singletons: `AppDatabase`, `LocalDataSource`, `CategoryBloc`
- Lazy Singletons: Repositories (created on first access)
- Factories: Use cases (new instance per injection)

**Organization in `injection.dart`:**
```dart
// Database layer
final db = AppDatabase();
getIt.registerSingleton<AppDatabase>(db);

// Data sources
getIt.registerSingleton<LocalDataSource>(localDataSource);

// Repositories
getIt.registerLazySingleton<CategoryRepository>(() => CategoryRepositoryImpl(...));

// Use cases
getIt.registerFactory(() => GetCategories(getIt<CategoryRepository>()));

// BLoCs
getIt.registerLazySingleton<CategoryBloc>(() => CategoryBloc(getIt<CategoryRepository>()));
```

## Module Boundaries and Responsibilities

### Categories Module
**Responsibilities:**
- CRUD operations for categories
- Category list display
- Category settings (movie type, scan paths, file extensions)

**Files:**
- Domain: `lib/domain/entities/category.dart`, `lib/domain/repositories/category_repository.dart`
- Use Cases: `lib/domain/usecases/categories/*.dart`
- Data: `lib/data/repositories/category_repository_impl.dart`
- BLoC: `lib/presentation/blocs/category/*.dart`
- UI: `lib/presentation/screens/category/category_screen.dart`

### Items Module
**Responsibilities:**
- Item management within categories
- Item search and filtering
- Launch functionality
- Metadata association

**Files:**
- Domain: `lib/domain/entities/item.dart`, `lib/domain/repositories/item_repository.dart`
- Use Cases: `lib/domain/usecases/items/*.dart`
- Data: `lib/data/repositories/item_repository_impl.dart`
- BLoC: `lib/presentation/blocs/item/*.dart`
- UI: `lib/presentation/screens/item_detail/item_detail_screen.dart`, `lib/presentation/screens/item_form/item_form_screen.dart`

### Search Module
**Responsibilities:**
- Global item search
- Category-scoped search
- Metadata search (TMDb/Kinopoisk integration)

**Files:**
- Use Cases: `lib/domain/usecases/items/search_items.dart`
- Remote: `lib/data/datasources/remote/tmdb_api.dart`, `lib/data/datasources/remote/kinopoisk_api.dart`
- UI: `lib/presentation/screens/search/search_screen.dart`

### Settings Module
**Responsibilities:**
- App configuration persistence
- User preferences
- API key management

**Files:**
- Database: `lib/data/database/tables/settings_table.dart`
- UI: `lib/presentation/screens/settings/settings_screen.dart`

## Entry Points

### Application Entry Point
**Location:** `lib/main.dart`
**Triggers:** OS launches application
**Responsibilities:**
- Initialize Flutter binding
- Configure dependencies (DI container)
- Run root App widget

### Navigation Entry Points
**Configured in:** `lib/app/router.dart`

**Routes:**
- `/` → HomeScreen (category list)
- `/category/:id` → CategoryScreen (items in category)
- `/item/:id` → ItemDetailScreen
- `/item/new` → ItemFormScreen (create)
- `/item/:id/edit` → ItemFormScreen (edit)
- `/search?q=` → SearchScreen
- `/settings` → SettingsScreen

**Router:** GoRouter with declarative route configuration

## Error Handling

**Strategy:** Layered error handling with graceful degradation

**Patterns:**
- Repository layer catches exceptions, maps to domain exceptions
- BLoC layer catches errors, emits error states
- UI layer displays error messages based on state
- Try-catch blocks at async boundaries

**Error Flow:**
1. Exception thrown in data layer (e.g., database error)
2. Repository catches and potentially re-throws
3. BLoC catches, emits Error state with message
4. UI displays error widget or snackbar

## Cross-Cutting Concerns

**Logging:** Basic error logging via Flutter debugPrint (avoid_print disabled)

**Validation:** Input validation in BLoCs before repository calls

**Authentication:** Not implemented (local desktop app)

**Caching:**
- Images: `cached_network_image` for remote posters
- API responses: Local cache in `LocalDataSource`
- Database: Drift manages connection pooling

**Database Access:**
- Pattern: DAO (Data Access Object)
- Implementation: Drift ORM with generated code
- Tables: Categories, Items, Settings
- Location: `lib/data/database/`

**Pagination:**
- Implemented in use cases (`get_items_by_category.dart`)
- Offset-based pagination (offset, limit parameters)
- In-memory slicing of full results

---

*Architecture analysis: 2025-04-19*
