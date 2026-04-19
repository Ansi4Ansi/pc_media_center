import 'package:drift/drift.dart';

import 'categories_table.dart';

class Items extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get categoryId =>
      integer().references(Categories, #id)();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  TextColumn get posterPath => text().nullable()();
  TextColumn get posterUrl => text().nullable()();
  TextColumn get launchPath => text().nullable()();
  TextColumn get launchArgs => text().nullable()();
  TextColumn get itemType =>
      text().withDefault(const Constant('file'))();
  IntColumn get year => integer().nullable()();
  RealColumn get rating => real().nullable()();
  TextColumn get externalId => text().nullable()();
  TextColumn get metadataJson => text().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  BoolColumn get isFavorite =>
      boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();
}
