# Phase 7: Fix Critical Code Issues

**Goal:** Address all critical, high, and medium concerns identified in codebase investigation.

## Critical Issues (5)

1. **COMPILATION ERROR**: `category_bloc.dart` has wrong import paths
   - Line 3-4: Should be `../../../domain/...` not `../../domain/...`
   - **Impact:** Build fails

2. **COMPILATION ERROR**: `injection.dart` missing ItemBloc import
   - Line 57: Uses ItemBloc but it's not imported
   - **Impact:** Build fails

3. **RUNTIME ERROR**: `category_screen.dart` undefined variable
   - Line 157: References `index` which is not defined in ItemCard
   - **Impact:** App crashes when viewing category

4. **MEMORY LEAK**: `category_screen.dart` bloc not disposed
   - Creates new ItemBloc but never disposes it
   - **Impact:** Memory leak on screen navigation

5. **UI BUG**: `home_screen.dart` dialog closes on type
   - Lines 28-31: onChanged pops dialog immediately when typing starts
   - **Impact:** Cannot enter text in dialog

## High Priority Issues (6)

6. **LOGGING**: print() instead of proper logger
7. **ERROR HANDLING**: Silent catch blocks swallowing errors
8. **NETWORK**: New Dio() instances without timeout/configuration
9. **EXCEPTIONS**: Generic Exception throwing everywhere
10. **TESTS**: No test coverage (only placeholder test)
11. **STUBS**: ItemFormScreen, SearchScreen, ItemDetailScreen are empty stubs

## Medium Priority Issues (6)

12. **HARDCODING**: API URLs and strings throughout
13. **ROUTER**: Hardcoded category name
14. **PAGINATION**: Off-by-one error in GetItemsByCategoryImpl
15. **STATE ACCESS**: CategoryBloc assumes always CategoryLoaded
16. **NULL SAFETY**: Missing null checks
17. **DOCUMENTATION**: Missing API documentation

## References
- Full investigation: `.planning/codebase/CONCERNS.md`
- Architecture: `.planning/codebase/ARCHITECTURE.md`
- Conventions: `.planning/codebase/CONVENTIONS.md`
