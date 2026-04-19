# PC Media Center — Архитектура

## Обзор проекта

**PC Media Center** — полноэкранный лаунчер/медиацентр для десктопа (Windows, Linux, macOS) на Flutter. Позволяет организовать программы, игры, фильмы, музыку и другой контент по категориям с красивым интерфейсом постеров. При нажатии на элемент — открывается его карточка с описанием и кнопкой запуска. Запуск происходит через системный обработчик ОС: программы запускаются как процессы, медиафайлы (видео, аудио) открываются в плеере по умолчанию.

---

## Технологический стек

| Компонент | Технология | Обоснование |
|---|---|---|
| Framework | Flutter 3.x (desktop) | Кроссплатформенность Win/Linux/macOS |
| State Management | `flutter_bloc` + `bloc` | Предсказуемый, хорошо документирован, удобен для AI-агентов |
| Database | `drift` (SQLite) | Type-safe SQL, миграции, портативное хранение рядом с приложением |
| HTTP Client | `dio` | Интерцепторы, retry, кэширование |
| Routing | `go_router` | Декларативный, поддержка deep links |
| DI | `get_it` + `injectable` | Простой service locator |
| Video Player | Системный плеер (через `Process.run` / `open`) | Используется плеер по умолчанию в ОС |
| Voice Input | `vosk_flutter` | Оффлайн распознавание речи, кроссплатформ |
| i18n | `flutter_localizations` + `.arb` | Стандартный механизм Flutter |
| Image Cache | `cached_network_image` | Кэширование постеров |
| Icon Extract | Нативный код (Win: `ExtractIcon`, Linux: `.desktop`, macOS: `NSWorkspace`) | Извлечение иконок из исполняемых файлов |
| API: фильмы | TMDB API + Kinopoisk (неофиц.) | Поиск фильмов, метаданные, постеры |
| API: метаданные | RAWG (игры), TMDB (фильмы) | Поиск постеров/описаний при добавлении |
| Input | `gamepads` / raw key events | Поддержка геймпада и пульта ДУ |

---

## Архитектура: Clean Architecture

```
┌─────────────────────────────────────────────────┐
│                 Presentation                     │
│  Screens → BLoC → Widgets                       │
├─────────────────────────────────────────────────┤
│                   Domain                         │
│  Entities, Use Cases, Repository Interfaces      │
├─────────────────────────────────────────────────┤
│                    Data                          │
│  Repository Impl, DataSources (Local + Remote)   │
│  Database (Drift/SQLite), API clients            │
└─────────────────────────────────────────────────┘
```

### Правило зависимостей
- **Presentation** зависит от **Domain**
- **Data** зависит от **Domain**
- **Domain** не зависит ни от чего (чистые Dart-классы)

---

## Структура проекта

```
lib/
├── main.dart                          # Точка входа
├── app/
│   ├── app.dart                       # MaterialApp, настройки
│   ├── router.dart                    # GoRouter конфигурация
│   └── theme/
│       ├── app_theme.dart             # ThemeData factory
│       ├── dark_theme.dart
│       └── light_theme.dart
│
├── core/
│   ├── constants/
│   │   ├── api_constants.dart         # URLs, ключи API
│   │   └── app_constants.dart         # Размеры, длительности
│   ├── errors/
│   │   ├── failures.dart              # Failure классы
│   │   └── exceptions.dart
│   ├── utils/
│   │   ├── input_handler.dart         # Унифицированный ввод (клав/геймпад/пульт)
│   │   └── platform_utils.dart
│   ├── services/
│   │   ├── launcher_service.dart      # Запуск файлов/программ через ОС
│   │   ├── directory_scanner.dart     # Сканирование каталогов для медиафайлов
│   │   ├── icon_extractor.dart        # Извлечение иконок из .exe/.app/.desktop
│   │   └── file_metadata_extractor.dart # Извлечение метаданных из файлов (оффлайн)
│   └── di/
│       └── injection.dart             # GetIt конфигурация
│
├── data/
│   ├── database/
│   │   ├── app_database.dart          # Drift database class
│   │   ├── tables/
│   │   │   ├── categories_table.dart
│   │   │   └── items_table.dart
│   │   └── daos/
│   │       ├── categories_dao.dart
│   │       └── items_dao.dart
│   ├── datasources/
│   │   ├── local/
│   │   │   └── local_data_source.dart
│   │   └── remote/
│   │       ├── tmdb_api.dart
│   │       ├── kinopoisk_api.dart
│   │       └── metadata_search_api.dart  # Общий поиск метаданных
│   ├── models/
│   │   ├── category_model.dart
│   │   ├── item_model.dart
│   │   └── search_result_model.dart
│   └── repositories/
│       ├── category_repository_impl.dart
│       ├── item_repository_impl.dart
│       └── search_repository_impl.dart
│
├── domain/
│   ├── entities/
│   │   ├── category.dart
│   │   ├── item.dart
│   │   └── search_result.dart
│   ├── repositories/
│   │   ├── category_repository.dart    # Абстрактный интерфейс
│   │   ├── item_repository.dart
│   │   └── search_repository.dart
│   └── usecases/
│       ├── categories/
│       │   ├── get_categories.dart
│       │   ├── add_category.dart
│       │   ├── update_category.dart
│       │   └── delete_category.dart
│       ├── items/
│       │   ├── get_items_by_category.dart
│       │   ├── add_item.dart
│       │   ├── update_item.dart
│       │   ├── delete_item.dart
│       │   ├── launch_item.dart
│       │   ├── scan_directory.dart
│       │   └── search_items.dart
│       └── search/
│           ├── search_movies_online.dart
│           └── search_metadata.dart
│
├── presentation/
│   ├── blocs/
│   │   ├── category/
│   │   │   ├── category_bloc.dart
│   │   │   ├── category_event.dart
│   │   │   └── category_state.dart
│   │   ├── item/
│   │   │   ├── item_bloc.dart
│   │   │   ├── item_event.dart
│   │   │   └── item_state.dart
│   │   ├── search/
│   │   │   ├── search_bloc.dart
│   │   │   ├── search_event.dart
│   │   │   └── search_state.dart
│   │   ├── settings/
│   │   │   ├── settings_bloc.dart
│   │   │   ├── settings_event.dart
│   │   │   └── settings_state.dart
│   │   └── voice/
│   │       ├── voice_bloc.dart
│   │       ├── voice_event.dart
│   │       └── voice_state.dart
│   ├── screens/
│   │   ├── home/
│   │   │   └── home_screen.dart       # Список категорий
│   │   ├── category/
│   │   │   └── category_screen.dart   # Сетка постеров
│   │   ├── item_detail/
│   │   │   └── item_detail_screen.dart # Карточка элемента
│   │   ├── item_form/
│   │   │   └── item_form_screen.dart  # Добавление/редактирование
│   │   ├── search/
│   │   │   └── search_screen.dart     # Поиск (результаты)
│   │   └── settings/
│   │       └── settings_screen.dart   # Тема, язык, настройки
│   └── widgets/
│       ├── common/
│       │   ├── focusable_widget.dart   # Обёртка для навигации фокусом
│       │   └── loading_indicator.dart
│       ├── poster_card.dart            # Карточка постера в сетке
│       ├── category_card.dart          # Карточка категории на главной
│       ├── search_bar_widget.dart      # Поисковая строка
│       └── voice_input_button.dart     # Кнопка голосового ввода
│
└── l10n/
    ├── app_en.arb                      # English
    └── app_ru.arb                      # Русский

assets/
├── icons/                              # Иконки категорий по умолчанию
├── images/                             # Placeholder изображения
└── vosk_model/                         # Модель для оффлайн-распознавания речи

data/                                   # RUNTIME: БД и кэш (рядом с .exe)
├── media_center.db                     # SQLite база
└── cache/
    └── posters/                        # Кэшированные постеры
```

---

## Схема базы данных (Drift/SQLite)

```sql
-- Категории
CREATE TABLE categories (
    id            INTEGER PRIMARY KEY AUTOINCREMENT,
    name          TEXT NOT NULL,
    icon          TEXT,           -- имя иконки или путь к файлу
    sort_order    INTEGER DEFAULT 0,
    is_movie_type BOOLEAN DEFAULT FALSE,  -- включает онлайн-поиск
    scan_paths    TEXT,           -- JSON-массив путей для сканирования медиафайлов
    file_extensions TEXT,        -- допустимые расширения для сканирования (например: "mp4,mkv,avi")
    created_at    DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at    DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Элементы (фильмы, игры, программы и т.д.)
CREATE TABLE items (
    id            INTEGER PRIMARY KEY AUTOINCREMENT,
    category_id   INTEGER NOT NULL REFERENCES categories(id) ON DELETE CASCADE,
    title         TEXT NOT NULL,
    description   TEXT,
    poster_path   TEXT,           -- локальный путь к постеру
    poster_url    TEXT,           -- URL постера (для загрузки)
    launch_path   TEXT,           -- путь к исполняемому файлу / медиафайлу
    launch_args   TEXT,           -- доп. параметры запуска (напр.: "-fullscreen -w 1920")
    item_type     TEXT DEFAULT 'file',  -- 'app' | 'file' | 'media' | 'url'
    year          INTEGER,
    rating        REAL,
    external_id   TEXT,           -- TMDB ID / другой внешний ID
    metadata_json TEXT,           -- доп. метаданные в JSON
    sort_order    INTEGER DEFAULT 0,
    is_favorite   BOOLEAN DEFAULT FALSE,
    created_at    DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at    DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Настройки приложения (key-value)
CREATE TABLE settings (
    key   TEXT PRIMARY KEY,
    value TEXT NOT NULL
);
```

---

## Навигация (Screens Flow)

```
                    ┌──────────────┐
                    │  Home Screen │
                    │  (категории) │
                    └──────┬───────┘
                           │
              ┌────────────┼────────────┐
              ▼            ▼            ▼
       ┌────────────┐ ┌────────────┐ ┌──────────┐
       │ Category   │ │ Category   │ │ Settings │
       │ (Фильмы)   │ │ (Игры)     │ │          │
       └─────┬──────┘ └─────┬──────┘ └──────────┘
             │               │
             ▼               ▼
       ┌────────────┐ ┌────────────┐
       │ Item Detail│ │ Item Detail│
       │ (карточка) │ │ (карточка) │
       └─────┬──────┘ └─────┬──────┘
             │               │
        ┌────┴────┐     ┌────┴────┐
        ▼         ▼     ▼         ▼
   ┌──────────┐ ┌──────┐ ┌──────┐ ┌──────────┐
   │ Launch   │ │ Edit │ │ Edit │ │ Launch   │
   │(сист.пл.)│ │ Form │ │ Form │ │(процесс) │
   └──────────┘ └──────┘ └──────┘ └──────────┘

   [Глобальная строка поиска + голосовой ввод доступны на всех экранах]
```

---

## Система ввода (Input System)

Унифицированная обработка ввода через `InputHandler`:

| Действие | Клавиатура | Геймпад | Пульт ДУ |
|---|---|---|---|
| Навигация | Arrow Keys / Tab | D-pad / Left Stick | Arrow Keys |
| Выбрать | Enter | A / X | OK / Enter |
| Назад | Escape / Backspace | B | Back |
| Поиск | Ctrl+F / начать печатать | Y | — |
| Голос | Ctrl+M | Зажать A | Mic button |
| Меню | Ctrl+, | Start | Menu |

### Реализация
- `FocusableWidget` — обёртка для каждого интерактивного элемента
- `Shortcuts` + `Actions` (Flutter) — биндинги клавиш
- `RawKeyboardListener` — для геймпада/пульта
- Автофокус на первый элемент при входе на экран

---

## API интеграции

### TMDB (TheMovieDB)
- **Endpoint**: `https://api.themoviedb.org/3/`
- **Используется**: поиск фильмов/сериалов, постеры, описания
- **Ключ**: хранится в настройках приложения (вводится пользователем)
- **Кэширование**: результаты кэшируются в SQLite

### Kinopoisk (неофициальный)
- **Endpoint**: `https://kinopoiskapiunofficial.tech/api/`
- **Используется**: поиск фильмов на русском, рейтинги КП
- **Ключ**: хранится в настройках приложения

### Поиск метаданных при добавлении
- Сначала — оффлайн: метаданные файла + парсинг имени
- Затем (если есть интернет) — поиск по TMDB / RAWG / Kinopoisk
- Пользователь выбирает результат → автозаполнение полей
- При отсутствии интернета — элемент добавляется с оффлайн-данными, онлайн-обогащение можно сделать позже

---

## Запуск элементов (LauncherService)

- Единый сервис для запуска любых элементов: программы, видео, аудио, документы
- **Программы/игры** (`item_type = 'app'`): `Process.run(launch_path, [...launch_args])`
  - Прямой запуск исполняемого файла с переданными аргументами
  - Пример: `launch_path="halflife.exe"`, `launch_args="-fullscreen -w 1920"`
- **Медиафайлы** (`item_type = 'file'` / `'media'`): открытие через системный обработчик
  - Windows: `Process.run('cmd', ['/c', 'start', '', filePath])`
  - Linux: `Process.run('xdg-open', [filePath])`
  - macOS: `Process.run('open', [filePath])`
- Обработка ошибок: файл не найден, нет прав на запуск

---

## Извлечение иконок и метаданных приложений (IconExtractor)

При добавлении приложения — автоматически извлечь иконку и название из исполняемого файла.

- **Windows**:
  - Иконка: `ExtractIcon` / `SHGetFileInfo` через FFI (`dart:ffi` + `package:win32`)
  - Название: `FileVersionInfo` → `ProductName` / `FileDescription`
- **macOS**:
  - Иконка: `NSWorkspace.shared.icon(forFile:)` через Method Channel или `sips` CLI
  - Название: парсинг `Info.plist` → `CFBundleDisplayName` / `CFBundleName`
- **Linux**:
  - Иконка: парсинг `.desktop` файла (поле `Icon=`) + поиск в `/usr/share/icons/`
  - Название: поле `Name=` из `.desktop` файла
- Иконка сохраняется в `data/cache/posters/` как PNG
- Если не удалось извлечь название — использовать имя файла без расширения
- Если не удалось извлечь иконку — использовать placeholder

---

## Оффлайн-извлечение метаданных (FileMetadataExtractor)

При отсутствии интернета или как первый шаг при добавлении элемента — данные извлекаются из самого файла.

### Парсинг имени файла
- `"Матрица (1999) BDRip 1080p.mkv"` → title=`"Матрица"`, year=`1999`
- `"The.Matrix.1999.1080p.BluRay.mkv"` → title=`"The Matrix"`, year=`1999`
- `"halflife2.exe"` → title=`"halflife2"` (фоллбэк, для приложений приоритет у IconExtractor)
- Регулярные выражения: извлечь год `(\d{4})` или `\.\d{4}\.`, убрать теги качества (BDRip, 1080p, 720p, WEB-DL и т.д.).
- Замена точек/подчёркиваний на пробелы

### Метаданные медиафайлов
- **Видео** (mp4, mkv, avi): извлечение через `ffprobe` (если установлен) — title, duration, resolution, codec
- **Аудио** (mp3, flac, ogg): ID3/Vorbis теги — title, artist, album, year, обложка альбома
- **Приложения** (.exe, .app, .desktop): через `IconExtractor` (название + иконка)

### Приоритет заполнения полей
1. Метаданные из файла (ID3, ffprobe, IconExtractor) — всегда доступны
2. Парсинг имени файла — фоллбэк для title/year
3. Онлайн-поиск (TMDB/Kinopoisk) — если есть интернет, обогащает данные

---

## Сканирование каталогов (DirectoryScanner)

- Позволяет массово добавлять медиафайлы из указанной папки
- В категории можно указать `scan_paths` — список каталогов для сканирования
- Фильтрация по расширениям (`file_extensions`): `.mp4`, `.mkv`, `.avi`, `.mp3`, `.flac` и т.д.
- Рекурсивное сканирование подпапок
- Новые файлы добавляются, удалённые помечаются
- Название элемента = имя файла (без расширения)
- Можно запустить повторное сканирование для обновления списка

---

## Принципы разработки

1. **Каждый BLoC** — отдельный файл для event, state, bloc
2. **Entities** — чистые Dart-классы без зависимостей
3. **Models** — `fromJson`/`toJson`, маппинг в Entity
4. **Repository** — интерфейс в domain, реализация в data
5. **UseCase** — один метод `call()`, одна ответственность
6. **Экраны** — минимум логики, всё через BLoC
7. **Виджеты** — переиспользуемые, без прямого обращения к BLoC
