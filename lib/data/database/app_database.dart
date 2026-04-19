import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;

import 'tables/categories_table.dart';
import 'tables/items_table.dart';
import 'tables/settings_table.dart';
import 'daos/categories_dao.dart';
import 'daos/items_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Categories, Items, Settings], daos: [CategoriesDao, ItemsDao])
class AppDatabase extends _$AppDatabase {
  AppDatabase._internal(super.e);

  factory AppDatabase({String? dbPath}) {
    final path = dbPath ?? _defaultDbPath();
    return AppDatabase._internal(
      NativeDatabase.createInBackground(File(path)),
    );
  }

  static String _defaultDbPath() {
    final exeDir = File(Platform.resolvedExecutable).parent.path;
    return p.join(exeDir, 'data', 'media_center.db');
  }

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
        onUpgrade: (m, from, to) async {
          // Future migrations go here
        },
      );

  // Settings helpers
  Future<String?> getSetting(String key) async {
    final result = await (select(settings)..where((t) => t.key.equals(key)))
        .getSingleOrNull();
    return result?.value;
  }

  Future<void> setSetting(String key, String value) async {
    await into(settings).insertOnConflictUpdate(
      SettingsCompanion(
        key: Value(key),
        value: Value(value),
      ),
    );
  }
}
