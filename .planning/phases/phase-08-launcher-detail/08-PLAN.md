---
phase: 08-launcher-detail
type: execute
wave: 1
depends_on: []
files_modified:
  - lib/core/services/launcher_service.dart
  - lib/presentation/screens/item_detail/item_detail_screen.dart
  - lib/core/di/injection.dart
requirements:
  - REQ-01
  - REQ-03
---

## Objective

Implement cross-platform file launching capability and a comprehensive Item Detail screen. This phase delivers the core functionality that allows users to view item metadata and launch files/programs directly from the app.

**Purpose:** Enable users to browse item details and launch media files or applications  
**Output:** LauncherService for cross-platform file execution, fully-featured ItemDetailScreen with poster display and action buttons

---

## Tasks

### Task 1: Create LauncherService Interface and Base Implementation

**Files:** `lib/core/services/launcher_service.dart` (new)

**Acceptance Criteria:**
- Abstract interface `LauncherService` defined with `Future<LaunchResult> launch(String path, {String? arguments})` method
- `LaunchResult` class created with success/failure status and error message
- Base implementation handles null/empty path validation
- Platform detection logic using `dart:io` Platform class

**Implementation Notes:**
- Use `Platform.isWindows`, `Platform.isLinux`, `Platform.isMacOS` for platform detection
- Return structured result instead of throwing exceptions for expected errors
- All error messages must be in Russian

---

### Task 2: Implement Windows Launching

**Files:** `lib/core/services/launcher_service.dart`

**Acceptance Criteria:**
- Windows implementation uses `Process.run('cmd', ['/c', 'start', '', path])`
- Handles spaces in file paths correctly
- Returns specific error for "file not found" (code: 0x80070002)
- Returns specific error for "no application associated" 

**Implementation Notes:**
- The empty string `''` in the cmd arguments is required for proper path handling
- Use `ProcessStartMode.detached` or similar to avoid blocking UI
- Parse process exit code and stderr for specific error messages

**Error Messages (Russian):**
- File not found: "Файл не найден: {path}"
- No application: "Нет приложения для открытия этого файла"
- Generic error: "Не удалось запустить файл: {error}"

---

### Task 3: Implement Linux Launching

**Files:** `lib/core/services/launcher_service.dart`

**Acceptance Criteria:**
- Linux implementation uses `Process.run('xdg-open', [path])`
- Handles file paths with special characters
- Returns specific error when xdg-open fails
- Graceful handling when xdg-open is not available

**Implementation Notes:**
- xdg-open is standard on most Linux distributions
- Exit code 3 typically means "file not found"
- Exit code 4 typically means "no application associated"

**Error Messages (Russian):**
- File not found: "Файл не найден: {path}"
- No application: "Нет приложения для открытия этого файла"
- xdg-open not found: "Утилита xdg-open не установлена"
- Generic error: "Не удалось запустить файл: {error}"

---

### Task 4: Implement macOS Launching

**Files:** `lib/core/services/launcher_service.dart`

**Acceptance Criteria:**
- macOS implementation uses `Process.run('open', [path])`
- Handles file paths with spaces correctly
- Returns specific error for "file not found" (exit code 1)
- Returns specific error for "no application associated"

**Implementation Notes:**
- `open` command is standard on all macOS versions
- Use `-W` flag if we need to wait for application to close (not required for this use case)
- Exit code 1 with "The file ... does not exist" message

**Error Messages (Russian):**
- File not found: "Файл не найден: {path}"
- No application: "Нет приложения для открытия этого файла"
- Generic error: "Не удалось запустить файл: {error}"

---

### Task 5: Create ItemDetailScreen UI with Poster and Metadata

**Files:** `lib/presentation/screens/item_detail/item_detail_screen.dart`

**Acceptance Criteria:**
- Screen displays item poster image (from posterPath or posterUrl) with placeholder fallback
- Title displayed prominently (using item.title or item.name)
- Description shown in scrollable text area
- Year displayed when available (item.year > 0)
- Rating displayed as stars or numeric value when available (item.rating > 0)
- File path displayed (item.launchPath)
- Launch arguments displayed if present (item.launchArgs)
- Item type displayed as localized string (movie, tvShow, episode)
- Created/updated timestamps formatted nicely

**UI Layout:**
```
AppBar: Item Title
Body:
  - Poster image (left side or top, ~40% width/height)
  - Metadata column:
    * Title (large)
    * Year | Rating | Type (row)
    * Description (scrollable)
    * File path (small, truncated with tooltip)
    * Arguments (if present)
    * Created/Updated dates
```

**Implementation Notes:**
- Use existing `CachedNetworkImage` or similar for poster loading
- Show placeholder icon when no poster available (Icons.image_not_supported)
- Use `SelectableText` for file path to allow copy-paste
- All labels and static text in Russian

---

### Task 6: Add Launch Button with Error Handling

**Files:** `lib/presentation/screens/item_detail/item_detail_screen.dart`

**Acceptance Criteria:**
- Prominent "Запустить" (Launch) button displayed
- Button disabled when item.launchPath is empty
- On tap: calls LauncherService.launch() with item.launchPath and item.launchArgs
- Success: shows brief confirmation snackbar "Приложение запущено"
- Failure: shows error snackbar with message from LaunchResult
- Loading state shown while launching (button shows CircularProgressIndicator)

**Error Handling:**
- Wrap launch call in try-catch for unexpected errors
- Show user-friendly error messages in Russian
- Log detailed errors for debugging

**UI State Flow:**
1. Button shows "Запустить" with play icon
2. On tap: button shows loading indicator, disabled
3. On success: snackbar "Приложение запущено", button restored
4. On error: snackbar with error message, button restored

---

### Task 7: Add Edit and Delete Buttons

**Files:** `lib/presentation/screens/item_detail/item_detail_screen.dart`

**Acceptance Criteria:**
- "Редактировать" (Edit) button in AppBar actions or below poster
- Edit button navigates to ItemFormScreen with item data pre-filled
- "Удалить" (Delete) button present with confirmation dialog
- Delete confirmation dialog asks: "Удалить \"{title}\"? Это действие нельзя отменить."
- On confirm delete: dispatch DeleteItem event via ItemBloc
- After delete: navigate back to category screen

**Delete Confirmation Dialog:**
```
Title: "Подтвердите удаление"
Content: "Удалить \"{item.title}\"? Это действие нельзя отменить."
Actions:
  - "Отмена" (Cancel) - closes dialog
  - "Удалить" (Delete) - confirms deletion, red color
```

**Implementation Notes:**
- Use existing BLoC pattern for delete operation
- Listen to ItemBloc state for delete success/failure
- Navigate back only after successful deletion
- Show error snackbar if delete fails

---

### Task 8: Register LauncherService in DI Container

**Files:** `lib/core/di/injection.dart`

**Acceptance Criteria:**
- LauncherService registered as singleton in configureDependencies()
- Registration uses factory pattern to create platform-specific implementation
- ItemDetailScreen can access LauncherService via getIt<LauncherService>()

**Implementation:**
```dart
// Add import
import '../services/launcher_service.dart';

// Register in configureDependencies
getIt.registerLazySingleton<LauncherService>(() => LauncherServiceImpl());
```

---

### Task 9: Write Unit Tests for LauncherService

**Files:** `test/core/services/launcher_service_test.dart` (new)

**Acceptance Criteria:**
- Tests for empty/null path validation
- Tests for platform detection logic
- Mock Process.run calls for each platform
- Test error handling for "file not found" scenario
- Test error handling for "no application associated" scenario
- Minimum 80% coverage for LauncherService

**Test Structure:**
```dart
group('LauncherService', () {
  group('path validation', () {
    test('returns error for empty path', () async {...});
    test('returns error for null path', () async {...});
  });
  
  group('Windows', () {
    test('calls cmd start with correct arguments', () async {...});
    test('handles file not found error', () async {...});
  });
  
  group('Linux', () {
    test('calls xdg-open with correct arguments', () async {...});
    test('handles xdg-open not found', () async {...});
  });
  
  group('macOS', () {
    test('calls open with correct arguments', () async {...});
  });
});
```

---

## Acceptance Criteria

### Functional Requirements
- [ ] LauncherService.launch() successfully opens files on all 3 platforms (Windows/Linux/macOS)
- [ ] ItemDetailScreen displays all item metadata fields
- [ ] Poster image loads and displays with proper fallback
- [ ] Launch button opens file with system default handler
- [ ] Edit button navigates to ItemFormScreen with pre-filled data
- [ ] Delete button shows confirmation dialog and removes item
- [ ] All errors handled gracefully with Russian user-friendly messages

### Technical Requirements
- [ ] LauncherService registered in DI container
- [ ] Unit tests for LauncherService pass
- [ ] No analyzer errors on modified files
- [ ] No breaking changes to existing functionality

### UI/UX Requirements
- [ ] All text in Russian
- [ ] Loading states shown during async operations
- [ ] Error messages displayed via SnackBar
- [ ] Responsive layout works on different screen sizes

---

## Threat Model

### Trust Boundaries

| Boundary | Description |
|----------|-------------|
| File System | LauncherService crosses from app sandbox to system file execution |
| User Input | Item file paths come from database (user-provided during item creation) |
| Process Execution | External process spawned with user-controlled path |

### STRIDE Threat Register

| Threat ID | Category | Component | Risk Level | Disposition | Mitigation |
|-----------|----------|-----------|------------|-------------|------------|
| T-08-01 | Spoofing | LauncherService | Medium | Mitigate | Validate file exists before launching; use canonical paths |
| T-08-02 | Tampering | Launch Path | Low | Accept | Paths stored in local DB, app is single-user desktop app |
| T-08-03 | Repudiation | Launch Action | Low | Accept | OS-level logging handles audit trail |
| T-08-04 | Information Disclosure | File Paths | Low | Accept | Paths displayed only to authenticated user (local app) |
| T-08-05 | Denial of Service | Process.spawn | Medium | Mitigate | Timeout on Process.run; handle process spawn failures gracefully |
| T-08-06 | Elevation of Privilege | File Execution | Medium | Mitigate | No shell execution; use direct commands only (start/xdg-open/open); validate file type where possible |

### Security Notes
- Never use shell interpolation with user-provided paths
- Always pass file paths as separate arguments to Process.run
- Consider adding file extension whitelist for safety (future enhancement)
- Do not execute launchPath directly - always use platform handlers

---

## Verification

### Pre-Implementation Checks
```bash
# Check current state
flutter analyze lib/presentation/screens/item_detail/item_detail_screen.dart
flutter analyze lib/core/di/injection.dart
```

### During Implementation
```bash
# After each task, verify no analyzer errors
flutter analyze lib/core/services/launcher_service.dart
flutter analyze lib/presentation/screens/item_detail/item_detail_screen.dart
flutter analyze lib/core/di/injection.dart
```

### Post-Implementation Verification
```bash
# Run all tests
flutter test test/core/services/launcher_service_test.dart

# Full analyzer check
flutter analyze

# Build verification
flutter build linux --debug  # or appropriate target
```

### Manual Testing Checklist
- [ ] Launch video file opens in default video player
- [ ] Launch audio file opens in default audio player
- [ ] Launch executable runs the program
- [ ] Non-existent file shows "file not found" error
- [ ] File with no associated app shows "no application" error
- [ ] Edit button navigates to form with correct data
- [ ] Delete removes item and returns to category screen

---

## Output

After completion, create `.planning/phases/phase-08-launcher-detail/08-SUMMARY.md` with:
- Summary of implemented features
- Files modified
- Test coverage metrics
- Known limitations or future improvements
- Verification results
