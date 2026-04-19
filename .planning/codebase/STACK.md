# PC Media Center — Technology Stack

**Analysis Date:** 2026-04-19

> Technology stack inventory for the PC Media Center Flutter desktop application.

---

## Languages

**Primary:**
- **Dart** 3.10.4+ — Type-safe programming language for Flutter development
  - SDK constraint: `>=3.10.4 <4.0.0` (from `pubspec.yaml`)

---

## Runtime & Framework

**Environment:**
- **Flutter SDK** — Latest stable channel
  - Revision: `f6ff1529fd6d8af5f706051d9251ac9231c83407`
  - Channel: `stable`
  - Project type: Desktop application

**Target Platforms:**
- Windows (CMake build)
- macOS (Xcode build)
- Linux (CMake build)

**Package Manager:**
- **Pub** — Dart package manager
- Lockfile: `pubspec.lock` present

---

## Core Dependencies

### State Management

| Package | Version | Purpose |
|---------|---------|---------|
| `flutter_bloc` | ^9.1.0 | BLoC pattern implementation for predictable state management |
| `equatable` | ^2.0.7 | Value equality for events and states |
| `bloc` | ^9.2.0 (transitive) | Core BLoC library |

### Routing

| Package | Version | Purpose |
|---------|---------|---------|
| `go_router` | ^17.2.1 | Declarative routing with deep link support |

### Dependency Injection

| Package | Version | Purpose |
|---------|---------|---------|
| `get_it` | ^9.2.1 | Service locator pattern for DI |
| `injectable` | ^2.5.0 | Compile-time code generation for DI |

### Database & Persistence

| Package | Version | Purpose |
|---------|---------|---------|
| `drift` | ^2.23.1 | Type-safe SQLite ORM with compile-time query validation |
| `sqlite3_flutter_libs` | ^0.6.0+eol | Native SQLite bindings for Flutter |
| `path_provider` | ^2.1.5 | Platform-specific path resolution |
| `path` | ^1.9.1 | Path manipulation utilities |

### Networking

| Package | Version | Purpose |
|---------|---------|---------|
| `dio` | ^5.7.0 | HTTP client with interceptors and timeout handling |
| `dio_web_adapter` | ^2.1.0 (transitive) | Web adapter for Dio |
| `cached_network_image` | ^3.4.1 | Image loading with automatic caching |

### Serialization

| Package | Version | Purpose |
|---------|---------|---------|
| `json_annotation` | ^4.9.0 | JSON serialization annotations |

### Internationalization

| Package | Version | Purpose |
|---------|---------|---------|
| `flutter_localizations` | SDK | Built-in Flutter localization support |
| `intl` | any | Date/time formatting and internationalization |

---

## Development Dependencies

### Code Generation

| Package | Version | Purpose |
|---------|---------|---------|
| `build_runner` | ^2.4.14 | Runs code generators for injectable, json_serializable, drift |
| `drift_dev` | ^2.23.1 | Drift code generation for type-safe SQL |
| `injectable_generator` | ^2.7.0 | Generates DI bindings at compile time |
| `json_serializable` | ^6.9.4 | Auto-generates JSON serialization code |

### Linting & Analysis

| Package | Version | Purpose |
|---------|---------|---------|
| `flutter_lints` | ^6.0.0 | Dart/Flutter recommended lint rules |

Configuration: `analysis_options.yaml` includes `package:flutter_lints/flutter.yaml`

### Testing

| Package | Version | Purpose |
|---------|---------|---------|
| `flutter_test` | SDK | Flutter's built-in testing framework |
| `bloc_test` | ^10.0.0 | BLoC-specific unit testing utilities |
| `mocktail` | ^1.0.4 | Type-safe mocking for Dart 3+ |

---

## Build Configuration

### Code Generation Commands

```bash
# Generate all code (DI, database, serialization)
flutter pub run build_runner build

# Watch for changes and regenerate
flutter pub run build_runner watch

# Delete conflicting outputs and rebuild
flutter pub run build_runner build --delete-conflicting-outputs
```

### Internationalization

Configuration: `l10n.yaml`
- ARB directory: `lib/l10n/`
- Template: `app_en.arb`
- Output: `lib/l10n/generated/app_localizations.dart`
- Supported locales: English (`en`), Russian (`ru`)

### Platform-Specific Build Tools

**Windows:**
- CMake 3.14+
- Visual Studio 2019+ or Build Tools
- Configuration: `windows/runner/CMakeLists.txt`

**macOS:**
- Xcode 14+
- CocoaPods
- Configuration: `macos/Runner.xcodeproj/`

**Linux:**
- CMake 3.10+
- GTK development headers
- Configuration: `linux/CMakeLists.txt`

---

## Database Technology

**Engine:** SQLite 3.x (via `sqlite3_flutter_libs`)

**ORM:** Drift 2.23.1

**Storage Location:**
```
{executable_directory}/data/media_center.db
```

**Schema:**
- Tables: `Categories`, `Items`, `Settings`
- DAOs: `CategoriesDao`, `ItemsDao`
- Schema version: 1

---

## Key Architectural Decisions

1. **BLoC Pattern** — Predictable state management with event-driven architecture
2. **Drift ORM** — Type-safe SQL with compile-time validation over raw SQLite
3. **get_it + injectable** — Clean dependency injection without Flutter-specific solutions
4. **go_router** — Modern declarative routing with parameter support
5. **Offline-first** — Local SQLite database as source of truth
6. **Clean Architecture** — Domain/Data/Presentation layer separation

---

## Transitive Dependencies (Notable)

| Package | Version | Used By |
|---------|---------|---------|
| `async` | ^2.13.1 | Dart async utilities |
| `analyzer` | ^10.0.1 | Code analysis (via build_runner) |
| `source_gen` | ^1.5.0 | Code generation infrastructure |
| `meta` | ^1.12.0 | Dart metadata annotations |

---

*Stack analysis: 2026-04-19*
