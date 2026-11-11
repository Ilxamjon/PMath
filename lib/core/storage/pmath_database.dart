import 'package:drift/drift.dart';

part 'pmath_database.g.dart';

/// Drift sxema. Versiya faqat oldinga oshadi, orqaga qaytarilmaydi.
class MetaRows extends Table {
  @override
  String get tableName => 'meta';

  TextColumn get key => text()();

  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}

class JsonDocs extends Table {
  @override
  String get tableName => 'docs';

  TextColumn get key => text()();

  TextColumn get payload => text()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}

class HomeworkRows extends Table {
  @override
  String get tableName => 'homework';

  TextColumn get id => text()();

  TextColumn get lessonId => text()();

  IntColumn get assignedAtMicros => integer()();

  IntColumn get seq => integer()();

  TextColumn get payload => text()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class ExamRows extends Table {
  @override
  String get tableName => 'exams';

  TextColumn get id => text()();

  TextColumn get lessonId => text()();

  IntColumn get completedAtMicros => integer()();

  IntColumn get seq => integer()();

  TextColumn get payload => text()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class AlertRows extends Table {
  @override
  String get tableName => 'alerts';

  TextColumn get id => text()();

  IntColumn get createdAtMicros => integer()();

  IntColumn get seq => integer()();

  TextColumn get payload => text()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class BucketValues extends Table {
  @override
  String get tableName => 'buckets';

  TextColumn get bucket => text()();

  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => {bucket, value};
}

@DriftDatabase(
  tables: [
    MetaRows,
    JsonDocs,
    HomeworkRows,
    ExamRows,
    AlertRows,
    BucketValues,
  ],
)
class PmathDatabase extends _$PmathDatabase {
  PmathDatabase(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
        onUpgrade: (m, from, to) async {
          // Orqaga qaytarilmaydi. Keyingi versiyalar faqat shu yerda oldinga yuradi.
        },
      );
}
