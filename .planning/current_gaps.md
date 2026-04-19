# PC Media Center - Current Gaps Analysis

**Date:** 2026-04-19  
**Analysis:** Comparison of DEVELOPMENT_PLAN.md vs Current Codebase State

---

## Executive Summary

| Phase | Status | Completion | Critical Gaps |
|-------|--------|------------|---------------|
| Phase 0: Initialization | ✅ Complete | 100% | None |
| Phase 1: Database & Data Layer | ✅ Complete | 95% | Minor: Settings repository not exposed |
| Phase 2: Home & Categories | 🟡 Partial | 70% | Edit category, default categories, navigation |
| Phase 3: Items & Cards | 🟡 Partial | 50% | Item detail, local search, launch functionality |
| Phase 4: Forms & Scanning | 🔴 Missing | 10% | All major features: form, picker, scanner |
| Phase 5: Metadata Search | 🟡 Partial | 30% | API clients exist, no UI or SearchBloc |
| Phase 6: Online Search | 🔴 Missing | 0% | Not started |
| Phase 7: Launcher & Icons | 🔴 Missing | 0% | Not started |
| Phase 8: Input System | 🔴 Missing | 0% | Not started |
| Phase 9: Voice Input | 🔴 Missing | 0% | Not started |
| Phase 10: Settings | 🔴 Missing | 20% | Screen stub only |
| Phase 11: Testing | 🟡 Partial | 40% | Unit tests exist, no integration tests |

**Overall Progress:** ~45% of planned features implemented

---

## Detailed Gap Analysis by Phase

### Phase 0: Initialization ✅ COMPLETE

**Status:** All tasks completed

**Implemented:**
- [x] Flutter project created for Windows/Linux/macOS
- [x] pubspec.yaml with all dependencies
- [x] Directory structure (lib/, assets/)
- [x] get_it + injectable DI configuration
- [x] go_router with routes
- [x] Dark/light themes
- [x] i18n (ARB files, Russian/English)
- [x] MaterialApp.router in app.dart
- [x] Fullscreen main.dart

**Gaps:** None

---

### Phase 1: Database & Data Layer ✅ COMPLETE (95%)

**Status:** Core infrastructure complete, minor gaps in settings

**Implemented:**
- [x] Drift tables (categories, items, settings)
- [x] AppDatabase with DAOs
- [x] Domain entities (Category, Item, SearchResult)
- [x] Data models with mapping
- [x] Repository interfaces
- [x] LocalDataSource
- [x] CategoryRepositoryImpl
- [x] ItemRepositoryImpl
- [x] All Use Cases for categories and items
- [x] DI registration
- [x] Code generation (build_runner)

**Gaps:**
- [ ] SettingsRepository not implemented (only table exists)
- [ ] Settings read/write only through AppDatabase helpers
- [ ] No migration strategy beyond basic onCreate

**Impact:** Low - settings can be accessed directly via database

---

### Phase 2: Home Screen & Categories 🟡 PARTIAL (70%)

**Status:** Basic functionality works, missing edit and defaults

**Implemented:**
- [x] CategoryBloc (Load, Add, Delete, Update events)
- [x] HomeScreen with category list
- [x] CategoryCard widget
- [x] Add category dialog (fixed)
- [x] Delete category functionality
- [x] Navigation to category screen

**Gaps:**
- [ ] **Edit category** - onEdit callback is empty in HomeScreen
- [ ] **Default categories** - No Movies, Games, Programs created on first launch
- [ ] **Category type** - No distinction between movie/program/game categories
- [ ] **Category settings** - scan_paths and file_extensions not exposed in UI
- [ ] **Category rename** - No UI for renaming existing categories

**Files to modify:**
- `lib/presentation/screens/home/home_screen.dart` - Add edit dialog
- `lib/presentation/blocs/category/category_bloc.dart` - Verify update works
- `lib/main.dart` or `app.dart` - Seed default categories on first launch

**Impact:** Medium - users can't edit categories or have default setup

---

### Phase 3: Items List & Detail 🟡 PARTIAL (50%)

**Status:** Category screen works, detail is stub, no search

**Implemented:**
- [x] ItemBloc (GetItems, Add, Update, Delete events)
- [x] CategoryScreen with lazy loading grid
- [x] ItemCard widget with poster and index
- [x] Basic navigation to ItemDetailScreen
- [x] Pagination (load more button)

**Gaps:**
- [ ] **ItemDetailScreen** - Only stub implemented (shows "stub" text)
  - Missing: full UI with poster, description, metadata
  - Missing: "Launch" button
  - Missing: "Edit" button
  - Missing: file info display
  
- [ ] **Local search** - No search bar in CategoryScreen
  - Missing: Search within category
  - Missing: Filter by name
  
- [ ] **Item launch** - No integration with OS launcher
  - Missing: Open file/program
  - Missing: Error handling for missing files

**Files to create/modify:**
- `lib/presentation/screens/item_detail/item_detail_screen.dart` - Full implementation
- `lib/presentation/screens/category/category_screen.dart` - Add search bar
- `lib/core/services/launcher_service.dart` - Create new

**Impact:** High - core functionality (viewing details, launching) missing

---

### Phase 4: Forms & Directory Scanning 🔴 MISSING (10%)

**Status:** Only stub screens exist, no actual functionality

**Implemented:**
- [x] ItemFormScreen stub (empty)
- [x] Data structures exist for items

**Gaps - ALL MAJOR FEATURES MISSING:**
- [ ] **ItemFormScreen** - Full form with fields:
  - Title, description, year
  - File path selection (file picker)
  - Poster selection/upload
  - Category selection
  - Validation
  
- [ ] **File picker integration** - No file_picker package usage
  - Missing: Select executable/media files
  - Missing: Platform-specific file dialogs
  
- [ ] **DirectoryScanner** - Not implemented
  - Missing: Scan folder for files
  - Missing: Extension filtering (.mp4, .mkv, .exe, etc.)
  - Missing: Recursive scanning
  - Missing: Batch add to category
  
- [ ] **FileMetadataExtractor** - Not implemented
  - Missing: Parse filename for title/year
  - Missing: ffprobe integration for video metadata
  - Missing: ID3 tag reading for audio
  - Missing: Auto-fill form fields
  
- [ ] **Category scan paths** - UI not connected
  - Missing: Configure scan_paths per category
  - Missing: Configure file_extensions per category
  - Missing: Re-scan button

**Files to create:**
- `lib/core/services/directory_scanner.dart`
- `lib/core/services/file_metadata_extractor.dart`
- `lib/presentation/screens/item_form/item_form_screen.dart` - Full rewrite
- `lib/presentation/widgets/file_picker_button.dart`

**Dependencies to add:**
- `file_picker: ^...` (not in pubspec.yaml)
- `ffprobe` or `media_info` for metadata extraction

**Impact:** Critical - can't add items manually or via scanning

---

### Phase 5: Metadata Search 🟡 PARTIAL (30%)

**Status:** API clients exist, no UI integration

**Implemented:**
- [x] TMDbApiClient with search
- [x] KinopoiskApiClient with search
- [x] MetadataSearchApi abstraction
- [x] SearchRepository with combined results
- [x] Domain exceptions for API errors

**Gaps:**
- [ ] **SearchBloc** - Not implemented
  - Missing: Events for search query
  - Missing: States for loading/results/error
  
- [ ] **Search UI** - No search in ItemFormScreen
  - Missing: "Search online" button
  - Missing: Results dialog/screen
  - Missing: Result selection → auto-fill
  
- [ ] **Poster caching** - Not implemented
  - Missing: Download poster to local storage
  - Missing: Cache management
  
- [ ] **API Key settings** - No UI
  - Missing: TMDB API key input
  - Missing: Kinopoisk API key input
  - Missing: Key validation

**Files to create:**
- `lib/presentation/blocs/search/search_bloc.dart`
- `lib/presentation/widgets/search_metadata_dialog.dart`
- `lib/core/services/poster_cache_service.dart`

**Impact:** High - users can't enrich items with online metadata

---

### Phase 6: Online Movie Search 🔴 MISSING (0%)

**Status:** Not started

**Gaps - ALL MISSING:**
- [ ] **CategoryScreen search bar** for online search
- [ ] **is_movie_type flag** on category
- [ ] **Combined results** (local + online)
- [ ] **Add from search** - Convert online result to local item
- [ ] **Pagination** for online results

**Impact:** Medium - only affects movie categories

---

### Phase 7: Launcher & Icon Extraction 🔴 MISSING (0%)

**Status:** Not started

**Gaps - ALL MISSING:**
- [ ] **LauncherService** - Cross-platform file launching
  - Windows: `start` command
  - Linux: `xdg-open`
  - macOS: `open`
  
- [ ] **Error handling** for launch failures
- [ ] **Launch arguments** support for programs/games
- [ ] **IconExtractor** - Extract app icons
  - Windows: ExtractIcon/SHGetFileInfo (FFI)
  - macOS: sips/MethodChannel
  - Linux: .desktop parsing
  
- [ ] **Auto-extract** icon on add

**Files to create:**
- `lib/core/services/launcher_service.dart`
- `lib/core/services/icon_extractor.dart`
- FFI bindings for Windows icon extraction

**Impact:** Critical - can't launch items (main app purpose)

---

### Phase 8: Input System 🔴 MISSING (0%)

**Status:** Not started

**Gaps - ALL MISSING:**
- [ ] **FocusableWidget** - Focus management wrapper
- [ ] **InputHandler** - Gamepad/remote mapping
- [ ] **Keyboard shortcuts** - Shortcuts + Actions
- [ ] **Focus highlighting** - Visual indicators
- [ ] **Auto-focus** - Focus on navigation

**Files to create:**
- `lib/presentation/widgets/common/focusable_widget.dart`
- `lib/core/utils/input_handler.dart`
- Platform-specific input plugins

**Impact:** Medium - app requires mouse currently

---

### Phase 9: Voice Input 🔴 MISSING (0%)

**Status:** Not started, dependency not in pubspec

**Gaps - ALL MISSING:**
- [ ] **vosk_flutter** - Package not added
- [ ] **VoiceBloc** - Speech recognition logic
- [ ] **VoiceInputButton** - Microphone button widget
- [ ] **Language model** - Vosk model download/setup
- [ ] **Integration** - Voice → Search

**Dependencies to add:**
- `vosk_flutter: ^...`

**Impact:** Low - nice-to-have feature

---

### Phase 10: Settings 🔴 MISSING (20%)

**Status:** Only stub screen

**Implemented:**
- [x] SettingsScreen stub
- [x] Settings table in database

**Gaps:**
- [ ] **SettingsBloc** - State management for settings
- [ ] **Theme switching** - Light/dark toggle
- [ ] **Language switching** - RU/EN toggle
- [ ] **Settings persistence** - Load/save from DB
- [ ] **API Keys** - TMDB/Kinopoisk key inputs
- [ ] **About section** - Version info

**Files to create/modify:**
- `lib/presentation/blocs/settings/settings_bloc.dart` - New
- `lib/presentation/screens/settings/settings_screen.dart` - Full rewrite

**Impact:** Medium - users can't customize app

---

### Phase 11: Testing 🟡 PARTIAL (40%)

**Status:** Unit tests for BLoCs exist

**Implemented:**
- [x] BLoC unit tests (CategoryBloc, ItemBloc)
- [x] Test helpers with mocks
- [x] Widget smoke test

**Gaps:**
- [ ] **Use case tests** - No domain layer tests
- [ ] **Repository tests** - No data layer tests
- [ ] **Widget tests** - Only basic smoke test
- [ ] **Integration tests** - None
- [ ] **Golden tests** - None
- [ ] **CI/CD** - No GitHub Actions or similar

**Impact:** Low - current coverage adequate for development

---

## Critical Path for MVP

To achieve a **Minimum Viable Product**, these gaps must be closed:

### Priority 1: Critical (App won't function without)
1. **ItemFormScreen** - Must be able to add items
2. **ItemDetailScreen** - Must view item details
3. **LauncherService** - Must launch files/programs
4. **File picker** - Must select files

### Priority 2: High (Major user value)
5. **DirectoryScanner** - Batch add items
6. **SearchBloc + UI** - Metadata enrichment
7. **Edit category** - Complete CRUD
8. **Local search** - Find items in category

### Priority 3: Medium (Polish)
9. **Default categories** - Better first-time UX
10. **Settings** - Customization
11. **Poster caching** - Offline posters

### Priority 4: Low (Nice-to-have)
12. **Voice input**
13. **Input system** (gamepad)
14. **Online movie search**

---

## Recommended Next Phase

**Phase 4.5: Core Functionality Sprint**

Combine elements of Phases 3, 4, and 7 to make the app actually usable:

**Tasks:**
1. Implement ItemDetailScreen with launch button
2. Create LauncherService for cross-platform file opening
3. Implement ItemFormScreen with file picker
4. Add file_picker dependency
5. Add local search to CategoryScreen

**Success Criteria:**
- User can add an item by selecting a file
- User can view item details
- User can launch the file/program from the app
- User can search within a category

---

## Appendix: File Inventory

### Fully Implemented Files
```
lib/main.dart
lib/app/app.dart
lib/app/router.dart
lib/app/theme/
lib/core/di/injection.dart
lib/core/error/exceptions.dart
lib/data/database/
lib/data/datasources/local/
lib/data/datasources/remote/
lib/data/repositories/
lib/data/models/
lib/domain/
lib/presentation/blocs/
lib/presentation/screens/home/home_screen.dart
lib/presentation/screens/category/category_screen.dart
lib/presentation/widgets/common/
```

### Stub Files (Need Implementation)
```
lib/presentation/screens/item_detail/item_detail_screen.dart (15 lines)
lib/presentation/screens/item_form/item_form_screen.dart (16 lines)
lib/presentation/screens/search/search_screen.dart (15 lines)
lib/presentation/screens/settings/settings_screen.dart (13 lines)
```

### Missing Files
```
lib/core/services/launcher_service.dart
lib/core/services/icon_extractor.dart
lib/core/services/directory_scanner.dart
lib/core/services/file_metadata_extractor.dart
lib/core/services/poster_cache_service.dart
lib/presentation/blocs/search/search_bloc.dart
lib/presentation/blocs/settings/settings_bloc.dart
lib/presentation/widgets/search_metadata_dialog.dart
lib/presentation/widgets/file_picker_button.dart
lib/core/utils/input_handler.dart
lib/presentation/widgets/common/focusable_widget.dart
```

---

**Document Generated:** 2026-04-19  
**For:** PC Media Center Planning  
**Next Step:** Prioritize and schedule implementation of critical gaps
