# PC Media Center - Milestone v1.0 Requirements

**Milestone:** v1.0 - Core Functionality MVP  
**Goal:** Make the app usable for basic media center operations  
**Target Date:** TBD  

---

## Overview

This milestone implements the minimum viable features needed for PC Media Center to be usable. After completing Phase 7 (critical fixes), the codebase is stable and ready for feature development.

**Current State:**
- ✅ Database layer complete
- ✅ Category management (add/delete/list)
- ✅ Item listing with pagination
- ✅ Basic routing
- ✅ Testing infrastructure

**Target State:**
- Users can add items via file picker
- Users can view item details
- Users can launch files/programs
- Users can scan directories for batch adding
- Users can search within categories

---

## Functional Requirements

### REQ-01: Item Detail Screen
**Priority:** Critical

The ItemDetailScreen must display comprehensive item information and provide launch capability.

**Acceptance Criteria:**
- [ ] Display item poster (or placeholder if none)
- [ ] Display item title, description, year
- [ ] Display file path
- [ ] Display metadata (duration, resolution for video; artist for audio)
- [ ] **"Launch" button** that opens the file/program
- [ ] **"Edit" button** that navigates to edit form
- [ ] **"Delete" button** with confirmation dialog
- [ ] Support all item types: movie, tvShow, episode, app, game

**Files:**
- `lib/presentation/screens/item_detail/item_detail_screen.dart`

---

### REQ-02: Item Form Screen
**Priority:** Critical

The ItemFormScreen must allow users to create and edit items with file selection.

**Acceptance Criteria:**
- [ ] Form fields: Title, Description, Year, File Path, Poster URL
- [ ] **File picker button** to select executable/media file
- [ ] **File picker button** to select poster image
- [ ] Category selector (dropdown)
- [ ] Form validation (title and file path required)
- [ ] Save button creates/updates item via ItemBloc
- [ ] Cancel button returns without saving
- [ ] Pre-fill form when editing existing item

**Dependencies:**
- Add `file_picker` package to pubspec.yaml

**Files:**
- `lib/presentation/screens/item_form/item_form_screen.dart`
- `lib/presentation/widgets/file_picker_button.dart` (new)

---

### REQ-03: Launcher Service
**Priority:** Critical

Cross-platform service to open files and programs with system default handlers.

**Acceptance Criteria:**
- [ ] **Windows:** Use `Process.run('cmd', ['/c', 'start', '', path])`
- [ ] **Linux:** Use `Process.run('xdg-open', [path])`
- [ ] **macOS:** Use `Process.run('open', [path])`
- [ ] Handle file not found errors gracefully
- [ ] Handle "no application associated" errors
- [ ] Support launch arguments for programs/games
- [ ] Return success/failure status

**Files:**
- `lib/core/services/launcher_service.dart` (new)

---

### REQ-04: Directory Scanner
**Priority:** High

Service to scan directories and batch-create items from files.

**Acceptance Criteria:**
- [ ] Scan directory recursively (optional flag)
- [ ] Filter by file extensions (.mp4, .mkv, .exe, etc.)
- [ ] Extract basic metadata from filename (title, year)
- [ ] Skip files that already exist in category
- [ ] Return list of discovered items
- [ ] Progress callback for UI updates
- [ ] Cancelable operation

**Files:**
- `lib/core/services/directory_scanner.dart` (new)

---

### REQ-05: Local Search
**Priority:** High

Search functionality within category screen.

**Acceptance Criteria:**
- [ ] Search bar in CategoryScreen app bar
- [ ] Real-time filtering as user types
- [ ] Search across item titles and descriptions
- [ ] Case-insensitive search
- [ ] Clear search button
- [ ] Show "no results" message when empty
- [ ] Debounce search input (300ms)

**Files:**
- `lib/presentation/screens/category/category_screen.dart` (modify)

---

### REQ-06: Category Edit
**Priority:** Medium

Complete CRUD for categories by adding edit functionality.

**Acceptance Criteria:**
- [ ] Edit button on CategoryCard
- [ ] Edit dialog with name field
- [ ] Update category via CategoryBloc
- [ ] Handle duplicate name validation
- [ ] Refresh list after update

**Files:**
- `lib/presentation/screens/home/home_screen.dart` (modify)
- `lib/presentation/widgets/common/category_card.dart` (modify)

---

### REQ-07: Default Categories
**Priority:** Medium

Seed default categories on first app launch.

**Acceptance Criteria:**
- [ ] Create "Фильмы" (Movies) category on first run
- [ ] Create "Игры" (Games) category on first run
- [ ] Create "Программы" (Programs) category on first run
- [ ] Detect first run via settings
- [ ] Only create once

**Files:**
- `lib/main.dart` or initialization logic

---

## Non-Functional Requirements

### NFR-01: Code Quality
- All new code must pass `flutter analyze` with zero errors
- Minimum 70% test coverage for new BLoCs
- Follow existing Clean Architecture patterns

### NFR-02: Performance
- File picker must open within 500ms
- Directory scan of 1000 files must complete within 5 seconds
- Search must update UI within 100ms of input

### NFR-03: Error Handling
- All user-facing errors must show clear messages in Russian
- File operations must have try-catch with user-friendly errors
- Network operations (if any) must handle offline state

### NFR-04: Testing
- Unit tests for LauncherService
- Unit tests for DirectoryScanner
- Widget tests for ItemFormScreen
- Integration test for "add item → view → launch" flow

---

## Technical Requirements

### Dependencies
Add to `pubspec.yaml`:
```yaml
dependencies:
  file_picker: ^8.0.0+1
  
dev_dependencies:
  # Existing test dependencies sufficient
```

### Platform-Specific Requirements

**Windows:**
- No additional setup needed for Process.run

**Linux:**
- Ensure xdg-open is available (standard on most distros)

**macOS:**
- No additional setup needed for Process.run

---

## Out of Scope

The following are intentionally NOT in this milestone:
- Online metadata search (Phase 5) - will use manual entry
- Voice input (Phase 9)
- Gamepad/remote navigation (Phase 8)
- Settings screen (Phase 10) - minimal settings only
- Icon extraction from executables
- Advanced metadata extraction (ffprobe)
- Playlist management
- Social features

---

## Success Criteria

This milestone is complete when:

1. ✅ User can add a new item by selecting a file
2. ✅ User can view item details with poster and metadata
3. ✅ User can click "Launch" to open the file/program
4. ✅ User can edit an item's details
5. ✅ User can delete an item
6. ✅ User can search items within a category
7. ✅ User can scan a directory to batch-add items
8. ✅ User can edit category names
9. ✅ App creates default categories on first launch
10. ✅ All tests pass (`flutter test` exits 0)
11. ✅ No analyzer errors (`flutter analyze` clean)

---

## Dependencies Between Requirements

```
REQ-03 (Launcher)
    │
    ▼
REQ-01 (Item Detail) ──► REQ-02 (Item Form)
    │                         │
    ▼                         ▼
REQ-05 (Search) ◄───────── REQ-04 (Scanner)
    │
    ▼
REQ-06 (Edit Category)
    │
    ▼
REQ-07 (Defaults)
```

**Execution Order:**
1. REQ-03 (LauncherService) - Foundation
2. REQ-01 + REQ-02 (Screens) - Core UI
3. REQ-04 (Scanner) - Batch operations
4. REQ-05 (Search) - Discovery
5. REQ-06 + REQ-07 (Polish) - UX improvements

---

## Risks and Mitigation

| Risk | Impact | Mitigation |
|------|--------|------------|
| file_picker platform issues | High | Test on all 3 platforms early |
| Launcher permissions | Medium | Document requirements, handle errors gracefully |
| Large directory scan performance | Medium | Implement progress callback, make cancelable |
| Form validation complexity | Low | Start with simple validation, iterate |

---

## Notes

- Keep UI simple and functional - polish comes later
- Use existing BLoC patterns from CategoryBloc/ItemBloc
- Reuse existing components (CategoryCard pattern for ItemCard)
- Russian language for all user-facing text
- Dark theme is default

---

*Document Version: 1.0*  
*Created: 2026-04-19*  
*Milestone: v1.0 Core Functionality MVP*
