---
phase: 10-scanner
type: execute
wave: 2
depends_on:
  - 09-PLAN.md
files_modified:
  - lib/core/services/directory_scanner.dart
  - lib/presentation/screens/category/category_screen.dart
  - lib/presentation/widgets/scan_progress_dialog.dart
  - lib/core/di/injection.dart
  - lib/presentation/blocs/item/item_bloc.dart
  - lib/presentation/blocs/item/item_event.dart
  - test/core/services/directory_scanner_test.dart
requirements:
  - REQ-04
---

# Phase 10: Directory Scanner

## Objective

Implement a directory scanning service that enables batch item creation by recursively scanning directories, filtering files by extensions, extracting metadata from filenames, and creating items in bulk while detecting duplicates and providing progress feedback to users.

## Background

PC Media Center needs the ability to quickly populate categories with multiple items. Manually adding each movie, game, or program is tedious. The Directory Scanner service will allow users to point to a folder (e.g., a movies directory) and automatically create items for all recognized files, extracting titles and years from filenames like "The.Matrix.1999.1080p.mkv".

## Tasks

### Task 1: Create DirectoryScanner Service

**File:** `lib/core/services/directory_scanner.dart`

Create the core scanning service with the following components:

1. **ScanOptions class** - Configuration for scanning:
   - `List<String> extensions` - File extensions to include (e.g., ['.mp4', '.mkv'])
   - `bool recursive` - Whether to scan subdirectories
   - `int? maxDepth` - Maximum recursion depth (null for unlimited)
   - `int maxFiles` - Safety limit (default 10000)
   - `bool followSymlinks` - Whether to follow symbolic links (default false)

2. **ScannedFile class** - Represents a discovered file:
   - `String path` - Absolute file path
   - `String filename` - Filename without path
   - `String extension` - File extension (lowercase)
   - `int fileSize` - File size in bytes
   - `DateTime modifiedAt` - Last modification time
   - `ExtractedMetadata metadata` - Parsed metadata

3. **ExtractedMetadata class** - Metadata extracted from filename:
   - `String title` - Cleaned title
   - `int? year` - Extracted year (4 digits, 1900-2030)
   - `String? resolution` - Resolution if found (e.g., "1080p", "4K")
   - `String? source` - Source tag if found (e.g., "BluRay", "WEB-DL")
   - `String originalFilename` - Original filename for reference

4. **DirectoryScanner class**:
   - `Stream<ScanProgress> scanDirectory(String path, ScanOptions options)` - Main scanning method
   - `List<ScannedFile> scanDirectorySync(String path, ScanOptions options)` - Synchronous version for tests
   - `ExtractedMetadata extractMetadata(String filename)` - Filename parsing
   - `bool isDuplicate(String path, int categoryId)` - Check against existing items

5. **ScanProgress class** - Progress updates:
   - `int filesFound` - Total files discovered
   - `int filesProcessed` - Files processed so far
   - `String? currentFile` - Currently processing file
   - `bool isComplete` - Whether scan is finished
   - `String? error` - Error message if failed
   - `Duration elapsed` - Time elapsed

**Key Implementation Details:**
- Use `dart:io` Directory.list/recursive for file enumeration
- Filter files by extension case-insensitively
- Skip hidden files (starting with '.')
- Skip system directories (like 'System Volume Information' on Windows)
- Validate paths to prevent directory traversal attacks
- Handle permission errors gracefully
- Never follow symlinks by default (security risk)

### Task 2: Implement Recursive Directory Scanning

**Implementation requirements:**

1. **BFS vs DFS**: Use BFS (breadth-first) to find files faster at shallow depths
2. **Cancellation support**: Accept `CancellationToken` or use stream cancellation
3. **Error handling per directory**: Continue scanning other directories if one fails
4. **Symlink detection**: Use `FileSystemEntity.isLinkSync()` to detect symlinks
5. **Circular reference protection**: Track visited inodes on Unix systems

**Algorithm outline:**
```dart
Stream<ScannedFile> scan(String path, ScanOptions options) async* {
  final queue = Queue<Directory>();
  queue.add(Directory(path));
  int depth = 0;
  
  while (queue.isNotEmpty && depth <= (options.maxDepth ?? infinity)) {
    final current = queue.removeFirst();
    
    await for (final entity in current.list()) {
      if (entity is File && matchesExtension(entity.path)) {
        yield ScannedFile.fromFile(entity);
      } else if (entity is Directory && options.recursive) {
        if (!isSymlink(entity) || options.followSymlinks) {
          queue.add(entity);
        }
      }
    }
    depth++;
  }
}
```

### Task 3: Add Extension Filtering

**Supported extensions by category type:**

```dart
static const Map<ItemType, List<String>> extensionsByType = {
  ItemType.movie: ['.mp4', '.mkv', '.avi', '.mov', '.wmv', '.flv', '.webm', '.m4v', '.mpg', '.mpeg'],
  ItemType.tvShow: ['.mp4', '.mkv', '.avi', '.mov', '.wmv'],
  ItemType.episode: ['.mp4', '.mkv', '.avi', '.mov'],
};

// For apps/games (not in ItemType enum yet, use custom):
static const List<String> executableExtensions = ['.exe', '.app', '.sh', '.bat', '.command'];
```

**Filter logic:**
- Convert extensions to lowercase for comparison
- Support both with and without leading dot
- Allow custom extension lists
- Default to common media extensions if none specified

### Task 4: Extract Metadata from Filename

**Filename parsing algorithm:**

1. **Remove extension**: Get basename without extension
2. **Replace separators**: Convert `.`, `_`, `-` to spaces
3. **Extract year**: Find 4-digit number between 1900-2030
4. **Clean title**: Remove common tags and garbage
5. **Title case**: Convert to proper title case

**Common patterns to handle:**
```
"The.Matrix.1999.1080p.BluRay.x264.mkv"
"Inception (2010) [1080p] [BluRay].mp4"
"Avatar_2009_Extended_Cut.mkv"
"The Dark Knight - 2008 - 1080p.mkv"
"Movie.Name.2021.WEB-DL.720p.mp4"
"TV.Show.S01E02.Episode.Title.mkv"
```

**Tags to remove:**
- Resolution: 720p, 1080p, 2160p, 4K, 480p
- Sources: BluRay, WEB-DL, WEBRip, HDRip, BRRip, DVDRip
- Encoders: x264, x265, H264, H265, AVC,HEVC
- Release groups: YIFY, RARBG, SPARKS, etc.
- Video codecs: MPEG, DivX, XviD
- Audio codecs: AAC, DTS, AC3, Dolby
- Misc: REMUX, PROPER, REPACK, EXTENDED, UNRATED, DC

**Implementation:**
```dart
ExtractedMetadata extractMetadata(String filename) {
  // Remove extension
  final nameWithoutExt = p.basenameWithoutExtension(filename);
  
  // Extract year (4 digits between 1900-2030)
  final yearMatch = RegExp(r'\b(19|20)\d{2}\b').firstMatch(nameWithoutExt);
  final year = yearMatch != null ? int.parse(yearMatch.group(0)!) : null;
  
  // Remove tags
  var cleanTitle = nameWithoutExt
    .replaceAll(RegExp(r'\[.*?\]'), '') // Remove [tags]
    .replaceAll(RegExp(r'\(.*?\)'), '') // Remove (tags)
    .replaceAll(RegExp(r'\b(1080p|720p|2160p|4K|480p|360p)\b', caseSensitive: false), '')
    .replaceAll(RegExp(r'\b(BluRay|WEB-?DL|WEBRip|HDRip|BRRip|DVDRip)\b', caseSensitive: false), '')
    // ... more patterns
    .trim();
  
  // Replace separators with spaces
  cleanTitle = cleanTitle.replaceAll(RegExp(r'[._-]+'), ' ').trim();
  
  // Remove extra spaces
  cleanTitle = cleanTitle.replaceAll(RegExp(r'\s+'), ' ');
  
  // Title case
  cleanTitle = toTitleCase(cleanTitle);
  
  return ExtractedMetadata(
    title: cleanTitle.isEmpty ? nameWithoutExt : cleanTitle,
    year: year,
    originalFilename: filename,
  );
}
```

### Task 5: Create Scan Progress Dialog

**File:** `lib/presentation/widgets/scan_progress_dialog.dart`

Create a dialog widget that displays scan progress:

1. **UI Components:**
   - Title: "Сканирование директории"
   - Progress bar (LinearProgressIndicator)
   - Current file path (truncated if long)
   - Statistics: "Найдено: X файлов, Обработано: Y"
   - Elapsed time
   - Cancel button
   - Completion message with summary

2. **States:**
   - Scanning: Show progress, Cancel button active
   - Completed: Show summary, "Готово" button
   - Error: Show error message, "Закрыть" button
   - Cancelled: Show cancellation message

3. **Usage pattern:**
```dart
showDialog(
  context: context,
  barrierDismissible: false,
  builder: (context) => ScanProgressDialog(
    scanStream: directoryScanner.scanDirectory(path, options),
    onComplete: (results) => createItemsFromResults(results),
    onCancel: () => cancellationToken.cancel(),
  ),
);
```

### Task 6: Add "Scan Folder" Button to CategoryScreen

**File:** `lib/presentation/screens/category/category_screen.dart`

Add scan functionality to CategoryScreen:

1. **Add file_picker dependency** (if not already added):
   ```yaml
   dependencies:
     file_picker: ^8.0.0+1
   ```

2. **Add Floating Action Button menu** or dedicated scan button:
   - Option 1: Expandable FAB with "Add Item" and "Scan Folder"
   - Option 2: Add to AppBar actions
   - Option 3: Bottom navigation with scan option

3. **Implementation:**
   ```dart
   Future<void> _scanDirectory() async {
     final result = await FilePicker.platform.getDirectoryPath();
     if (result == null) return;
     
     // Show extension selection dialog
     final extensions = await _showExtensionPickerDialog();
     if (extensions == null) return;
     
     // Show progress dialog and start scan
     final scannedFiles = await showDialog<List<ScannedFile>>(
       context: context,
       builder: (context) => ScanProgressDialog(
         directoryPath: result,
         extensions: extensions,
         categoryId: int.parse(widget.categoryId),
       ),
     );
     
     if (scannedFiles != null && scannedFiles.isNotEmpty) {
       // Create items
       _createItemsFromScan(scannedFiles);
     }
   }
   ```

4. **Extension picker dialog**:
   - Show common extensions grouped by type
   - Movies: .mp4, .mkv, .avi
   - Programs: .exe, .app
   - Custom input for other extensions
   - Select/deselect all option

### Task 7: Implement Batch Item Creation via ItemBloc

**Files to modify:**
- `lib/presentation/blocs/item/item_event.dart` - Add new events
- `lib/presentation/blocs/item/item_bloc.dart` - Handle batch creation

1. **New Events:**
```dart
class BatchCreateItemsEvent extends ItemEvent {
  final List<CreateItemData> items;
  final int categoryId;
  
  const BatchCreateItemsEvent({
    required this.items,
    required this.categoryId,
  });
}

class CreateItemData {
  final String title;
  final String launchPath;
  final int? year;
  final ItemType itemType;
  
  const CreateItemData({
    required this.title,
    required this.launchPath,
    this.year,
    this.itemType = ItemType.movie,
  });
}
```

2. **Bloc Handler:**
```dart
Future<void> _onBatchCreateItems(
  BatchCreateItemsEvent event,
  Emitter<ItemState> emit,
) async {
  emit(ItemBatchCreating(progress: 0, total: event.items.length));
  
  int successCount = 0;
  int duplicateCount = 0;
  int errorCount = 0;
  
  for (int i = 0; i < event.items.length; i++) {
    final item = event.items[i];
    
    // Check for duplicates
    final existing = await _repository.findByPath(item.launchPath);
    if (existing != null) {
      duplicateCount++;
      continue;
    }
    
    try {
      await _addItem(
        categoryId: event.categoryId,
        title: item.title,
        launchPath: item.launchPath,
        year: item.year,
        itemType: item.itemType,
      );
      successCount++;
    } catch (e) {
      errorCount++;
    }
    
    // Emit progress every 5 items or on last
    if (i % 5 == 0 || i == event.items.length - 1) {
      emit(ItemBatchCreating(
        progress: i + 1,
        total: event.items.length,
        successCount: successCount,
        duplicateCount: duplicateCount,
        errorCount: errorCount,
      ));
    }
  }
  
  emit(ItemBatchCreated(
    successCount: successCount,
    duplicateCount: duplicateCount,
    errorCount: errorCount,
  ));
  
  // Refresh the list
  add(GetItemsByCategoryEvent(categoryId: event.categoryId));
}
```

### Task 8: Add Duplicate Detection

**Duplicate detection strategies:**

1. **Path-based** (primary): Check if `launchPath` already exists in category
2. **Filename-based** (fallback): Check if filename matches existing item
3. **Hash-based** (optional future): Compare file hashes for moved files

**Implementation in DirectoryScanner:**
```dart
class DuplicateDetector {
  final ItemRepository _repository;
  final Set<String> _scannedPaths = {};
  
  Future<bool> isDuplicate(String path, int categoryId) async {
    // Check already scanned in this session
    if (_scannedPaths.contains(path.toLowerCase())) {
      return true;
    }
    
    // Check database
    final existing = await _repository.findByPathInCategory(path, categoryId);
    if (existing != null) {
      return true;
    }
    
    _scannedPaths.add(path.toLowerCase());
    return false;
  }
  
  void clear() => _scannedPaths.clear();
}
```

**User experience for duplicates:**
- Show count of skipped duplicates in progress dialog
- Option to "Show duplicates" after scan
- Allow user to force-add if needed (advanced option)

### Task 9: Write Unit Tests for DirectoryScanner

**File:** `test/core/services/directory_scanner_test.dart`

**Test cases:**

1. **Basic scanning:**
   - Scan directory with various file types
   - Verify correct files are found
   - Verify extensions are filtered correctly

2. **Recursive scanning:**
   - Scan with recursive=true finds nested files
   - Scan with recursive=false only finds top-level
   - Respect maxDepth parameter

3. **Symlink handling:**
   - Skip symlinks by default
   - Follow symlinks when option enabled
   - Don't infinite loop on circular symlinks

4. **Metadata extraction:**
   ```dart
   test('extracts year from filename', () {
     final metadata = scanner.extractMetadata('Movie.2021.1080p.mkv');
     expect(metadata.year, equals(2021));
     expect(metadata.title, equals('Movie'));
   });
   
   test('removes common tags', () {
     final metadata = scanner.extractMetadata(
       'The.Matrix.1999.1080p.BluRay.x264.mkv'
     );
     expect(metadata.title, equals('The Matrix'));
     expect(metadata.year, equals(1999));
   });
   ```

5. **Error handling:**
   - Handle non-existent directory
   - Handle permission denied
   - Handle unreadable files

6. **Duplicate detection:**
   - Detect same path scanned twice
   - Detect existing database entries

7. **Edge cases:**
   - Empty directory
   - Directory with only hidden files
   - Very long filenames
   - Special characters in filenames
   - Unicode filenames

## Acceptance Criteria

### Functional Requirements

- [ ] Scanner finds all files matching specified extensions in target directory
- [ ] Recursive scanning respects the recursive flag and maxDepth parameter
- [ ] Progress is shown during scan with current file and statistics
- [ ] Items are created with titles extracted from filenames
- [ ] Years are extracted from filenames when present (1900-2030 range)
- [ ] Duplicate files (by path) are skipped with count reported to user
- [ ] Scan operation can be cancelled by user
- [ ] Scan completes within 5 seconds for 1000 files (NFR-02)
- [ ] All user-facing text is in Russian

### Non-Functional Requirements

- [ ] `flutter analyze` reports zero errors
- [ ] All unit tests pass (`flutter test`)
- [ ] DirectoryScanner has minimum 70% test coverage
- [ ] No UI thread blocking during scan (use isolates or async)
- [ ] Handles symlinks safely (no infinite loops)
- [ ] Validates file paths to prevent directory traversal

### Edge Cases Handled

- [ ] Empty directories (show appropriate message)
- [ ] Directories with no matching files (show appropriate message)
- [ ] Permission denied errors (skip file, log error, continue)
- [ ] Very large directories (maxFiles limit enforced)
- [ ] Circular symlinks (detected and skipped)
- [ ] Invalid UTF-8 filenames (handled gracefully)
- [ ] Network drives / removable media (handle disconnect gracefully)

## Threat Model

### Security Considerations

| Threat | Risk Level | Mitigation |
|--------|------------|------------|
| **Path Traversal** | High | Validate all paths are within allowed directory. Use `path.canonicalize()` and verify prefix. Reject paths containing `..` sequences. |
| **Symlink Attack** | High | Never follow symlinks by default. If enabled, track visited inodes to prevent loops. Check symlink target is within allowed scope. |
| **Resource Exhaustion** | Medium | Enforce maxFiles limit (default 10,000). Add timeout for scan operations. Limit recursion depth. Monitor memory usage. |
| **Infinite Recursion** | Medium | Limit recursion depth. Detect circular directory structures. Track visited directories by inode on Unix. |
| **Memory Exhaustion** | Medium | Use streaming API (Stream<ScannedFile>) instead of collecting all results. Process files in batches. |
| **File Handle Exhaustion** | Low | Use `Directory.list()` which handles handles efficiently. Don't keep files open longer than necessary. |
| **Sensitive File Exposure** | Low | Don't scan system directories. Skip hidden files by default. Respect file permissions. |

### Path Validation

```dart
bool isValidScanPath(String path, String basePath) {
  final canonical = File(path).resolveSymbolicLinksSync();
  final canonicalBase = Directory(basePath).resolveSymbolicLinksSync();
  
  // Must be within base path
  if (!canonical.startsWith(canonicalBase)) {
    return false;
  }
  
  // Must exist and be readable
  final entity = FileSystemEntity.typeSync(canonical);
  if (entity == FileSystemEntityType.notFound) {
    return false;
  }
  
  return true;
}
```

### Symlink Handling

```dart
Future<bool> isSafeSymlink(Link link, String basePath) async {
  try {
    final target = await link.resolveSymbolicLinks();
    final canonicalTarget = File(target).resolveSymbolicLinksSync();
    final canonicalBase = Directory(basePath).resolveSymbolicLinksSync();
    
    // Symlink must point within base directory
    return canonicalTarget.startsWith(canonicalBase);
  } catch (e) {
    return false;
  }
}
```

## Implementation Order

1. Create DirectoryScanner service with basic scanning (Task 1, 2)
2. Add extension filtering (Task 3)
3. Implement metadata extraction with tests (Task 4, 9)
4. Create scan progress dialog (Task 5)
5. Add ItemBloc batch creation support (Task 7)
6. Add duplicate detection (Task 8)
7. Integrate into CategoryScreen (Task 6)
8. Full integration testing

## Dependencies

**Pubspec additions:**
```yaml
dependencies:
  file_picker: ^8.0.0+1
  path: ^1.9.0  # Already likely present

dev_dependencies:
  mockito: ^5.4.4  # For mocking in tests
  build_runner: ^2.4.9  # For mockito code generation
```

**Existing code to leverage:**
- `ItemBloc` for item state management
- `AddItem` use case for creating items
- `ItemRepository` for duplicate checking
- `CategoryScreen` for UI integration

## Testing Strategy

### Unit Tests (Priority)

1. DirectoryScanner tests
2. Metadata extraction tests
3. Duplicate detection tests
4. Path validation tests

### Integration Tests

1. Scan → Create items → Verify in database
2. Cancel scan mid-operation
3. Large directory scan performance

### Manual Testing Checklist

- [ ] Scan directory with 1000+ files
- [ ] Cancel scan while running
- [ ] Scan with various filename formats
- [ ] Verify duplicate detection
- [ ] Test with symlinks (should skip)
- [ ] Test on Windows, Linux, macOS
- [ ] Test with permission-restricted directories

## Rollback Plan

If issues are discovered:
1. Revert `lib/core/services/directory_scanner.dart`
2. Revert changes to `CategoryScreen`
3. Revert BLoC changes
4. Database remains unaffected (items already created remain)

## Post-Implementation

After completing this phase:
1. Run `flutter analyze` and fix any issues
2. Run `flutter test` and ensure all pass
3. Create `10-SUMMARY.md` with:
   - What was implemented
   - Design decisions made
   - Performance metrics
   - Known limitations
   - Future improvements identified

## Verification

```bash
# Static analysis
flutter analyze

# Run tests
flutter test test/core/services/directory_scanner_test.dart

# Full test suite
flutter test

# Check coverage (if configured)
flutter test --coverage
```

## Output

**Deliverables:**
1. `lib/core/services/directory_scanner.dart` - Core scanning service
2. `lib/presentation/widgets/scan_progress_dialog.dart` - Progress UI
3. `lib/presentation/blocs/item/item_event.dart` - Batch events (modified)
4. `lib/presentation/blocs/item/item_bloc.dart` - Batch handling (modified)
5. `lib/presentation/screens/category/category_screen.dart` - UI integration (modified)
6. `lib/core/di/injection.dart` - Service registration (modified)
7. `test/core/services/directory_scanner_test.dart` - Unit tests
8. `10-SUMMARY.md` - Post-implementation summary

## Notes

- Keep UI responsive - use `compute()` or isolates for heavy parsing
- Russian text for all user-facing strings
- Follow existing BLoC patterns
- Reuse existing components where possible
- Consider adding "Recent scan locations" feature in future
- Future enhancement: Remember last used extensions per category
