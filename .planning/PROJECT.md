# PC Media Center - Project Document

## Overview
A fullscreen desktop media center application for organizing and launching apps, games, movies, and media files on Windows, Linux, and macOS.

**Architecture:** Clean Architecture + BLoC Pattern  
**Framework:** Flutter 3.41.7  
**State Management:** flutter_bloc  
**Database:** Drift (SQLite)  
**Routing:** go_router  
**DI:** get_it + injectable  

---

## Milestone History

### v0.7 - Foundation & Critical Fixes ✅ COMPLETED
**Date:** 2026-04-19

**Accomplishments:**
- Fixed all critical compilation errors (import paths, undefined variables)
- Fixed critical UI bug (dialog closing on type)
- Fixed memory leaks (stream subscription disposal, BLoC lifecycle)
- Implemented comprehensive error handling (domain exceptions, logging, Dio singleton)
- Established testing infrastructure with 16 passing tests
- Cleaned codebase with auto-linter (14 fixes applied)

**Status:** All critical issues resolved, clean build, tests passing

---

### v1.0 - Core Functionality MVP 🚧 IN PROGRESS
**Goal:** Make the app actually usable - implement minimum viable features

**Target Features:**
1. **Item Detail Screen** - View item metadata with launch button
2. **Item Form Screen** - Add/edit items with file picker
3. **Launcher Service** - Cross-platform file/program launching
4. **Directory Scanner** - Batch add items by scanning folders
5. **Local Search** - Search within categories

**Success Criteria:**
- User can add an item by selecting a file
- User can view item details and metadata
- User can launch the file/program from the app
- User can search items within a category
- User can scan a folder to batch-add items

---

## Project Structure

```
lib/
├── app/                    # App configuration
│   ├── app.dart           # MaterialApp with router
│   ├── router.dart        # go_router configuration
│   └── theme/             # Light/dark themes
├── core/                   # Core utilities
│   ├── di/                # Dependency injection
│   ├── error/             # Exception classes
│   └── services/          # Launcher, scanner, etc. (NEW)
├── data/                   # Data layer
│   ├── database/          # Drift database
│   ├── datasources/       # Local/remote data sources
│   ├── models/            # Data models
│   └── repositories/      # Repository implementations
├── domain/                 # Domain layer
│   ├── entities/          # Business entities
│   ├── repositories/      # Repository interfaces
│   └── usecases/          # Use cases
└── presentation/           # Presentation layer
    ├── blocs/             # BLoCs
    ├── screens/           # Screens
    └── widgets/           # Reusable widgets

test/                      # Test suite
├── blocs/                 # BLoC unit tests
├── helpers/               # Test helpers/mocks
└── widget_test.dart       # Widget tests
```

---

## Key Documents

- **Current Gaps:** `.planning/current_gaps.md` - Detailed gap analysis vs DEVELOPMENT_PLAN.md
- **Roadmap:** `.planning/ROADMAP.md` - Current milestone roadmap
- **Requirements:** `.planning/REQUIREMENTS.md` - Current milestone requirements
- **State:** `.planning/STATE.md` - Project state tracking
- **Architecture:** `.planning/codebase/ARCHITECTURE.md`
- **Conventions:** `.planning/codebase/CONVENTIONS.md`

---

## Development Guidelines

### Code Quality
- All code must pass `flutter analyze` with zero errors
- All tests must pass (`flutter test`)
- Use `dart fix --apply` before committing
- Follow Clean Architecture principles
- Use BLoC pattern for state management

### Testing
- Unit tests for BLoCs (using bloc_test)
- Widget tests for screens
- Mock repositories for isolation
- Run tests before committing

### Dependencies
Key dependencies managed in `pubspec.yaml`:
- flutter_bloc: State management
- drift: Database
- go_router: Navigation
- get_it + injectable: Dependency injection
- dio: HTTP client
- file_picker: File selection (NEW - to be added)

---

## Current Blockers

None - Phase 7 resolved all critical blockers.

---

## Next Milestone Goals (v1.0)

Based on gap analysis, the v1.0 milestone focuses on **Core Functionality**:

1. **Complete Item Management**
   - Full item detail view with metadata
   - Item creation/editing form
   - File picker integration

2. **Launch Capability**
   - Cross-platform file launching
   - Error handling for missing files
   - Support for launch arguments

3. **Batch Operations**
   - Directory scanning
   - Extension filtering
   - Batch item creation

4. **Search & Discovery**
   - Local search within categories
   - Basic filtering

---

## Contributing

When adding new features:
1. Check `current_gaps.md` for planned features
2. Create/update plan in `.planning/phases/`
3. Follow existing patterns in codebase
4. Add tests for new BLoCs
5. Run `flutter analyze` and `flutter test`
6. Update documentation

---

*Last Updated: 2026-04-19*
