# PC Media Center - Agent Guidelines

## Development Methodology: Test-Driven Development (TDD)

All development MUST follow TDD principles: **Red → Green → Refactor**

---

## TDD Cycle

### 1. RED: Write Failing Test First
- **BEFORE writing any implementation code**, write a test that fails
- Test should define the expected behavior clearly
- Run test to confirm it fails (RED state)
- Commit: `test(module): add failing test for [feature]`

### 2. GREEN: Write Minimum Implementation
- Write just enough code to make the test pass
- Don't worry about perfection - make it work
- Run test to confirm it passes (GREEN state)
- Commit: `feat(module): implement [feature] to pass test`

### 3. REFACTOR: Improve Code Quality
- Clean up the implementation
- Keep all tests passing
- Improve naming, reduce duplication, optimize
- Run full test suite to ensure no regressions
- Commit: `refactor(module): improve [feature] implementation`

---

## Testing Standards

### Unit Tests (Required for All Logic)
```dart
// Pattern: Arrange → Act → Assert
group('LauncherService', () {
  test('should return success when file exists', () async {
    // Arrange
    final service = LauncherService();
    final existingFile = 'test.txt';
    
    // Act
    final result = await service.launch(existingFile);
    
    // Assert
    expect(result.success, isTrue);
    expect(result.errorMessage, isNull);
  });
});
```

### Widget Tests (Required for All Screens)
```dart
testWidgets('ItemDetailScreen displays item title', (tester) async {
  // Build widget
  await tester.pumpWidget(
    MaterialApp(
      home: ItemDetailScreen(itemId: 1),
    ),
  );
  
  // Verify
  expect(find.text('Test Item'), findsOneWidget);
});
```

### BLoC Tests (Required for All BLoCs)
```dart
blocTest<ItemBloc, ItemState>(
  'emits [ItemLoading, ItemLoaded] when GetItems succeeds',
  build: () => ItemBloc(mockRepository),
  act: (bloc) => bloc.add(GetItems()),
  expect: () => [
    isA<ItemLoading>(),
    isA<ItemLoaded>(),
  ],
);
```

---

## File Organization

```
lib/
├── feature/
│   ├── feature_service.dart
│   └── feature_bloc.dart
test/
├── feature/
│   ├── feature_service_test.dart      # Unit tests
│   ├── feature_bloc_test.dart         # BLoC tests
│   └── feature_widget_test.dart       # Widget tests
```

---

## Commit Message Convention (TDD Style)

| Stage | Pattern | Example |
|-------|---------|---------|
| Test (RED) | `test(module): add failing test for [feature]` | `test(launcher): add failing test for Windows file launch` |
| Feature (GREEN) | `feat(module): implement [feature]` | `feat(launcher): implement Windows Process.run` |
| Refactor | `refactor(module): improve [aspect]` | `refactor(launcher): extract platform detection` |
| Fix | `fix(module): resolve [issue]` | `fix(launcher): handle spaces in file paths` |

---

## Development Workflow

### Before Starting Task
1. Read existing tests for the module
2. Understand current test patterns
3. Plan test cases for new feature

### During Implementation
1. **Write test** → Run (should fail) → Commit
2. **Write code** → Run test (should pass) → Commit  
3. **Refactor** → Run all tests (should pass) → Commit
4. **Repeat** for next feature

### Before Committing
- [ ] All new tests pass
- [ ] All existing tests pass (`flutter test`)
- [ ] No analyzer errors (`flutter analyze`)
- [ ] Code follows project conventions
- [ ] Tests cover success and error cases

---

## Test Coverage Requirements

| Component | Minimum Coverage |
|-----------|------------------|
| Services | 90% |
| BLoCs | 85% |
| Repositories | 80% |
| Screens | 60% (critical paths) |
| Widgets | 50% (reusable only) |

---

## Testing Best Practices

### DO
- ✅ Test one thing per test
- ✅ Use descriptive test names
- ✅ Test edge cases (null, empty, invalid)
- ✅ Mock external dependencies
- ✅ Use `setUp`/`tearDown` for common fixtures
- ✅ Test error paths, not just success

### DON'T
- ❌ Skip tests because "it's simple"
- ❌ Test implementation details (test behavior)
- ❌ Share state between tests
- ❌ Use real network/DB in unit tests
- ❌ Write tests after implementation (violates TDD)

---

## Platform-Specific Testing

### Windows Tests
```dart
test('Windows launcher uses start command', () {
  // Mock Platform.isWindows = true
  // Verify Process.run called with ['cmd', '/c', 'start', ...]
});
```

### Linux Tests
```dart
test('Linux launcher uses xdg-open', () {
  // Mock Platform.isLinux = true
  // Verify Process.run called with ['xdg-open', path]
});
```

### macOS Tests
```dart
test('macOS launcher uses open command', () {
  // Mock Platform.isMacOS = true
  // Verify Process.run called with ['open', path]
});
```

---

## Mocking Guidelines

### Use mocktail for Dart/Flutter
```dart
import 'package:mocktail/mocktail.dart';

class MockProcessRunner extends Mock implements ProcessRunner {}

setUp(() {
  mockRunner = MockProcessRunner();
  when(() => mockRunner.run(any(), any()))
      .thenAnswer((_) async => ProcessResult(0, 0, '', ''));
});
```

### Register Fallback Values
```dart
setUpAll(() {
  registerFallbackValue(ItemEntity());
  registerFallbackValue(LaunchOptions());
});
```

---

## Running Tests

### During Development (Fast Feedback)
```bash
# Watch mode - run tests on file changes
flutter test --watch

# Specific file
flutter test test/core/services/launcher_service_test.dart

# Specific test
flutter test --plain-name "should return success"
```

### Before Commit (Full Verification)
```bash
# All tests
flutter test

# With coverage
flutter test --coverage

# Analyze
flutter analyze

# Full check
flutter analyze && flutter test
```

---

## Example: TDD Implementation Flow

### Feature: LauncherService

**Step 1: Write Failing Test**
```dart
// test/core/services/launcher_service_test.dart
test('should launch file on Windows', () async {
  final service = LauncherServiceWindows();
  final result = await service.launch('test.exe');
  expect(result.success, isTrue);
});
```
*Run: FAIL (class doesn't exist)*
*Commit: `test(launcher): add failing test for Windows launch`*

**Step 2: Minimum Implementation**
```dart
// lib/core/services/launcher_service.dart
class LauncherServiceWindows {
  Future<LaunchResult> launch(String path) async {
    await Process.run('cmd', ['/c', 'start', '', path]);
    return LaunchResult.success();
  }
}
```
*Run: PASS*
*Commit: `feat(launcher): implement Windows launcher`*

**Step 3: Add Error Case Test**
```dart
test('should return error when file not found', () async {
  final service = LauncherServiceWindows();
  final result = await service.launch('nonexistent.exe');
  expect(result.success, isFalse);
  expect(result.errorMessage, contains('не найден'));
});
```
*Run: FAIL*
*Commit: `test(launcher): add failing test for file not found`*

**Step 4: Implement Error Handling**
```dart
Future<LaunchResult> launch(String path) async {
  if (!File(path).existsSync()) {
    return LaunchResult.failure('Файл не найден: $path');
  }
  await Process.run('cmd', ['/c', 'start', '', path]);
  return LaunchResult.success();
}
```
*Run: PASS*
*Commit: `feat(launcher): add file existence check`*

**Step 5: Refactor**
```dart
// Extract common interface, improve naming
abstract class LauncherService {
  Future<LaunchResult> launch(String path);
}

class WindowsLauncherService implements LauncherService {
  @override
  Future<LaunchResult> launch(String path) {
    // Implementation...
  }
}
```
*Run: PASS*
*Commit: `refactor(launcher): extract LauncherService interface`*

---

## Emergency Procedures

### Tests Failing Unexpectedly
1. Check if test is flaky (run 3 times)
2. Verify mock setup is correct
3. Check for shared state between tests
4. Use `setUp`/`tearDown` properly

### Can't Write Test First
If truly blocked:
1. Spike: Write exploratory code (throw away after)
2. Learn from spike
3. Delete spike code
4. Write test
5. Implement properly

### Legacy Code (No Tests)
1. Characterization test: Write test for current behavior
2. Verify test passes
3. Now you have safety net
4. Refactor with confidence

---

## Phase Execution with TDD

### For Each Task in Phase:
1. Read task requirements
2. Write failing test(s)
3. Commit: `test(module): ...`
4. Implement to pass test
5. Commit: `feat(module): ...`
6. Refactor if needed
7. Commit: `refactor(module): ...`
8. Move to next task

### Phase Completion Checklist
- [ ] All tests pass (`flutter test`)
- [ ] No analyzer errors (`flutter analyze`)
- [ ] Coverage meets minimum requirements
- [ ] All acceptance criteria have tests
- [ ] Error cases tested
- [ ] Integration between components tested

---

*Document Version: 1.0*  
*Created: 2026-04-19*  
*TDD Mandate: All code must have tests written first*
