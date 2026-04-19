# Codebase Concerns

**Analysis Date:** 2026-04-19

## Summary

This document identifies critical bugs, technical debt, security concerns, and architectural issues in the PC Media Center Flutter application. Issues are categorized by severity and include specific locations and remediation guidance.

---

## Critical Issues (Fix Immediately)

### 1. Undefined Variable Reference
- **Type:** Bug
- **Location:** `lib/presentation/screens/category/category_screen.dart:157`
- **Severity:** Critical
- **Description:** ItemCard references undefined `index` variable in Text widget showing item number
- **Impact:** Build will fail with compile-time error
- **Fix:** Pass index as parameter to ItemCard or compute from list position

### 2. Incorrect Import Paths in CategoryBloc
- **Type:** Bug
- **Location:** `lib/presentation/blocs/category/category_bloc.dart:3-4`
- **Severity:** Critical
- **Description:** Import paths are wrong: `../../domain/entities/category.dart` should be `../../../domain/entities/category.dart`
- **Impact:** Build will fail with "Target of URI doesn't exist" error
- **Fix:** Change to:
  ```dart
  import '../../../domain/entities/category.dart';
  import '../../../domain/repositories/category_repository.dart';
  ```

### 3. Missing Import in Injection Container
- **Type:** Bug
- **Location:** `lib/core/di/injection.dart:57`
- **Severity:** Critical
- **Description:** ItemBloc is used on line 57 but not imported
- **Impact:** Build will fail with "Undefined name 'ItemBloc'" error
- **Fix:** Add import:
  ```dart
  import '../../presentation/blocs/item/item_bloc.dart';
  ```

### 4. Home Screen Dialog Logic Bug
- **Type:** Bug
- **Location:** `lib/presentation/screens/home/home_screen.dart:28-31`
- **Severity:** Critical
- **Description:** Dialog pops immediately when user starts typing due to onChanged calling pop()
- **Impact:** Users cannot type category names - dialog closes on first keystroke
- **Fix:** Remove onChanged handler, use controller and read value on button press instead

---

## High Severity Issues

### 5. Memory Leak in Category Screen
- **Type:** Resource Leak
- **Location:** `lib/presentation/screens/category/category_screen.dart:48-58`
- **Severity:** High
- **Description:** Stream subscription from `bloc.stream.listen()` is never cancelled
- **Impact:** Memory leak - multiple subscriptions accumulate on each load
- **Fix:** Store subscription in state and cancel in dispose():
  ```dart
  StreamSubscription? _subscription;
  
  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
  ```

### 6. Improper Bloc Lifecycle Management
- **Type:** Architecture
- **Location:** `lib/presentation/screens/category/category_screen.dart:40`
- **Severity:** High
- **Description:** Creates new ItemBloc via getIt instead of using BlocProvider; ItemBloc registered as singleton but shouldn't be
- **Impact:** State management issues, potential conflicts between screens
- **Fix:** Register ItemBloc as factory (not singleton) and use BlocProvider:
  ```dart
  getIt.registerFactory<ItemBloc>(...);
  ```

### 7. Using print() for Error Logging
- **Type:** Code Quality
- **Location:** `lib/data/repositories/search_repository_impl.dart:68`
- **Severity:** High
- **Description:** Uses print() statement for error logging instead of proper logger
- **Impact:** Logs not captured in production; violates Flutter lints
- **Fix:** Use a logger package (e.g., logger, fancy_logger) or debugPrint with structured logging

### 8. Silent Error Swallowing
- **Type:** Error Handling
- **Location:** `lib/data/repositories/search_repository_impl.dart:100-102`, `135-137`
- **Severity:** High
- **Description:** Empty catch blocks silently discard parsing errors
- **Impact:** Invalid data is silently skipped with no logging or metrics
- **Fix:** Log errors with context:
  ```dart
  } catch (e, stackTrace) {
    logger.warning('Failed to parse search result', e, stackTrace);
  }
  ```

### 9. No HTTP Client Reuse or Timeout
- **Type:** Performance/Resource
- **Location:** `lib/data/datasources/remote/tmdb_api.dart:14`, `kinopoisk_api.dart:14`
- **Severity:** High
- **Description:** Creates new Dio() instance on every API call with no timeout configuration
- **Impact:** Resource exhaustion, hanging requests, no connection pooling
- **Fix:** Use singleton Dio instance with proper configuration:
  ```dart
  final dio = Dio(BaseOptions(
    connectTimeout: Duration(seconds: 5),
    receiveTimeout: Duration(seconds: 10),
  ));
  ```

### 10. Generic Exception Anti-pattern
- **Type:** Error Handling
- **Location:** Multiple files (12 occurrences across tmdb_api.dart, kinopoisk_api.dart, metadata_search_api.dart, search_repository_impl.dart)
- **Severity:** High
- **Description:** Throws generic `Exception` with string message instead of domain-specific exceptions
- **Impact:** Callers cannot distinguish between retryable and fatal errors
- **Fix:** Create domain exceptions:
  ```dart
  class ApiException implements Exception {
    final String message;
    final bool isRetryable;
    ApiException(this.message, {this.isRetryable = false});
  }
  ```

### 11. Zero Test Coverage
- **Type:** Testing
- **Location:** `test/widget_test.dart`
- **Severity:** High
- **Description:** Only contains placeholder test that always passes
- **Impact:** No safety net for regressions; cannot safely refactor
- **Fix:** Add unit tests for:
  - All BLoC state transitions
  - Repository methods
  - Use case logic
  - API client error handling

### 12. Stub Screens in Production Code
- **Type:** Completeness
- **Location:** 
  - `lib/presentation/screens/item_form/item_form_screen.dart`
  - `lib/presentation/screens/search/search_screen.dart`
  - `lib/presentation/screens/item_detail/item_detail_screen.dart`
  - `lib/presentation/screens/settings/settings_screen.dart`
- **Severity:** High
- **Description:** Multiple screens are just stubs with placeholder text
- **Impact:** Non-functional UI features
- **Fix:** Implement actual functionality or hide routes until ready

---

## Medium Severity Issues

### 13. Pagination Off-by-One Error
- **Type:** Logic Error
- **Location:** `lib/domain/usecases/items/get_items_by_category.dart:27`
- **Severity:** Medium
- **Description:** `start = offset + 1` causes first item to be skipped on initial load
- **Impact:** First item in category never displayed
- **Fix:** Use zero-based indexing consistently: `final start = offset;`

### 14. Hardcoded Strings Throughout
- **Type:** Maintainability
- **Location:** Multiple files
- **Severity:** Medium
- **Description:** UI strings hardcoded in Russian and English without i18n
- **Impact:** Cannot localize app; inconsistent language usage
- **Fix:** Move all strings to AppLocalizations:
  ```dart
  Text(AppLocalizations.of(context)!.newCategory)
  ```

### 15. Hardcoded API URLs
- **Type:** Maintainability
- **Location:** `lib/data/datasources/remote/tmdb_api.dart:7`, `kinopoisk_api.dart:7`, `search_repository_impl.dart:88,123`
- **Severity:** Medium
- **Description:** API base URLs and image CDN URLs hardcoded
- **Impact:** Cannot configure different environments (dev/staging/prod)
- **Fix:** Use configuration class or environment variables

### 16. Unsafe Type Casting
- **Type:** Type Safety
- **Location:** `lib/data/repositories/search_repository_impl.dart:79`, `114`, `lib/data/datasources/remote/metadata_search_api.dart:18-20`
- **Severity:** Medium
- **Description:** Casts `List<dynamic>` to expected types without validation
- **Impact:** Runtime crashes if API response structure changes
- **Fix:** Use proper JSON serialization with generated models or validate before cast

### 17. Hardcoded Category Name in Router
- **Type:** UX Issue
- **Location:** `lib/app/router.dart:18`
- **Severity:** Medium
- **Description:** Shows "Категория ${id}" as placeholder instead of actual category name
- **Impact:** Poor user experience
- **Fix:** Fetch category name from repository or pass in route parameters

### 18. Missing Error States in UI
- **Type:** UX
- **Location:** `lib/presentation/screens/home/home_screen.dart:89`, `category_screen.dart:79-80`
- **Severity:** Medium
- **Description:** Empty Container shown for unhandled states; no error UI
- **Impact:** Users see blank screen on errors
- **Fix:** Add proper error widget with retry button

### 19. No Input Validation on Category Name
- **Type:** Validation
- **Location:** `lib/presentation/screens/home/home_screen.dart:23-53`
- **Severity:** Medium
- **Description:** No validation beyond empty check; allows special characters, very long names
- **Impact:** Potential UI issues, database constraints
- **Fix:** Add validation for length, special characters, duplicates

### 20. Unused onTap/onEdit Handlers
- **Type:** Completeness
- **Location:** `lib/presentation/screens/home/home_screen.dart:76-77`
- **Severity:** Medium
- **Description:** CategoryCard onTap and onEdit are empty callbacks
- **Impact:** UI elements appear interactive but do nothing
- **Fix:** Implement navigation or disable buttons until implemented

### 21. Potential Division by Zero
- **Type:** Logic Error
- **Location:** `lib/presentation/widgets/common/category_card.dart:85`
- **Severity:** Low-Medium
- **Description:** `name.hashCode.abs % 8` could theoretically have issues
- **Impact:** App crash on edge case
- **Fix:** Ensure modulo handles all cases properly

### 22. No Retry Mechanism for API Calls
- **Type:** Resilience
- **Location:** All API clients
- **Severity:** Medium
- **Description:** API calls fail immediately with no retry logic
- **Impact:** Poor UX on flaky networks
- **Fix:** Implement exponential backoff retry for idempotent requests

### 23. No API Response Caching
- **Type:** Performance
- **Location:** API clients
- **Severity:** Medium
- **Description:** _cacheResult stores in local cache but no TTL or cache strategy
- **Impact:** Stale data, unnecessary API calls
- **Fix:** Implement proper cache with expiration policy

---

## Low Severity Issues

### 24. Key? Instead of super.key
- **Type:** Code Style
- **Location:** `lib/presentation/screens/home/home_screen.dart:8`, `lib/presentation/widgets/common/category_card.dart:12`
- **Severity:** Low
- **Description:** Uses `Key? key` instead of modern `super.key` pattern
- **Fix:** Update to `const HomeScreen({super.key});`

### 25. Inconsistent Constructor Syntax
- **Type:** Code Style
- **Location:** Multiple files
- **Severity:** Low
- **Description:** Mix of `super.key` and `Key? key` patterns
- **Fix:** Standardize on `super.key` throughout codebase

### 26. Analysis Options Not Strict
- **Type:** Configuration
- **Location:** `analysis_options.yaml`
- **Severity:** Low
- **Description:** Only uses basic flutter_lints, no strict mode or custom rules
- **Impact:** Missing potential issues at analysis time
- **Fix:** Add stricter lints:
  ```yaml
  include: package:flutter_lints/flutter.yaml
  linter:
    rules:
      avoid_print: true
      prefer_single_quotes: true
      avoid_dynamic_calls: true
  ```

---

## Security Considerations

### 27. API Keys in Plain Text (Potential)
- **Type:** Security
- **Location:** `lib/core/di/injection.dart`
- **Severity:** Medium
- **Description:** API keys likely stored in plain text and bundled in app
- **Impact:** Keys can be extracted from app binary
- **Recommendation:** Store in secure storage or use backend proxy

### 28. No HTTPS Certificate Pinning
- **Type:** Security
- **Location:** API clients
- **Severity:** Low
- **Description:** No certificate pinning for API calls
- **Impact:** Vulnerable to MITM attacks on public WiFi
- **Recommendation:** Implement pinning for production

### 29. No Input Sanitization
- **Type:** Security
- **Location:** `lib/data/datasources/remote/tmdb_api.dart:16`, `kinopoisk_api.dart:16`
- **Severity:** Low
- **Description:** Query parameters passed directly to API without sanitization
- **Impact:** Potential injection attacks
- **Fix:** URL-encode all query parameters

---

## Test Coverage Gaps

| Component | Coverage | Risk |
|-----------|----------|------|
| BLoCs | 0% | High - Core business logic untested |
| Repositories | 0% | High - Data layer untested |
| Use Cases | 0% | High - Domain logic untested |
| API Clients | 0% | High - Network error handling untested |
| Screens | 0% | Medium - UI interaction untested |
| Models | 0% | Low - Data structures untested |

### Critical Untested Paths:
1. Error states in all BLoCs
2. API timeout and retry scenarios
3. Database migration paths
4. State transitions with empty data
5. Concurrent category operations

---

## Architecture Drift

### Current Issues:
1. **DI Configuration:** Mix of factory and singleton registrations without clear lifecycle strategy
2. **Error Handling:** Inconsistent - some places return empty lists, others throw exceptions
3. **State Management:** Direct bloc access instead of using BlocProvider/BlocBuilder
4. **Navigation:** MaterialPageRoute mixed with go_router in same app

### Recommended Patterns:
1. Use `Result<T, E>` type for operations that can fail
2. Implement consistent error boundary widgets
3. Separate domain exceptions from infrastructure errors
4. Use BLoC observer for global error handling and analytics

---

## Fix Priority Matrix

### Immediate (This Sprint):
1. Fix undefined index variable (category_screen.dart:157)
2. Fix CategoryBloc import paths
3. Add missing ItemBloc import
4. Fix home screen dialog onChanged bug
5. Cancel stream subscriptions properly

### This Week:
6. Replace print() with proper logger
7. Add error logging to silent catch blocks
8. Implement singleton Dio with timeouts
9. Create domain-specific exception classes
10. Add basic BLoC tests

### Next Sprint:
11. Implement stub screens or hide routes
12. Fix pagination off-by-one error
13. Move hardcoded strings to i18n
14. Add input validation
15. Implement error UI states

---

## Additional Architectural Concerns

### 30. Domain Layer Dependencies
- **Potential Issue:** Verify no imports from `data/` or `presentation/` in domain layer
- **Check:** Run static analysis to confirm no cross-layer imports
- **Files to review:** `lib/domain/entities/*.dart`, `lib/domain/repositories/*.dart`

### 31. BLoC State Complexity
- **Concern:** As app grows, state objects may become complex
- **Recommendation:** Split large states into smaller, focused BLoCs
- **Current Status:** Currently manageable but monitor growth

### 32. Database Migration Strategy
- **Concern:** Drift handles migrations, but large schema changes need testing
- **Current:** MigrationStrategy onUpgrade is empty (line 40 in app_database.dart)
- **Risk:** Future schema changes may cause data loss

### 33. Repository Interface Coupling
- **Concern:** Verify clean separation between repository interfaces
- **Check:** Ensure repositories don't depend on each other through interfaces

### 34. Icon Extraction Reliability
- **Concern:** Platform-specific icon extraction with fallback to placeholders
- **Risk:** Some executables may not have extractable icons
- **Test:** Verify on various application types

### 35. File Launching Edge Cases
- **Concern:** OS-specific commands for file launching
- **Risks:**
  - Files without associated applications
  - Permission errors accessing protected directories
- **Fix:** Add user confirmation dialogs and error handling

### 36. Image Caching Strategy
- **Concern:** Unbounded cache growth with `cached_network_image`
- **Risk:** Disk space consumption over time
- **Fix:** Implement LRU cache with size limits

### 37. Search Performance
- **Concern:** Online search via TMDB/Kinopoisk without local indexing
- **Risks:**
  - API rate limits during heavy usage
  - Network latency affects UX
  - No offline search capability
- **Fix:** Implement local search index and debouncing

### 38. Local Data Exposure
- **Concern:** Database file readable by any user with app directory access
- **Risk:** Sensitive user data exposure if device compromised
- **Mitigation:** Consider database encryption for sensitive data

### 39. Accessibility
- **Concern:** Keyboard navigation and screen reader compatibility unknown
- **Current:** `FocusableWidget` wrapper exists but coverage unclear
- **Test:** Verify with screen readers and keyboard-only navigation

### 40. Color Contrast
- **Concern:** May not meet WCAG AA/AAA contrast requirements
- **Fix:** Run automated accessibility audits

---

*Analysis completed: 2026-04-19*
*Total Issues Identified: 40 (4 Critical, 12 High, 24 Medium/Low)*
