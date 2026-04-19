---
phase: 11-search-polish
type: execute
wave: 2
depends_on:
  - 08-PLAN.md
  - 10-PLAN.md
files_modified:
  - lib/presentation/screens/category/category_screen.dart
  - lib/presentation/screens/home/home_screen.dart
  - lib/presentation/widgets/common/category_card.dart
  - lib/main.dart
  - lib/core/services/initialization_service.dart
requirements:
  - REQ-05
  - REQ-06
  - REQ-07
---

## Objective

Add local search functionality to the CategoryScreen with real-time filtering, complete category CRUD by implementing edit functionality, and seed default categories (Фильмы, Игры, Программы) on first app launch. This phase polishes the core user experience by enabling content discovery and completing category management.

**Purpose:** Enable users to search within categories, edit category names, and have sensible defaults on first run
**Output:** Enhanced CategoryScreen with search, working category edit, and automatic default category creation

---

## Tasks

### Task 1: Add Search Bar to CategoryScreen App Bar

**Files:** `lib/presentation/screens/category/category_screen.dart`

**Action:**
1. Add a search query state variable (`_searchQuery`)
2. Add a boolean flag to toggle search mode (`_isSearching`)
3. Modify the AppBar to show search field when in search mode:
   - Add search icon button to toggle search mode
   - When in search mode, show TextField with clear button
   - Use `TextField` with `onChanged` callback
4. Add search icon to AppBar actions

**Acceptance Criteria:**
- Search icon visible in CategoryScreen app bar
- Tapping search icon opens search text field
- Search field has clear button (X) to reset
- Search mode can be exited to return to normal title view

---

### Task 2: Implement Real-Time Filtering with Debounce

**Files:** `lib/presentation/screens/category/category_screen.dart`

**Action:**
1. Add `Timer? _debounceTimer` field to state class
2. Create debounced search method:
   ```dart
   void _onSearchChanged(String query) {
     _debounceTimer?.cancel();
     _debounceTimer = Timer(const Duration(milliseconds: 300), () {
       setState(() => _searchQuery = query);
       _performSearch(query);
     });
   }
   ```
3. Cancel timer in `dispose()` method
4. Create `_performSearch(String query)` method that filters items

**Acceptance Criteria:**
- Search input debounced at 300ms (not on every keystroke)
- Timer properly cancelled on widget dispose
- No memory leaks from orphaned timers

---

### Task 3: Add Search Across Titles and Descriptions

**Files:** `lib/presentation/screens/category/category_screen.dart`

**Action:**
1. Filter loaded items based on search query:
   ```dart
   List<ItemEntity> get _filteredItems {
     if (_searchQuery.isEmpty) return _items;
     final lowerQuery = _searchQuery.toLowerCase();
     return _items.where((item) {
       final titleMatch = item.title.toLowerCase().contains(lowerQuery);
       final descMatch = item.description?.toLowerCase().contains(lowerQuery) ?? false;
       return titleMatch || descMatch;
     }).toList();
   }
   ```
2. Update GridView to use `_filteredItems` instead of `_items`
3. Ensure case-insensitive comparison using `toLowerCase()`

**Acceptance Criteria:**
- Search matches item titles (case-insensitive)
- Search matches item descriptions (case-insensitive)
- Empty search query shows all items
- Search works with Cyrillic characters

---

### Task 4: Add "No Results" Message

**Files:** `lib/presentation/screens/category/category_screen.dart`

**Action:**
1. Add conditional display when search returns no results:
   ```dart
   if (_filteredItems.isEmpty && _searchQuery.isNotEmpty) {
     return Center(
       child: Column(
         mainAxisAlignment: MainAxisAlignment.center,
         children: [
           Icon(Icons.search_off, size: 64, color: Colors.grey),
           SizedBox(height: 16),
           Text(
             'Ничего не найдено',
             style: Theme.of(context).textTheme.titleMedium,
           ),
           SizedBox(height: 8),
           Text(
             'Попробуйте изменить запрос',
             style: Theme.of(context).textTheme.bodyMedium?.copyWith(
               color: Colors.grey,
             ),
           ),
         ],
       ),
     );
   }
   ```
2. Show different message for empty category vs no search results

**Acceptance Criteria:**
- "Ничего не найдено" message shown when search has no matches
- Helpful subtext suggests changing the query
- Visual icon (search_off) displayed
- Message only appears when actively searching (query not empty)

---

### Task 5: Add Edit Button Handler to CategoryCard

**Files:** `lib/presentation/screens/home/home_screen.dart`

**Action:**
1. Update CategoryCard onEdit callback in HomeScreen:
   ```dart
   CategoryCard(
     category: category,
     onTap: () => _navigateToCategory(context, category),
     onEdit: () => _showEditCategoryDialog(context, category),
     onDelete: () => _showDeleteConfirmation(context, category),
   )
   ```
2. Implement `_navigateToCategory` method for onTap
3. Implement `_showDeleteConfirmation` with AlertDialog for delete

**Acceptance Criteria:**
- Edit button on category card opens edit dialog
- Delete button shows confirmation dialog before deleting
- Category card tap navigates to category screen

---

### Task 6: Create Edit Category Dialog

**Files:** `lib/presentation/screens/home/home_screen.dart`

**Action:**
1. Create `_showEditCategoryDialog` method:
   ```dart
   void _showEditCategoryDialog(BuildContext context, CategoryEntity category) {
     final controller = TextEditingController(text: category.name);
     showDialog(
       context: context,
       builder: (dialogContext) => AlertDialog(
         title: const Text('Редактировать категорию'),
         content: TextField(
           controller: controller,
           autofocus: true,
           decoration: const InputDecoration(
             labelText: 'Название',
             hintText: 'Введите название категории',
           ),
         ),
         actions: [
           TextButton(
             onPressed: () => Navigator.pop(dialogContext),
             child: const Text('Отмена'),
           ),
           TextButton(
             onPressed: () {
               final newName = controller.text.trim();
               if (newName.isNotEmpty && newName != category.name) {
                 context.read<CategoryBloc>().add(
                   UpdateCategoryEvent(
                     categoryId: category.id,
                     name: newName,
                   ),
                 );
               }
               Navigator.pop(dialogContext);
             },
             child: const Text('Сохранить'),
           ),
         ],
       ),
     );
   }
   ```
2. Pre-fill text field with current category name
3. Only emit update event if name actually changed

**Acceptance Criteria:**
- Dialog shows with current category name pre-filled
- Save button updates category via CategoryBloc
- Cancel button closes without changes
- Dialog uses Russian text for all labels

---

### Task 7: Handle Duplicate Name Validation

**Files:** `lib/presentation/screens/home/home_screen.dart`, `lib/presentation/blocs/category/category_bloc.dart`

**Action:**
1. In HomeScreen, check for duplicates before updating:
   ```dart
   void _showEditCategoryDialog(BuildContext context, CategoryEntity category) {
     // ... existing code ...
     TextButton(
       onPressed: () {
         final newName = controller.text.trim();
         if (newName.isEmpty) {
           _showError(dialogContext, 'Название не может быть пустым');
           return;
         }
         // Check for duplicates against current categories
         final currentState = context.read<CategoryBloc>().state;
         if (currentState is CategoryLoaded) {
           final exists = currentState.categories.any(
             (c) => c.name.toLowerCase() == newName.toLowerCase() && c.id != category.id
           );
           if (exists) {
             _showError(dialogContext, 'Категория с таким названием уже существует');
             return;
           }
         }
         // Proceed with update...
       },
       child: const Text('Сохранить'),
     );
   }
   ```
2. Add `_showError(BuildContext context, String message)` helper method
3. Also add validation in CategoryBloc._onUpdateCategory for defense in depth

**Acceptance Criteria:**
- Empty category names rejected with error message
- Duplicate names (case-insensitive) rejected with error message
- Validation happens before emitting update event
- Error messages shown in Russian

---

### Task 8: Detect First App Launch

**Files:** `lib/main.dart`, `lib/core/services/initialization_service.dart` (create)

**Action:**
1. Create `lib/core/services/initialization_service.dart`:
   ```dart
   import '../di/injection.dart';
   import '../../data/datasources/local/local_data_source.dart';
   import '../../data/database/app_database.dart';
   
   class InitializationService {
     static const String _firstRunKey = 'first_run_completed';
     
     final LocalDataSource _localDataSource;
     
     InitializationService(this._localDataSource);
     
     Future<bool> isFirstRun() async {
       final value = await _localDataSource.getSetting(_firstRunKey);
       return value == null || value != 'true';
     }
     
     Future<void> markFirstRunComplete() async {
       await _localDataSource.setSetting(_firstRunKey, 'true');
     }
   }
   ```
2. Register in injection.dart
3. Modify main.dart to use initialization service:
   ```dart
   Future<void> main() async {
     WidgetsFlutterBinding.ensureInitialized();
     await configureDependencies();
     
     final initService = getIt<InitializationService>();
     if (await initService.isFirstRun()) {
       await _createDefaultCategories();
       await initService.markFirstRunComplete();
     }
     
     runApp(const App());
   }
   ```

**Acceptance Criteria:**
- First run detected when no 'first_run_completed' setting exists
- Setting stored after first run completes
- Subsequent launches skip default category creation
- Service properly registered in DI container

---

### Task 9: Create Default Categories

**Files:** `lib/main.dart`, `lib/core/services/initialization_service.dart`

**Action:**
1. Add default categories creation method:
   ```dart
   Future<void> _createDefaultCategories() async {
     final categoryRepository = getIt<CategoryRepository>();
     
     final defaults = [
       {'name': 'Фильмы', 'isMovieType': true},
       {'name': 'Игры', 'isMovieType': false},
       {'name': 'Программы', 'isMovieType': false},
     ];
     
     for (final category in defaults) {
       try {
         await categoryRepository.addCategory(
           name: category['name'] as String,
           isMovieType: category['isMovieType'] as bool,
         );
       } catch (e) {
         // Log but don't fail - category might already exist
         debugPrint('Failed to create default category ${category['name']}: $e');
       }
     }
   }
   ```
2. Call from main.dart before runApp when first run detected
3. Handle case where categories might already exist (idempotent)

**Acceptance Criteria:**
- Three default categories created: Фильмы, Игры, Программы
- Фильмы marked as movie type (true)
- Игры and Программы marked as non-movie type (false)
- Creation is idempotent (safe to run multiple times)
- Categories appear in Russian as specified

---

### Task 10: Write Tests for Search Functionality

**Files:** `test/presentation/screens/category/category_screen_test.dart` (create)

**Action:**
1. Create widget test file for CategoryScreen search:
   ```dart
   import 'package:flutter/material.dart';
   import 'package:flutter_test/flutter_test.dart';
   import 'package:flutter_bloc/flutter_bloc.dart';
   import 'package:mocktail/mocktail.dart';
   import 'package:pc_media_center/presentation/screens/category/category_screen.dart';
   import 'package:pc_media_center/presentation/blocs/item/item_bloc.dart';
   import 'package:pc_media_center/domain/entities/item.dart';
   
   void main() {
     group('CategoryScreen Search', () {
       testWidgets('search icon is visible in app bar', (tester) async {
         // Test that search icon exists
       });
       
       testWidgets('tapping search icon opens search field', (tester) async {
         // Test search mode toggle
       });
       
       testWidgets('search filters items by title', (tester) async {
         // Test title filtering
       });
       
       testWidgets('search filters items by description', (tester) async {
         // Test description filtering
       });
       
       testWidgets('case insensitive search works', (tester) async {
         // Test case insensitivity
       });
       
       testWidgets('no results message shown when empty', (tester) async {
         // Test empty state
       });
       
       testWidgets('clear button resets search', (tester) async {
         // Test clear functionality
       });
     });
   }
   ```
2. Mock ItemBloc and test search interactions
3. Test debounce behavior (if feasible in widget test)

**Acceptance Criteria:**
- Tests cover search icon visibility
- Tests cover search mode toggle
- Tests cover filtering by title and description
- Tests cover case-insensitive matching
- Tests cover "no results" state
- All tests pass with `flutter test`

---

## Acceptance Criteria

- [ ] Search bar visible in CategoryScreen app bar
- [ ] Real-time filtering with 300ms debounce
- [ ] Case-insensitive search across titles and descriptions
- [ ] "Ничего не найдено" message shown for empty results
- [ ] Category edit updates name via dialog
- [ ] Duplicate category names rejected with error
- [ ] Empty category names rejected with error
- [ ] Default categories (Фильмы, Игры, Программы) created on first run
- [ ] First-run flag stored in settings
- [ ] All tests pass (`flutter test` exits 0)
- [ ] No analyzer errors (`flutter analyze` clean)

---

## Threat Model

### Trust Boundaries

| Boundary | Description |
|----------|-------------|
| User Input (Search) | Untrusted - user can enter any text |
| User Input (Category Names) | Untrusted - user can enter any text |
| Local Database | Trusted - internal storage |
| Settings Storage | Trusted - internal app state |

### STRIDE Threat Register

| Threat ID | Category | Component | Risk | Disposition | Mitigation |
|-----------|----------|-----------|------|-------------|------------|
| T-11-01 | Injection | Search input | Medium | MITIGATE | No SQL queries built from search text; use in-memory filtering only |
| T-11-02 | Tampering | First-run flag | Low | ACCEPT | Local app data only; user modifying it just recreates defaults |
| T-11-03 | DoS | Search debounce | Low | MITIGATE | 300ms debounce prevents rapid re-filtering performance issues |
| T-11-04 | Elevation | Category validation bypass | Low | MITIGATE | Validation in both UI and BLoC layers (defense in depth) |
| T-11-05 | Information Disclosure | Search results | Low | ACCEPT | Only shows user's own items; no sensitive data exposure |

---

## Verification

### Static Analysis
```bash
flutter analyze --no-fatal-infos
```
Must exit with code 0 (no errors).

### Unit Tests
```bash
flutter test
```
All tests must pass.

### Manual Verification Steps
1. Launch app on fresh install - verify 3 default categories created
2. Navigate to a category with items
3. Tap search icon - verify search field appears
4. Type search query - verify debounce (300ms delay before filtering)
5. Verify case-insensitive matching (search "фильм" matches "Фильм")
6. Verify description search (item with matching description appears)
7. Enter query with no matches - verify "Ничего не найдено" message
8. Tap clear button - verify search resets
9. Navigate to HomeScreen
10. Tap edit on category card - verify dialog opens with current name
11. Try to save empty name - verify error message
12. Try to save duplicate name - verify error message
13. Save valid new name - verify category updates
14. Kill app and restart - verify defaults not created again

---

## Output

After completion, create `.planning/phases/phase-11-search-polish/11-SUMMARY.md` with:
- Summary of changes made
- Files modified
- Tests added
- Any deviations from plan
- Lessons learned
