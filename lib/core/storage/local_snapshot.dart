import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';

import '../../models/diagnostic_result_model.dart';
import '../../models/exam_result_model.dart';
import '../../models/homework_model.dart';
import '../../models/parent_alert_log.dart';
import '../../models/study_plan_bundle.dart';
import '../../models/user_model.dart';
import 'pmath_database.dart';
import 'store_keys.dart';

/// Xotiradagi nusxa. O‘qish sinxron, yozish ketma-ket SQLite ga tushadi.
class LocalSnapshot {
  LocalSnapshot(this.db, {required DateTime Function() now}) : _now = now;

  final PmathDatabase db;
  final DateTime Function() _now;

  Future<void> _tail = Future<void>.value();

  UserModel? user;
  bool onboardingDone = false;
  bool diagnosticDone = false;
  DiagnosticResultModel? diagnostic;
  bool studyPlanReady = false;
  StudyPlanBundle? studyPlan;
  List<HomeworkModel> homework = [];
  List<ExamResultModel> exams = [];
  List<ParentAlertLogEntry> alerts = [];
  Set<String> overdueIds = {};
  String? streakAlertDay;
  Set<String> avatarIds = {};
  int weeklyXp = 0;
  String? weeklyXpWeek;
  int? pendingShellTab;

  DateTime Function() get now => _now;

  Future<T> serial<T>(Future<T> Function() action) {
    final run = _tail.then((_) => action());
    _tail = run.then((_) {}, onError: (_, _) {});
    return run;
  }

  Future<void> load() async {
    final meta = {
      for (final row in await db.select(db.metaRows).get()) row.key: row.value,
    };
    onboardingDone = meta[StoreKeys.onboardingDone] == '1';
    diagnosticDone = meta[StoreKeys.diagnosticDone] == '1';
    studyPlanReady = meta[StoreKeys.studyPlanReady] == '1';
    streakAlertDay = meta[StoreKeys.streakAlertDay];
    weeklyXp = int.tryParse(meta[StoreKeys.weeklyXp] ?? '') ?? 0;
    weeklyXpWeek = meta[StoreKeys.weeklyXpWeek];
    final tab = meta[StoreKeys.pendingShellTab];
    pendingShellTab = tab == null ? null : int.tryParse(tab);

    final docs = {
      for (final row in await db.select(db.jsonDocs).get())
        row.key: row.payload,
    };
    user = _decodeUser(docs[StoreKeys.docUser]);
    diagnostic = _decodeDiagnostic(docs[StoreKeys.docDiagnostic]);
    studyPlan = _decodePlan(docs[StoreKeys.docStudyPlan]);

    final homeworkRows = await (db.select(db.homeworkRows)
          ..orderBy([(t) => OrderingTerm.asc(t.seq)]))
        .get();
    homework = [
      for (final row in homeworkRows)
        HomeworkModel.fromJson(jsonDecode(row.payload) as Map<String, dynamic>),
    ];

    final examRows = await (db.select(db.examRows)
          ..orderBy([(t) => OrderingTerm.asc(t.seq)]))
        .get();
    exams = [
      for (final row in examRows)
        ExamResultModel.fromJson(
          jsonDecode(row.payload) as Map<String, dynamic>,
        ),
    ];

    final alertRows = await (db.select(db.alertRows)
          ..orderBy([(t) => OrderingTerm.asc(t.seq)]))
        .get();
    alerts = [
      for (final row in alertRows)
        ParentAlertLogEntry.fromJson(
          jsonDecode(row.payload) as Map<String, dynamic>,
        ),
    ];

    overdueIds = await _readBucket(StoreKeys.bucketOverdue);
    avatarIds = await _readBucket(StoreKeys.bucketAvatars);
  }

  Future<void> saveUser(UserModel value) {
    return serial(() async {
      await _setDoc(StoreKeys.docUser, jsonEncode(value.toJson()));
      user = value;
    });
  }

  Future<void> clearUser() {
    return serial(() async {
      await _deleteDoc(StoreKeys.docUser);
      user = null;
    });
  }

  Future<void> setOnboardingDone(bool value) {
    return serial(() async {
      await _setMeta(StoreKeys.onboardingDone, value ? '1' : '0');
      onboardingDone = value;
    });
  }

  Future<void> setDiagnosticDone(bool value) {
    return serial(() async {
      await _setMeta(StoreKeys.diagnosticDone, value ? '1' : '0');
      diagnosticDone = value;
    });
  }

  Future<void> saveDiagnostic(DiagnosticResultModel value) {
    return serial(() async {
      await _setDoc(StoreKeys.docDiagnostic, jsonEncode(value.toJson()));
      diagnostic = value;
    });
  }

  Future<void> setStudyPlanReady(bool value) {
    return serial(() async {
      await _setMeta(StoreKeys.studyPlanReady, value ? '1' : '0');
      studyPlanReady = value;
    });
  }

  Future<void> saveStudyPlan(StudyPlanBundle value) {
    return serial(() async {
      await _setDoc(StoreKeys.docStudyPlan, jsonEncode(value.toJson()));
      studyPlan = value;
    });
  }

  Future<void> clearStudyPlan() {
    return serial(() async {
      await db.transaction(() async {
        await _setMeta(StoreKeys.studyPlanReady, '0');
        await _deleteDoc(StoreKeys.docStudyPlan);
      });
      studyPlanReady = false;
      studyPlan = null;
    });
  }

  Future<void> saveHomework(List<HomeworkModel> items) {
    return serial(() async {
      await db.transaction(() async {
        await db.delete(db.homeworkRows).go();
        for (var i = 0; i < items.length; i++) {
          final item = items[i];
          await db.into(db.homeworkRows).insert(
                HomeworkRowsCompanion.insert(
                  id: item.id,
                  lessonId: item.lessonId,
                  assignedAtMicros: item.assignedAt.microsecondsSinceEpoch,
                  seq: i,
                  payload: jsonEncode(item.toJson()),
                ),
              );
        }
      });
      homework = List<HomeworkModel>.of(items);
    });
  }

  Future<void> saveExams(List<ExamResultModel> items) {
    return serial(() async {
      await db.transaction(() async {
        await db.delete(db.examRows).go();
        for (var i = 0; i < items.length; i++) {
          final item = items[i];
          await db.into(db.examRows).insert(
                ExamRowsCompanion.insert(
                  id: item.id,
                  lessonId: item.lessonId,
                  completedAtMicros: item.completedAt.microsecondsSinceEpoch,
                  seq: i,
                  payload: jsonEncode(item.toJson()),
                ),
              );
        }
      });
      exams = List<ExamResultModel>.of(items);
    });
  }

  Future<void> saveAlerts(List<ParentAlertLogEntry> items) {
    return serial(() async {
      await db.transaction(() async {
        await db.delete(db.alertRows).go();
        for (var i = 0; i < items.length; i++) {
          final item = items[i];
          await db.into(db.alertRows).insert(
                AlertRowsCompanion.insert(
                  id: item.id,
                  createdAtMicros: item.createdAt.microsecondsSinceEpoch,
                  seq: i,
                  payload: jsonEncode(item.toJson()),
                ),
              );
        }
      });
      alerts = List<ParentAlertLogEntry>.of(items);
    });
  }

  Future<void> saveOverdueIds(Set<String> ids) {
    return serial(() async {
      await _replaceBucket(StoreKeys.bucketOverdue, ids);
      overdueIds = Set<String>.of(ids);
    });
  }

  Future<void> setStreakAlertDay(String day) {
    return serial(() async {
      await _setMeta(StoreKeys.streakAlertDay, day);
      streakAlertDay = day;
    });
  }

  Future<void> saveAvatarIds(Set<String> ids) {
    return serial(() async {
      await _replaceBucket(StoreKeys.bucketAvatars, ids);
      avatarIds = Set<String>.of(ids);
    });
  }

  Future<void> saveWeeklyXp({required int xp, required String week}) {
    return serial(() async {
      await db.transaction(() async {
        await _setMeta(StoreKeys.weeklyXp, '$xp');
        await _setMeta(StoreKeys.weeklyXpWeek, week);
      });
      weeklyXp = xp;
      weeklyXpWeek = week;
    });
  }

  Future<void> setPendingShellTab(int index) {
    return serial(() async {
      await _setMeta(StoreKeys.pendingShellTab, '$index');
      pendingShellTab = index;
    });
  }

  /// Eski API sinxron o‘qiydi va kalitni darhol olib tashlaydi.
  int? takePendingShellTab() {
    final value = pendingShellTab;
    if (value == null) return null;
    pendingShellTab = null;
    unawaited(serial(() => _deleteMeta(StoreKeys.pendingShellTab)));
    return value;
  }

  Future<void> resetAll() {
    return serial(() async {
      await db.transaction(() async {
        await db.delete(db.jsonDocs).go();
        await db.delete(db.homeworkRows).go();
        await db.delete(db.examRows).go();
        await db.delete(db.alertRows).go();
        await db.delete(db.bucketValues).go();
        await (db.delete(db.metaRows)..where(
          (t) => t.key.isNotIn(const [
            StoreKeys.prefsImportVersion,
            StoreKeys.pendingShellTab,
          ]),
        ))
            .go();
        await _setMeta(StoreKeys.onboardingDone, '0');
        await _setMeta(StoreKeys.diagnosticDone, '0');
        await _setMeta(StoreKeys.studyPlanReady, '0');
      });
      user = null;
      onboardingDone = false;
      diagnosticDone = false;
      diagnostic = null;
      studyPlanReady = false;
      studyPlan = null;
      homework = [];
      exams = [];
      alerts = [];
      overdueIds = {};
      streakAlertDay = null;
      avatarIds = {};
      weeklyXp = 0;
      weeklyXpWeek = null;
    });
  }

  Future<void> close() => db.close();

  Future<Set<String>> _readBucket(String bucket) async {
    final rows = await (db.select(db.bucketValues)
          ..where((t) => t.bucket.equals(bucket)))
        .get();
    return rows.map((row) => row.value).toSet();
  }

  Future<void> _replaceBucket(String bucket, Set<String> values) async {
    await db.transaction(() async {
      await (db.delete(db.bucketValues)
            ..where((t) => t.bucket.equals(bucket)))
          .go();
      for (final value in values) {
        await db.into(db.bucketValues).insert(
              BucketValuesCompanion.insert(bucket: bucket, value: value),
            );
      }
    });
  }

  Future<void> _setMeta(String key, String value) {
    return db.into(db.metaRows).insert(
          MetaRowsCompanion.insert(key: key, value: value),
          mode: InsertMode.insertOrReplace,
        );
  }

  Future<void> _deleteMeta(String key) {
    return (db.delete(db.metaRows)..where((t) => t.key.equals(key))).go();
  }

  Future<void> _setDoc(String key, String payload) {
    return db.into(db.jsonDocs).insert(
          JsonDocsCompanion.insert(key: key, payload: payload),
          mode: InsertMode.insertOrReplace,
        );
  }

  Future<void> _deleteDoc(String key) {
    return (db.delete(db.jsonDocs)..where((t) => t.key.equals(key))).go();
  }

  UserModel? _decodeUser(String? raw) {
    if (raw == null) return null;
    return UserModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  DiagnosticResultModel? _decodeDiagnostic(String? raw) {
    if (raw == null) return null;
    return DiagnosticResultModel.fromJson(
      jsonDecode(raw) as Map<String, dynamic>,
    );
  }

  StudyPlanBundle? _decodePlan(String? raw) {
    if (raw == null) return null;
    return StudyPlanBundle.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }
}
