# PC Media Center - Roadmap

## Overview
Media center application for organizing and launching apps, games, movies, and media.

**Current Milestone:** v1.0 Core Functionality MVP

---

## Milestone History

### v0.7 - Foundation & Critical Fixes ✅
**Status:** Complete  
**Date:** 2026-04-19

Fixed compilation errors, UI bugs, memory leaks, and established testing infrastructure.

---

## Current Milestone: v1.0 Core Functionality MVP

**Goal:** Make the app actually usable - implement minimum viable features

**Target:** Users can add items, view details, and launch files/programs

---

## Phase 8: Launcher Service & Item Detail

**Goal:** Implement cross-platform file launching and item detail view

**Requirements:** REQ-01, REQ-03

### Plans:
- [ ] **08-01-PLAN.md** — LauncherService Implementation
  - Cross-platform file launching (Windows/Linux/macOS)
  - Error handling for missing files
  - Support for launch arguments
  
- [ ] **08-02-PLAN.md** — ItemDetailScreen Implementation
  - Full item detail UI with poster, metadata
  - Launch button integration
  - Edit/Delete buttons

---

## Phase 9: Item Form & File Picker

**Goal:** Implement item creation/editing with file selection

**Requirements:** REQ-02

### Plans:
- [ ] **09-01-PLAN.md** — File Picker Integration
  - Add file_picker dependency
  - Create reusable FilePickerButton widget
  - Platform-specific file dialogs
  
- [ ] **09-02-PLAN.md** — ItemFormScreen Implementation
  - Full form with all fields
  - Form validation
  - Create/Update functionality
  - Category selector

---

## Phase 10: Directory Scanner

**Goal:** Implement batch item creation via directory scanning

**Requirements:** REQ-04

### Plans:
- [ ] **10-01-PLAN.md** — DirectoryScanner Service
  - Recursive directory scanning
  - Extension filtering
  - Filename parsing for metadata
  - Progress callbacks
  
- [ ] **10-02-PLAN.md** — Scanner UI Integration
  - "Scan Folder" button in CategoryScreen
  - Progress dialog
  - Batch item creation
  - Duplicate detection

---

## Phase 11: Local Search & Category Polish

**Goal:** Add search functionality and complete category CRUD

**Requirements:** REQ-05, REQ-06, REQ-07

### Plans:
- [ ] **11-01-PLAN.md** — Local Search Implementation
  - Search bar in CategoryScreen
  - Real-time filtering
  - Debounced search input
  
- [ ] **11-02-PLAN.md** — Category Edit & Defaults
  - Edit category functionality
  - Default categories seeding
  - First-run detection

---

## Dependency Graph

```
Phase 8 (Launcher + Detail)
    │
    ├──► Phase 9 (Form + Picker)
    │       │
    │       ├──► Phase 10 (Scanner)
    │       │
    │       └──► Phase 11 (Search + Polish)
    │
    └──► Can run in parallel with other phases
```

**Critical Path:** Phase 8 → Phase 9 → Phase 10 → Phase 11

---

## Notes

- Phase 8 is foundational - launcher service needed by detail screen
- Phase 9 can start after Phase 8 launcher is ready
- Phase 10 and 11 can be done in parallel
- Each phase should produce working, testable features
- All phases must pass `flutter analyze` and `flutter test`

---

## Future Milestones

### v1.1 - Metadata Enrichment
- Online search (TMDB/Kinopoisk)
- Poster caching
- Automatic metadata fetching

### v1.2 - Advanced Features
- Icon extraction from executables
- Settings screen
- Theme switching
- Language switching

### v1.3 - Input & Accessibility
- Gamepad support
- Keyboard navigation
- Voice input

### v2.0 - Polish & Release
- Performance optimization
- Comprehensive testing
- Documentation
- Release builds

---

*Last Updated: 2026-04-19*
