# Graph Report - /Users/simkin/Developent/opencode_projects/pc_media_center  (2026-04-19)

## Corpus Check
- 77 files · ~27,176 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 351 nodes · 374 edges · 32 communities detected
- Extraction: 97% EXTRACTED · 3% INFERRED · 0% AMBIGUOUS · INFERRED: 11 edges (avg confidence: 0.8)
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- [[_COMMUNITY_Community 0|Community 0]]
- [[_COMMUNITY_Community 1|Community 1]]
- [[_COMMUNITY_Community 2|Community 2]]
- [[_COMMUNITY_Community 3|Community 3]]
- [[_COMMUNITY_Community 4|Community 4]]
- [[_COMMUNITY_Community 5|Community 5]]
- [[_COMMUNITY_Community 6|Community 6]]
- [[_COMMUNITY_Community 7|Community 7]]
- [[_COMMUNITY_Community 8|Community 8]]
- [[_COMMUNITY_Community 9|Community 9]]
- [[_COMMUNITY_Community 10|Community 10]]
- [[_COMMUNITY_Community 11|Community 11]]
- [[_COMMUNITY_Community 12|Community 12]]
- [[_COMMUNITY_Community 13|Community 13]]
- [[_COMMUNITY_Community 14|Community 14]]
- [[_COMMUNITY_Community 15|Community 15]]
- [[_COMMUNITY_Community 16|Community 16]]
- [[_COMMUNITY_Community 17|Community 17]]
- [[_COMMUNITY_Community 18|Community 18]]
- [[_COMMUNITY_Community 19|Community 19]]
- [[_COMMUNITY_Community 20|Community 20]]
- [[_COMMUNITY_Community 21|Community 21]]
- [[_COMMUNITY_Community 22|Community 22]]
- [[_COMMUNITY_Community 23|Community 23]]
- [[_COMMUNITY_Community 24|Community 24]]
- [[_COMMUNITY_Community 25|Community 25]]
- [[_COMMUNITY_Community 26|Community 26]]
- [[_COMMUNITY_Community 27|Community 27]]
- [[_COMMUNITY_Community 28|Community 28]]
- [[_COMMUNITY_Community 29|Community 29]]
- [[_COMMUNITY_Community 30|Community 30]]
- [[_COMMUNITY_Community 31|Community 31]]

## God Nodes (most connected - your core abstractions)
1. `_` - 19 edges
2. `package:flutter/material.dart` - 13 edges
3. `package:drift/drift.dart` - 8 edges
4. `../../../domain/entities/item.dart` - 7 edges
5. `Create()` - 7 edges
6. `package:equatable/equatable.dart` - 6 edges
7. `Destroy()` - 6 edges
8. `../database/app_database.dart` - 5 edges
9. `../../../domain/entities/category.dart` - 5 edges
10. `OnCreate()` - 5 edges

## Surprising Connections (you probably didn't know these)
- `OnCreate()` --calls--> `RegisterPlugins()`  [INFERRED]
  /Users/simkin/Developent/opencode_projects/pc_media_center/windows/runner/flutter_window.cpp → /Users/simkin/Developent/opencode_projects/pc_media_center/windows/flutter/generated_plugin_registrant.cc
- `OnCreate()` --calls--> `Show()`  [INFERRED]
  /Users/simkin/Developent/opencode_projects/pc_media_center/windows/runner/flutter_window.cpp → /Users/simkin/Developent/opencode_projects/pc_media_center/windows/runner/win32_window.cpp
- `wWinMain()` --calls--> `CreateAndAttachConsole()`  [INFERRED]
  /Users/simkin/Developent/opencode_projects/pc_media_center/windows/runner/main.cpp → /Users/simkin/Developent/opencode_projects/pc_media_center/windows/runner/utils.cpp
- `wWinMain()` --calls--> `SetQuitOnClose()`  [INFERRED]
  /Users/simkin/Developent/opencode_projects/pc_media_center/windows/runner/main.cpp → /Users/simkin/Developent/opencode_projects/pc_media_center/windows/runner/win32_window.cpp
- `main()` --calls--> `my_application_new()`  [INFERRED]
  /Users/simkin/Developent/opencode_projects/pc_media_center/linux/runner/main.cc → /Users/simkin/Developent/opencode_projects/pc_media_center/linux/runner/my_application.cc

## Communities

### Community 0 - "Community 0"
Cohesion: 0.06
Nodes (27): dark_theme.dart, light_theme.dart, package:flutter/material.dart, package:pc_media_center/l10n/generated/app_localizations.dart, router.dart, theme/app_theme.dart, App, build (+19 more)

### Community 1 - "Community 1"
Cohesion: 0.11
Nodes (24): OnCreate(), RegisterPlugins(), wWinMain(), CreateAndAttachConsole(), GetCommandLineArguments(), Utf8FromUtf16(), Create(), Destroy() (+16 more)

### Community 2 - "Community 2"
Cohesion: 0.08
Nodes (23): category_event.dart, category_state.dart, ../database/app_database.dart, ../../database/daos/categories_dao.dart, ../../database/daos/items_dao.dart, ../datasources/local/local_data_source.dart, ../../../domain/entities/category.dart, ../../domain/repositories/category_repository.dart (+15 more)

### Community 3 - "Community 3"
Cohesion: 0.09
Nodes (19): ../app_database.dart, categories_table.dart, daos/categories_dao.dart, daos/items_dao.dart, dart:io, package:drift/drift.dart, package:drift/native.dart, package:path/path.dart (+11 more)

### Community 4 - "Community 4"
Cohesion: 0.09
Nodes (16): package:equatable/equatable.dart, CategoryEntity, ItemEntity, SearchResult, CategoryError, CategoryInitial, CategoryLoaded, CategoryLoading (+8 more)

### Community 5 - "Community 5"
Cohesion: 0.11
Nodes (17): app_localizations.dart, app_localizations_en.dart, app_localizations_ru.dart, dart:async, package:flutter_localizations/flutter_localizations.dart, package:flutter/widgets.dart, package:intl/intl.dart, AppLocalizations (+9 more)

### Community 6 - "Community 6"
Cohesion: 0.1
Nodes (18): ../../data/database/app_database.dart, ../../data/datasources/local/local_data_source.dart, ../../data/repositories/category_repository_impl.dart, ../../domain/usecases/categories/add_category.dart, ../../domain/usecases/categories/delete_category.dart, ../../domain/usecases/categories/get_categories.dart, ../../domain/usecases/categories/update_category.dart, ../../domain/usecases/items/add_item.dart (+10 more)

### Community 7 - "Community 7"
Cohesion: 0.12
Nodes (18): _, CategoriesCompanion, Category, copyWith, copyWithCompanion, f, Function, Item (+10 more)

### Community 8 - "Community 8"
Cohesion: 0.12
Nodes (14): ../datasources/remote/kinopoisk_api.dart, ../datasources/remote/tmdb_api.dart, ../../domain/entities/search_result.dart, ../../domain/repositories/search_repository.dart, ../local/local_data_source.dart, package:dio/dio.dart, _cacheResult, Exception (+6 more)

### Community 9 - "Community 9"
Cohesion: 0.12
Nodes (14): app/app.dart, ../../blocs/category/category_bloc.dart, ../../../core/di/injection.dart, configureDependencies, AlertDialog, BlocProvider, build, CategoryCard (+6 more)

### Community 10 - "Community 10"
Cohesion: 0.13
Nodes (12): ../../../data/repositories/item_repository_impl.dart, ../../../domain/entities/item.dart, ItemEntity, _parseItemType, toDbString, toEntity, GetItemsByCategory, GetItemsByCategoryImpl (+4 more)

### Community 11 - "Community 11"
Cohesion: 0.14
Nodes (4): fl_register_plugins(), main(), my_application_activate(), my_application_new()

### Community 12 - "Community 12"
Cohesion: 0.2
Nodes (7): ../../entities/item.dart, ../../repositories/item_repository.dart, ItemRepository, AddItem, DeleteItem, SearchItems, UpdateItem

### Community 13 - "Community 13"
Cohesion: 0.18
Nodes (7): ../../entities/category.dart, ../../repositories/category_repository.dart, CategoryRepository, AddCategory, DeleteCategory, GetCategories, UpdateCategory

### Community 14 - "Community 14"
Cohesion: 0.18
Nodes (10): ../../blocs/item/item_bloc.dart, ../item_detail/item_detail_screen.dart, build, Card, CategoryScreen, _CategoryScreenState, Container, initState (+2 more)

### Community 15 - "Community 15"
Cohesion: 0.25
Nodes (7): package:go_router/go_router.dart, ../presentation/screens/category/category_screen.dart, ../presentation/screens/home/home_screen.dart, ../presentation/screens/item_detail/item_detail_screen.dart, ../presentation/screens/item_form/item_form_screen.dart, ../presentation/screens/search/search_screen.dart, ../presentation/screens/settings/settings_screen.dart

### Community 16 - "Community 16"
Cohesion: 0.33
Nodes (3): RegisterGeneratedPlugins(), MainFlutterWindow, NSWindow

### Community 17 - "Community 17"
Cohesion: 0.33
Nodes (5): AddCategoryEvent, CategoryEvent, DeleteCategoryEvent, LoadCategories, UpdateCategoryEvent

### Community 18 - "Community 18"
Cohesion: 0.4
Nodes (2): AppDelegate, FlutterAppDelegate

### Community 19 - "Community 19"
Cohesion: 0.4
Nodes (4): kinopoisk_api.dart, tmdb_api.dart, Exception, MetadataSearchApi

### Community 20 - "Community 20"
Cohesion: 0.4
Nodes (1): FlutterWindow()

### Community 21 - "Community 21"
Cohesion: 0.5
Nodes (2): RunnerTests, XCTestCase

### Community 22 - "Community 22"
Cohesion: 0.67
Nodes (2): package:flutter_test/flutter_test.dart, main

### Community 23 - "Community 23"
Cohesion: 0.67
Nodes (2): ../entities/search_result.dart, SearchRepository

### Community 24 - "Community 24"
Cohesion: 2.0
Nodes (2): _, CategoriesDaoManager

### Community 25 - "Community 25"
Cohesion: 2.0
Nodes (2): _, ItemsDaoManager

### Community 26 - "Community 26"
Cohesion: 1.0
Nodes (0): 

### Community 27 - "Community 27"
Cohesion: 1.0
Nodes (0): 

### Community 28 - "Community 28"
Cohesion: 1.0
Nodes (0): 

### Community 29 - "Community 29"
Cohesion: 1.0
Nodes (0): 

### Community 30 - "Community 30"
Cohesion: 1.0
Nodes (0): 

### Community 31 - "Community 31"
Cohesion: 1.0
Nodes (0): 

## Knowledge Gaps
- **198 isolated node(s):** `main`, `package:flutter_test/flutter_test.dart`, `configureDependencies`, `app/app.dart`, `AppLocalizations` (+193 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **Thin community `Community 24`** (2 nodes): `_`, `CategoriesDaoManager`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 25`** (2 nodes): `_`, `ItemsDaoManager`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 26`** (1 nodes): `my_application.h`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 27`** (1 nodes): `generated_plugin_registrant.h`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 28`** (1 nodes): `utils.h`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 29`** (1 nodes): `win32_window.h`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 30`** (1 nodes): `resource.h`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 31`** (1 nodes): `generated_plugin_registrant.h`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `package:flutter/material.dart` connect `Community 0` to `Community 9`, `Community 10`, `Community 2`, `Community 14`?**
  _High betweenness centrality (0.138) - this node is a cross-community bridge._
- **Why does `../../../domain/entities/item.dart` connect `Community 10` to `Community 2`, `Community 4`, `Community 6`, `Community 14`?**
  _High betweenness centrality (0.115) - this node is a cross-community bridge._
- **Why does `../../../domain/entities/category.dart` connect `Community 2` to `Community 4`?**
  _High betweenness centrality (0.088) - this node is a cross-community bridge._
- **What connects `main`, `package:flutter_test/flutter_test.dart`, `configureDependencies` to the rest of the system?**
  _198 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Community 0` be split into smaller, more focused modules?**
  _Cohesion score 0.06 - nodes in this community are weakly interconnected._
- **Should `Community 1` be split into smaller, more focused modules?**
  _Cohesion score 0.11 - nodes in this community are weakly interconnected._
- **Should `Community 2` be split into smaller, more focused modules?**
  _Cohesion score 0.08 - nodes in this community are weakly interconnected._