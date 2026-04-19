# PC Media Center — External Integrations

**Analysis Date:** 2026-04-19

> External APIs, services, and third-party integrations used by the application.

---

## APIs & External Services

### Movie/TV Metadata APIs

#### TMDB (The Movie Database)

**Purpose:** Primary source for international movie and TV show metadata, posters, and descriptions

**Configuration:**
- Base URL: `https://api.themoviedb.org/3`
- Authentication: Query parameter `api_key` (user-provided)
- Rate Limits: 40 requests per 10 seconds (TMDB standard)

**Implementation:**
- File: `lib/data/datasources/remote/tmdb_api.dart`
- Class: `TMDbApiClient`

**API Endpoints Used:**
| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/search/movie` | GET | Search movies by title |
| `/movie/{id}` | GET | Get detailed movie information |
| `/movie/{id}/images` | GET | Get movie posters and backdrops |

**Data Flow:**
```
User Query → TMDbApiClient.searchMovies() → Dio HTTP GET → TMDB API
                                    ↓
                              LocalDataSource.cache() ← Cache result
```

**Error Handling:** Throws `Exception('Ошибка TMDB API: $e')` on failure

---

#### Kinopoisk API (via RapidAPI)

**Purpose:** Russian movie database for localized content and ratings

**Configuration:**
- Base URL: `https://kinopoiskdkp.p.rapidapi.com`
- Authentication: Header `X-RapidAPI-Key` (user-provided)
- Provider: RapidAPI marketplace

**Implementation:**
- File: `lib/data/datasources/remote/kinopoisk_api.dart`
- Class: `KinopoiskApiClient`

**API Endpoints Used:**
| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/v2/movie/search` | GET | Search movies with query parameter `q` |
| `/v2/movie/{id}` | GET | Get detailed movie information |
| `/v2/movie/{id}/images` | GET | Get movie images |

**Data Flow:**
```
User Query → KinopoiskApiClient.searchMovies() → Dio HTTP GET (with RapidAPI header)
                                    ↓
                              LocalDataSource.cache() ← Cache result
```

**Error Handling:** Throws `Exception('Ошибка Кинопоиск API: $e')` on failure

---

#### MetadataSearchApi (Aggregator)

**Purpose:** Unified interface that combines TMDB and Kinopoisk search results

**Implementation:**
- File: `lib/data/datasources/remote/metadata_search_api.dart`
- Class: `MetadataSearchApi`

**Methods:**
| Method | Description |
|--------|-------------|
| `search(String query)` | Searches both APIs and merges results |
| `searchTmdb(String query)` | TMDB-only search |
| `searchKp(String query)` | Kinopoisk-only search |
| `getPoster(int movieId)` | Get poster from TMDB |
| `getDescription(int movieId)` | Get description from TMDB |

**Result Merging:** Combines results from both APIs, returns unified list

---

### Image CDNs

| Service | URL Pattern | Purpose |
|---------|-------------|---------|
| **TMDB Images** | `https://image.tmdb.org/t/p/w500{poster_path}` | Movie posters (500px width) |
| **Kinopoisk Images** | `https://img.kinopoisk.ru/cover/{poster}` | Russian movie covers |

**Integration:** Used via `cached_network_image` package for automatic caching

---

## Data Storage

### Local Database

**Type:** SQLite

**ORM:** Drift 2.23.1

**Implementation:**
- File: `lib/data/database/app_database.dart`
- Class: `AppDatabase`

**Schema:**
| Table | Purpose |
|-------|---------|
| `Categories` | Media categories/folders |
| `Items` | Media items (movies, games, files) |
| `Settings` | Key-value application settings |

**DAO Access:**
- `CategoriesDao` — Category CRUD operations
- `ItemsDao` — Item CRUD operations

**Storage Location:**
```dart
{executable_directory}/data/media_center.db
```

**Platform Paths:**
- **Windows:** `C:\Program Files\PC Media Center\data\media_center.db`
- **Linux:** `/opt/pc-media-center/data/media_center.db`
- **macOS:** `/Applications/PC Media Center.app/Contents/data/media_center.db`

---

## Authentication

**Auth Provider:** None (user-provided API keys only)

**API Key Management:**
- TMDB API key: Passed via constructor to `TMDbApiClient`
- Kinopoisk API key: Passed via constructor to `KinopoiskApiClient`
- Storage: Planned to be stored in Settings table

**Current Implementation:**
```dart
// Manual injection at startup
final tmdbClient = TMDbApiClient(apiKey: userTmdbKey, localCache: cache);
final kpClient = KinopoiskApiClient(apiKey: userKpKey, localCache: cache);
```

---

## File System Integration

### Local Storage Access

**Package:** `path_provider` 2.1.5

**Purpose:**
- Resolve platform-specific paths
- Locate executable directory for database storage
- Future: File picker for media folder scanning

**Current Usage:**
```dart
static String _defaultDbPath() {
  final exeDir = File(Platform.resolvedExecutable).parent.path;
  return p.join(exeDir, 'data', 'media_center.db');
}
```

### Media Launch Capability

**Status:** Planned

**Data Model (in database):**
- `Items.launchPath` — Path to executable/media file
- `Items.launchArgs` — Command-line arguments

**Planned Implementation:**
- Windows: `Process.run()` with shell execute
- Linux: `xdg-open` command
- macOS: `open` command or NSWorkspace

---

## Internationalization (i18n)

**Framework:** Flutter's built-in localization + intl package

**Configuration:**
- File: `l10n.yaml`
- ARB files: `lib/l10n/app_en.arb`, `lib/l10n/app_ru.arb`
- Generated files: `lib/l10n/generated/app_localizations_*.dart`

**Supported Locales:**
- English (`en`)
- Russian (`ru`)

**Usage:**
```dart
MaterialApp.router(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
)
```

---

## Caching Strategy

### Local Cache (API Results)

**Implementation:**
- File: `lib/data/datasources/local/local_data_source.dart`
- Class: `LocalDataSource`

**Caching Pattern:**
```dart
Map<String, dynamic> _cacheResult(String key, Map<String, dynamic> data) {
  localCache.cache(key, data);
  return data;
}
```

**Cache Keys:**
- `tmdb_movies_{query}` — TMDB search results
- `tmdb_movie_{id}` — TMDB movie details
- `tmdb_images_{id}` — TMDB movie images
- `kp_movies_{query}` — Kinopoisk search results
- `kp_movie_{id}` — Kinopoisk movie details

### Image Caching

**Package:** `cached_network_image` 3.4.1

**Features:**
- Automatic disk caching of downloaded images
- Memory cache for frequently accessed images
- Placeholder and error widgets

---

## Error Handling & Resilience

### API Error Handling

| Layer | Strategy | Implementation |
|-------|----------|----------------|
| **API Client** | Try-catch + Exception | `try { Dio().get(...) } catch (e) { throw Exception('...') }` |
| **Repository** | Graceful degradation | Return empty list on error |
| **BLoC** | Error states | Emit error state with message |

### Network Error Scenarios

| Scenario | Behavior |
|----------|----------|
| **No Internet** | Falls back to cached data or empty results |
| **API Timeout** | Exception propagates to repository layer |
| **Invalid API Key** | API returns error, caught and logged |
| **Rate Limiting** | Relies on TMDB/RapidAPI limits (no explicit handling) |

### Database Error Handling

| Operation | Handling |
|-----------|----------|
| **Connection** | Drift handles automatically with `NativeDatabase.createInBackground()` |
| **Queries** | Drift type-safety prevents SQL errors at compile time |
| **Migrations** | `MigrationStrategy` with `onCreate` and `onUpgrade` hooks |

---

## Integration Summary

| Category | Count | Technologies |
|----------|-------|--------------|
| **External APIs** | 2 | TMDB, Kinopoisk (via RapidAPI) |
| **Image CDNs** | 2 | image.tmdb.org, img.kinopoisk.ru |
| **Databases** | 1 | SQLite (via Drift) |
| **HTTP Clients** | 1 | Dio 5.7.0 |
| **State Management** | 1 | flutter_bloc |
| **Routing** | 1 | go_router |
| **DI Framework** | 2 | get_it, injectable |
| **i18n** | 1 | flutter_localizations + intl |

**Integration Maturity:**
- ✅ **Production-ready:** Database, routing, state management, i18n
- 📝 **Partial:** API clients (need API key management UI)
- ⏳ **Planned:** File launching, platform-specific process execution

---

## Required Configuration

### Environment Variables / Settings

| Setting | Purpose | Required |
|---------|---------|----------|
| `tmdb_api_key` | TMDB API authentication | Yes (for metadata) |
| `kinopoisk_api_key` | Kinopoisk RapidAPI key | No (optional fallback) |

**Note:** No `.env` file detected. API keys passed via constructors.

---

*Integration audit: 2026-04-19*
