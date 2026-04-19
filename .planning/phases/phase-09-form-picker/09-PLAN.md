---
phase: 09-form-picker
type: execute
wave: 1
depends_on:
  - 08-PLAN.md
files_modified:
  - lib/presentation/screens/item_form/item_form_screen.dart
  - lib/presentation/widgets/file_picker_button.dart
  - pubspec.yaml
  - lib/presentation/blocs/item/item_event.dart
  - lib/presentation/blocs/item/item_bloc.dart
files_created:
  - lib/presentation/widgets/file_picker_button.dart
  - test/presentation/screens/item_form/item_form_screen_test.dart
requirements:
  - REQ-02
---

# Phase 9: Item Form & File Picker

## Objective

Implement a complete item creation and editing form with file selection capability. This screen allows users to add new items (movies, games, apps) by selecting files from the filesystem, editing their metadata, and saving them to the database.

## Context

- **ItemEntity** fields: id, name, posterPath, posterUrl, categoryId, title, description, launchPath, launchArgs, itemType, year, rating, externalId, metadataJson, sortOrder, isFavorite
- **Current ItemFormScreen**: Basic stub that accepts optional `itemId` parameter
- **ItemBloc**: Currently only handles `GetItemsByCategoryEvent`, needs new events for create/update
- **Existing patterns**: CategoryBloc has Add/Update/Delete events that reload list after mutation
- **Validation**: Must be in Russian per NFR-03
- **File picking**: Uses `file_picker: ^8.0.0+1` package

## Tasks

### Task 1: Add file_picker dependency to pubspec.yaml

Add the file_picker package to dependencies:

```yaml
dependencies:
  # ... existing dependencies
  file_picker: ^8.0.0+1
```

Run `flutter pub get` to install.

**Notes:**
- Version ^8.0.0+1 supports all desktop platforms (Windows, macOS, Linux)
- No additional platform-specific setup required for desktop

---

### Task 2: Create FilePickerButton widget

Create `lib/presentation/widgets/file_picker_button.dart`:

**Requirements:**
- Reusable button that opens file picker dialog
- Displays selected file path or placeholder text
- Supports different file type filters (media, executables, images)
- Shows error message if picker fails
- Russian UI text

**Interface:**
```dart
class FilePickerButton extends StatelessWidget {
  final String? selectedPath;
  final ValueChanged<String?> onPathSelected;
  final String label;
  final List<String>? allowedExtensions;
  final bool allowMultiple;
  
  const FilePickerButton({
    super.key,
    this.selectedPath,
    required this.onPathSelected,
    required this.label,
    this.allowedExtensions,
    this.allowMultiple = false,
  });
}
```

**Behavior:**
- Button shows "Выбрать файл" (Select file)
- Below button shows selected path or "Файл не выбран"
- On tap: opens `FilePicker.platform.pickFiles()`
- Handles PlatformException gracefully with SnackBar
- Allowed extensions examples: `['exe', 'mp4', 'mkv']` for media, `['jpg', 'png']` for posters

---

### Task 3: Create ItemFormScreen with form fields

Replace the stub implementation in `lib/presentation/screens/item_form/item_form_screen.dart`:

**Form Fields:**
1. **Title** (TextFormField) - Required
2. **Description** (TextFormField, maxLines: 3) - Optional
3. **Year** (TextFormField, keyboardType: number) - Optional
4. **File Path** (FilePickerButton) - Required
5. **Poster Path** (FilePickerButton) - Optional (image files)
6. **Category** (DropdownButtonFormField) - Required
7. **Item Type** (DropdownButtonFormField) - Required, defaults to movie

**Layout:**
- Use `SingleChildScrollView` with `Padding`
- Form fields in vertical `Column` with `SizedBox` spacing (16px)
- At bottom: Save and Cancel buttons in `Row`

**Parameters:**
```dart
class ItemFormScreen extends StatefulWidget {
  final String? itemId;  // null = create mode, set = edit mode
  final int? initialCategoryId;  // Pre-select category when creating from category screen
  
  const ItemFormScreen({
    super.key,
    this.itemId,
    this.initialCategoryId,
  });
}
```

**State Management:**
- Use `GlobalKey<FormState>` for form validation
- Local state for form field values
- Listen to ItemBloc state for save success/error

---

### Task 4: Add form validation (title, file path required)

**Validation Rules:**

| Field | Rule | Error Message (Russian) |
|-------|------|-------------------------|
| Title | Required, min 1 char | "Название обязательно" |
| File Path | Required, file must exist | "Выберите файл" / "Файл не существует" |
| Year | Optional, if set: 1900-current+1 | "Некорректный год" |
| Category | Required | "Выберите категорию" |

**Validation Implementation:**
- Use `TextFormField.validator` for text fields
- File existence check before save using `File(path).existsSync()`
- Show validation errors inline (TextFormField's built-in error display)
- Disable Save button while validation fails

---

### Task 5: Integrate with ItemBloc for save/update

**Add new events to `lib/presentation/blocs/item/item_event.dart`:**

```dart
class SaveItemEvent extends ItemEvent {
  final int? itemId;  // null = create
  final int categoryId;
  final String title;
  final String? description;
  final String? launchPath;
  final String? posterPath;
  final int? year;
  final ItemType itemType;
  
  const SaveItemEvent({
    this.itemId,
    required this.categoryId,
    required this.title,
    this.description,
    this.launchPath,
    this.posterPath,
    this.year,
    required this.itemType,
  });
}

class LoadItemForEditEvent extends ItemEvent {
  final int itemId;
  const LoadItemForEditEvent(this.itemId);
}
```

**Add new states to `lib/presentation/blocs/item/item_state.dart`:**

```dart
class ItemFormLoading extends ItemState {
  const ItemFormLoading();
}

class ItemFormLoaded extends ItemState {
  final ItemEntity? item;  // null = create mode
  const ItemFormLoaded({this.item});
}

class ItemSaved extends ItemState {
  const ItemSaved();
}

class ItemFormError extends ItemState {
  final String message;
  const ItemFormError({required this.message});
}
```

**Update ItemBloc:**
- Add `AddItem` and `UpdateItem` use cases as dependencies
- Handle `LoadItemForEditEvent`: fetch item by ID, emit `ItemFormLoaded`
- Handle `SaveItemEvent`:
  - If itemId is null: call `AddItem` use case
  - If itemId is set: fetch existing, merge changes, call `UpdateItem`
  - On success: emit `ItemSaved`
  - On error: emit `ItemFormError`

---

### Task 6: Handle create vs edit modes

**Create Mode (itemId == null):**
- AppBar title: "Добавить элемент"
- All fields empty/default
- Pre-select `initialCategoryId` if provided
- Save button: "Добавить"
- On save success: Navigate back with result `true`

**Edit Mode (itemId != null):**
- AppBar title: "Редактировать элемент"
- On init: dispatch `LoadItemForEditEvent`
- Pre-fill all fields from loaded ItemEntity
- Save button: "Сохранить"
- On save success: Navigate back with result `true`

**Common Behavior:**
- Cancel button: Navigate back with result `false` or no result
- Show loading indicator while loading item in edit mode
- Show error SnackBar if item load fails

---

### Task 7: Add category selector dropdown

**Implementation:**
- Use `DropdownButtonFormField<int>` for category selection
- Fetch categories via `CategoryBloc` or direct repository call
- Display category names, use IDs as values
- Required field with validation

**Dependencies:**
- Inject `GetCategories` use case or listen to `CategoryBloc`
- On screen init: dispatch `LoadCategories` if using bloc

**UI:**
- Label: "Категория"
- Hint: "Выберите категорию"
- Validation error: "Категория обязательна"

---

### Task 8: Write widget tests for ItemFormScreen

Create `test/presentation/screens/item_form/item_form_screen_test.dart`:

**Test Cases:**
1. **Create Mode Initial State:**
   - Shows "Добавить элемент" title
   - All fields empty
   - Save button disabled initially

2. **Validation - Empty Title:**
   - Tap Save without entering title
   - Shows "Название обязательно" error

3. **Validation - No File:**
   - Enter title, don't select file
   - Shows "Выберите файл" error

4. **File Picker Integration:**
   - Mock file_picker to return path
   - Tap file picker button
   - Verify selected path displayed

5. **Save Success - Create:**
   - Fill valid form
   - Tap Save
   - Verify ItemBloc receives SaveItemEvent with correct data
   - Verify navigation back with true result

6. **Edit Mode Loading:**
   - Pass itemId
   - Verify LoadItemForEditEvent dispatched
   - Verify form pre-filled after load

7. **Cancel Navigation:**
   - Tap Cancel
   - Verify navigation back without saving

**Mock Setup:**
- Mock `ItemBloc`, `CategoryBloc`
- Mock `FilePicker` platform channel
- Provide blocs via `BlocProvider` in test

---

## Acceptance Criteria

- [x] `file_picker` dependency added and installs cleanly
- [x] FilePickerButton widget created and reusable
- [x] ItemFormScreen has all required fields (title, description, year, file path, poster path, category, item type)
- [x] Form validates required fields (title, file path, category) with Russian error messages
- [x] File existence verified before save
- [x] ItemBloc handles SaveItemEvent for create and update
- [x] Create mode shows empty form, Edit mode pre-fills existing data
- [x] Category dropdown loads and selects correctly
- [x] Save button creates/updates item via BLoC
- [x] Cancel button returns without saving
- [x] All widget tests pass
- [x] `flutter analyze` shows zero errors

## Threat Model

### T1: Directory Traversal via File Path
**Threat:** Malicious file path like `../../../etc/passwd` could access system files
**Mitigation:** 
- Validate file exists using `File(path).existsSync()`
- Use `path.isAbsolute` check
- Store canonical path using `File(path).resolveSymbolicLinksSync()`
- Don't execute paths, only store and later open via platform launcher

### T2: Path Injection via Form Fields
**Threat:** Special characters in paths could break SQL queries
**Mitigation:**
- Repository uses parameterized queries (Drift handles this)
- No string concatenation in SQL

### T3: Invalid File Selection
**Threat:** User selects non-existent or unreadable file
**Mitigation:**
- Validate file existence before save
- Check file permissions (readable)
- Show user-friendly error if file invalid

### T4: Oversized Metadata
**Threat:** Very long paths or descriptions could cause storage issues
**Mitigation:**
- SQLite TEXT field has 1GB limit (sufficient)
- UI max length constraints on fields

## Verification

### Static Analysis
```bash
flutter analyze
```
Expected: 0 issues

### Tests
```bash
flutter test test/presentation/screens/item_form/item_form_screen_test.dart
```
Expected: All tests pass

### Manual Testing Checklist
- [ ] File picker opens on current platform
- [ ] Can select media file (.mp4, .mkv, .exe)
- [ ] Can select poster image (.jpg, .png)
- [ ] Form validates empty title
- [ ] Form validates missing file
- [ ] Creating new item saves to database
- [ ] Editing existing item updates database
- [ ] Cancel returns without changes
- [ ] Category dropdown shows all categories
- [ ] Russian text displays correctly

## Output

Upon completion, create `09-SUMMARY.md` with:
1. What was implemented
2. Key design decisions
3. Test coverage summary
4. Any deviations from plan

## Platform Notes

**Windows:**
- File paths use backslashes, Flutter handles normalization
- No special permissions needed for file picker

**macOS:**
- Sandboxing not enforced for desktop Flutter apps
- May need entitlements for file access in signed apps

**Linux:**
- xdg-desktop-portal required for file picker
- Available on all modern desktop environments

## Related Files

- `lib/presentation/screens/item_form/item_form_screen.dart` (modified)
- `lib/presentation/widgets/file_picker_button.dart` (created)
- `lib/presentation/blocs/item/item_bloc.dart` (modified)
- `lib/presentation/blocs/item/item_event.dart` (modified)
- `lib/presentation/blocs/item/item_state.dart` (modified)
- `pubspec.yaml` (modified)
- `test/presentation/screens/item_form/item_form_screen_test.dart` (created)
