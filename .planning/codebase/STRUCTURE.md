# Codebase Structure

**Analysis Date:** 2025-04-19

## Directory Layout

```
pc_media_center/
├── android/                   # Android platform configuration
├── assets/                    # Static assets (images, icons)
├── build/                     # Build output (gitignored)
├── ios/                       # iOS platform configuration
├── lib/                       # Main Dart source code
├── linux/                     # Linux platform configuration
├── macos/                     # macOS platform configuration
├── test/                      # Test files
├── windows/                   # Windows platform configuration
├── .gitignore                 # Git ignore rules
├── analysis_options.yaml      # Dart analyzer configuration
├── l10n.yaml                  # Localization configuration
├── pubspec.lock               # Dependency lock file
└── pubspec.yaml               # Project dependencies and metadata
```

## Source Code Organization (`lib/`)

```
lib/
├── main.dart                  # Application entry point
├── app/                       # App-level configuration
│   ├── app.dart              # Root MaterialApp widget
│   ├── router.dart           # GoRouter route definitions
│   └── theme/                # Theme definitions
│       ├── app_theme.dart    # Theme factory
│       ├── dark_theme.dart   # Dark mode theme
│       └── light_theme.dart  # Light mode theme
├── core/                      # Core utilities and DI
│   └── di/
│       └── injection.dart    # GetIt dependency injection setup
├── data/                      # Data layer
│   ├── database/             # Database (Drift ORM)
│   │   ├── app_database.dart           # Database class
│   │   ├── app_database.g.dart         # Generated code
│   │   ├── daos/             # Data Access Objects
│   │   │   ├── categories_dao.dart
│   │   │   ├── categories_dao.g.dart
│   │   │   ├── items_dao.dart
│   │   │   └── items_dao.g.dart
│   │   └── tables/           # Database table definitions
│   │       ├── categories_table.dart
│   │       ├── items_table.dart
│   │       └── settings_table.dart
│   ├── datasources/          # Data sources
│   │   ├── local/            # Local data sources
│   │   │   └── local_data_source.dart
│   │   └── remote/           # Remote API clients
│   │       ├── kinopoisk_api.dart
│   │       ├── metadata_search_api.dart
│   │       └── tmdb_api.dart
│   ├── models/               # Data transfer objects
│   │   ├── category_model.dart
│   │   └── item_model.dart
│   └── repositories/         # Repository implementations
│       ├── category_repository_impl.dart
│       ├── item_repository_impl.dart
│       └── search_repository_impl.dart
├── domain/                    # Domain layer (business logic)
│   ├── entities/             # Business entities
│   │   ├── category.dart
│   │   ├── item.dart
│   │   └── search_result.dart
│   ├── repositories/         # Repository interfaces
│   │   ├── category_repository.dart
│   │   ├── item_repository.dart
│   │   └── search_repository.dart
│   └── usecases/             # Use cases (business operations)
│       ├── categories/
│       │   ├── add_category.dart
│       │   ├── delete_category.dart
│       │   ├── get_categories.dart
│       │   └── update_category.dart
│       └── items/
│           ├── add_item.dart
│           ├── delete_item.dart
│           ├── get_items_by_category.dart
│           ├── search_items.dart
│           └── update_item.dart
├── l10n/                      # Localization
│   └── generated/            # Generated localization files
│       ├── app_localizations.dart
│       ├── app_localizations_en.dart
│       └── app_localizations_ru.dart
└── presentation/              # Presentation layer (UI)
    ├── blocs/                # BLoC state management
    │   ├── category/
    │   │   ├── category_bloc.dart
    │   │   ├── category_event.dart
    │   │   └── category_state.dart
    │   └── item/
    │       ├── item_bloc.dart
    │       ├── item_event.dart
    │       └── item_state.dart
    ├── screens/              # Screen widgets
    │   ├── category/
    │   │   └── category_screen.dart
    │   ├── home/
    │   │   └── home_screen.dart
    │   ├── item_detail/
    │   │   └── item_detail_screen.dart
    │   ├── item_form/
    │   │   └── item_form_screen.dart
    │   ├── search/
    │   │   └── search_screen.dart
    │   └── settings/
    │       └── settings_screen.dart
    └── widgets/              # Reusable widgets
        └── common/
            ├── category_card.dart
            └── item_card.dart
```

## Directory Purposes

### `android/` `ios/` `linux/` `macos/` `windows/`
**Purpose:** Platform-specific configuration and native code
**Contains:** Build configurations, native plugins, platform manifests
**Generated:** Yes (via Flutter create)
**Committed:** Yes (required for building)

### `assets/`
**Purpose:** Static resources bundled with the app
**Contains:**
- `icons/` - Application icons
- `images/` - Static images used in UI
**Generated:** No
**Committed:** Yes

### `lib/`
**Purpose:** Main Dart source code
**Contains:** All application logic, UI, and business rules
**Key Files:**
- `main.dart` - Entry point, initializes DI and runs app

### `lib/app/`
**Purpose:** Application-level configuration
**Contains:**
- Root widget configuration
- Navigation routing setup
- Theme definitions

### `lib/core/`
**Purpose:** Cross-cutting concerns and shared utilities
**Contains:**
- Dependency injection setup
- Utility functions
- Constants

### `lib/data/`
**Purpose:** Data layer implementation
**Contains:**
- Database configuration and tables
- Data access objects (DAOs)
- Data sources (local and remote)
- Repository implementations
- Data models

### `lib/domain/`
**Purpose:** Domain layer - business logic independent of frameworks
**Contains:**
- Entities (business objects)
- Repository interfaces (contracts)
- Use cases (business operations)

### `lib/l10n/`
**Purpose:** Internationalization and localization
**Contains:**
- Generated localization classes
**Generated:** Yes (via Flutter gen-l10n)
**Committed:** Yes

### `lib/presentation/`
**Purpose:** UI layer
**Contains:**
- BLoC components (state management)
- Screens (page-level widgets)
- Reusable widgets

### `test/`
**Purpose:** Test files
**Contains:**
- Unit tests
- Widget tests
- Integration tests

### `build/` `coverage/` `.dart_tool/` `.pub/`
**Purpose:** Generated build artifacts
**Generated:** Yes (via build_runner, flutter build)
**Committed:** No (gitignored)

## Key File Locations

### Entry Points
- `lib/main.dart` - Application entry point

### Configuration
- `pubspec.yaml` - Dependencies, assets, app metadata
- `analysis_options.yaml` - Dart linter rules
- `l10n.yaml` - Localization configuration
- `.gitignore` - Git ignore patterns

### App Configuration
- `lib/app/app.dart` - Root App widget
- `lib/app/router.dart` - Navigation routes
- `lib/core/di/injection.dart` - Dependency injection

### Database
- `lib/data/database/app_database.dart` - Main database class
- `lib/data/database/tables/*.dart` - Table schemas
- `lib/data/database/daos/*.dart` - Data access objects

### Entities (Domain)
- `lib/domain/entities/item.dart` - Item entity
- `lib/domain/entities/category.dart` - Category entity

### Repositories
- Interfaces: `lib/domain/repositories/*.dart`
- Implementations: `lib/data/repositories/*.dart`

### Use Cases
- `lib/domain/usecases/categories/*.dart`
- `lib/domain/usecases/items/*.dart`

### BLoCs
- `lib/presentation/blocs/category/*.dart`
- `lib/presentation/blocs/item/*.dart`

### Screens
- `lib/presentation/screens/home/home_screen.dart`
- `lib/presentation/screens/category/category_screen.dart`
- `lib/presentation/screens/item_detail/item_detail_screen.dart`
- `lib/presentation/screens/item_form/item_form_screen.dart`
- `lib/presentation/screens/search/search_screen.dart`
- `lib/presentation/screens/settings/settings_screen.dart`

### Tests
- `test/widget_test.dart` - Default widget test

## Naming Conventions

### Files
- **Dart files:** lowercase_with_underscores.dart
- **Generated files:** *.g.dart (Drift), *.freezed.dart (not used)
- **Test files:** *_test.dart or test_*.dart

### Classes
- **Entities:** PascalCase (e.g., `ItemEntity`, `Category`)
- **Repositories:** PascalCase with Repository suffix (e.g., `ItemRepository`, `ItemRepositoryImpl`)
- **Use Cases:** PascalCase with descriptive names (e.g., `GetItemsByCategory`, `AddItem`)
- **BLoCs:** PascalCase with Bloc suffix (e.g., `ItemBloc`, `CategoryBloc`)
- **States/Events:** PascalCase with State/Event suffix (e.g., `ItemLoaded`, `AddItemEvent`)
- **Screens:** PascalCase with Screen suffix (e.g., `HomeScreen`, `CategoryScreen`)
- **Widgets:** PascalCase (e.g., `CategoryCard`, `ItemCard`)

### Directories
- **Lowercase with underscores:** `lib/domain/usecases/`, `lib/presentation/blocs/`

## Where to Add New Code

### New Feature (e.g., Tag Support)
**Domain:**
- Entity: `lib/domain/entities/tag.dart`
- Repository Interface: `lib/domain/repositories/tag_repository.dart`

**Domain (Use Cases):**
- `lib/domain/usecases/tags/add_tag.dart`
- `lib/domain/usecases/tags/get_tags.dart`
- `lib/domain/usecases/tags/delete_tag.dart`

**Data:**
- Table: `lib/data/database/tables/tags_table.dart`
- DAO: `lib/data/database/daos/tags_dao.dart`
- Model: `lib/data/models/tag_model.dart`
- Repository: `lib/data/repositories/tag_repository_impl.dart`

**Presentation:**
- BLoC: `lib/presentation/blocs/tag/tag_bloc.dart`
- Screen: `lib/presentation/screens/tags/tag_management_screen.dart`
- Widget: `lib/presentation/widgets/common/tag_chip.dart`

**DI:**
- Register in `lib/core/di/injection.dart`

**Routes:**
- Add to `lib/app/router.dart`

### New Screen
1. Create directory: `lib/presentation/screens/feature_name/`
2. Create file: `feature_screen.dart`
3. Add route in `lib/app/router.dart`
4. Create BLoC if needed: `lib/presentation/blocs/feature/`

### New Repository
1. Create interface: `lib/domain/repositories/feature_repository.dart`
2. Create implementation: `lib/data/repositories/feature_repository_impl.dart`
3. Register in DI: `lib/core/di/injection.dart`

### New Database Table
1. Create table: `lib/data/database/tables/feature_table.dart`
2. Create DAO: `lib/data/database/daos/feature_dao.dart`
3. Register in `AppDatabase` in `lib/data/database/app_database.dart`
4. Run: `flutter pub run build_runner build`

### New API Client
1. Create file: `lib/data/datasources/remote/feature_api.dart`
2. Implement using Dio for HTTP requests
3. Register in DI if needed

## Special Directories

### Generated Files
**Location:** Various (`.g.dart` suffix)
**Purpose:** Code generated by build_runner
**Tools:** Drift (database), json_serializable (JSON)
**Regenerate:** `flutter pub run build_runner build` or `watch`
**Committed:** Yes (for Drift tables, localization)

### Build Output
**Location:** `build/`, `.dart_tool/`, `.pub/`
**Purpose:** Compilation output, cached dependencies
**Generated:** Yes
**Committed:** No (gitignored)

### Platform Directories
**Location:** `android/`, `ios/`, `linux/`, `macos/`, `windows/`
**Purpose:** Native platform code and configuration
**Generated:** Yes (via Flutter tooling)
**Committed:** Yes (with modifications as needed)

### Assets
**Location:** `assets/`
**Purpose:** Static files bundled with app
**Registration:** Listed in `pubspec.yaml` under `flutter: assets:`
**Usage:** `AssetImage('assets/images/logo.png')`

---

*Structure analysis: 2025-04-19*
