import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/diagnostic_result_model.dart';
import '../../models/exam_result_model.dart';
import '../../models/homework_model.dart';
import '../../models/parent_alert_log.dart';
import '../../models/study_plan_bundle.dart';
import '../../models/user_model.dart';
import 'pmath_database.dart';
import 'store_keys.dart';

/// SharedPreferences JSON ini birinchi ochilishda SQLite ga ko‘chiradi.
///
/// Tranzaksiya yopilguncha `prefs_import_version` yozilmaydi. Xato bo‘lsa
/// prefs o‘z joyida qoladi va keyingi ochilish qayta urinadi.
/// SQLite dan prefs ga qaytarish yo‘li yo‘q.
class PrefsDriftMigrator {
  PrefsDriftMigrator({required this.prefs, required this.db});

  final SharedPreferences prefs;
  final PmathDatabase db;

  Future<void> migrate() async {
    final existing = await (db.select(db.metaRows)
          ..where((t) => t.key.equals(StoreKeys.prefsImportVersion)))
        .getSingleOrNull();
    if (existing?.value == StoreKeys.currentImportVersion) return;

    await db.transaction(() async {
      await _copyUser();
      await _copyFlag(PrefsKeys.onboardingDone, StoreKeys.onboardingDone);
      await _copyFlag(PrefsKeys.diagnosticDone, StoreKeys.diagnosticDone);
      await _copyFlag(PrefsKeys.studyPlanReady, StoreKeys.studyPlanReady);
      await _copyDoc(
        PrefsKeys.diagnosticResult,
        StoreKeys.docDiagnostic,
        (raw) => DiagnosticResultModel.fromJson(
          jsonDecode(raw) as Map<String, dynamic>,
        ),
      );
      await _copyDoc(
        PrefsKeys.studyPlan,
        StoreKeys.docStudyPlan,
        (raw) => StudyPlanBundle.fromJson(
          jsonDecode(raw) as Map<String, dynamic>,
        ),
      );
      await _copyHomework();
      await _copyExams();
      await _copyAlerts();
      await _copyStringSet(PrefsKeys.overdueAlerted, StoreKeys.bucketOverdue);
      await _copyStringSet(PrefsKeys.unlockedAvatars, StoreKeys.bucketAvatars);
      await _copyString(PrefsKeys.streakAlertDay, StoreKeys.streakAlertDay);
      await _copyInt(PrefsKeys.weeklyXp, StoreKeys.weeklyXp);
      await _copyString(PrefsKeys.weeklyXpWeek, StoreKeys.weeklyXpWeek);
      await _copyInt(PrefsKeys.pendingShellTab, StoreKeys.pendingShellTab);
      await _verify();
      await db.into(db.metaRows).insert(
            MetaRowsCompanion.insert(
              key: StoreKeys.prefsImportVersion,
              value: StoreKeys.currentImportVersion,
            ),
          );
    });
  }

  Future<void> _copyUser() async {
    final raw = prefs.getString(PrefsKeys.user);
    if (raw == null) return;
    UserModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    await _setDoc(StoreKeys.docUser, raw);
  }

  Future<void> _copyFlag(String prefsKey, String metaKey) async {
    if (!prefs.containsKey(prefsKey)) return;
    final value = prefs.getBool(prefsKey);
    if (value == null) return;
    await _setMeta(metaKey, value ? '1' : '0');
  }

  Future<void> _copyDoc(
    String prefsKey,
    String docKey,
    Object Function(String raw) parse,
  ) async {
    final raw = prefs.getString(prefsKey);
    if (raw == null) return;
    parse(raw);
    await _setDoc(docKey, raw);
  }

  Future<void> _copyHomework() async {
    final raw = prefs.getString(PrefsKeys.homeworkList);
    if (raw == null) return;
    final list = jsonDecode(raw) as List<dynamic>;
    for (var i = 0; i < list.length; i++) {
      final map = list[i] as Map<String, dynamic>;
      final item = HomeworkModel.fromJson(map);
      await db.into(db.homeworkRows).insert(
            HomeworkRowsCompanion.insert(
              id: item.id,
              lessonId: item.lessonId,
              assignedAtMicros: item.assignedAt.microsecondsSinceEpoch,
              seq: i,
              payload: jsonEncode(map),
            ),
          );
    }
  }

  Future<void> _copyExams() async {
    final raw = prefs.getString(PrefsKeys.examResults);
    if (raw == null) return;
    final list = jsonDecode(raw) as List<dynamic>;
    for (var i = 0; i < list.length; i++) {
      final map = list[i] as Map<String, dynamic>;
      final item = ExamResultModel.fromJson(map);
      await db.into(db.examRows).insert(
            ExamRowsCompanion.insert(
              id: item.id,
              lessonId: item.lessonId,
              completedAtMicros: item.completedAt.microsecondsSinceEpoch,
              seq: i,
              payload: jsonEncode(map),
            ),
          );
    }
  }

  Future<void> _copyAlerts() async {
    final raw = prefs.getString(PrefsKeys.parentAlerts);
    if (raw == null) return;
    final list = jsonDecode(raw) as List<dynamic>;
    for (var i = 0; i < list.length; i++) {
      final map = list[i] as Map<String, dynamic>;
      final item = ParentAlertLogEntry.fromJson(map);
      await db.into(db.alertRows).insert(
            AlertRowsCompanion.insert(
              id: item.id,
              createdAtMicros: item.createdAt.microsecondsSinceEpoch,
              seq: i,
              payload: jsonEncode(map),
            ),
          );
    }
  }

  Future<void> _copyStringSet(String prefsKey, String bucket) async {
    final values = prefs.getStringList(prefsKey);
    if (values == null) return;
    for (final value in values) {
      await db.into(db.bucketValues).insert(
            BucketValuesCompanion.insert(bucket: bucket, value: value),
            mode: InsertMode.insertOrReplace,
          );
    }
  }

  Future<void> _copyString(String prefsKey, String metaKey) async {
    final value = prefs.getString(prefsKey);
    if (value == null) return;
    await _setMeta(metaKey, value);
  }

  Future<void> _copyInt(String prefsKey, String metaKey) async {
    final value = prefs.getInt(prefsKey);
    if (value == null) return;
    await _setMeta(metaKey, '$value');
  }

  Future<void> _verify() async {
    final userRaw = prefs.getString(PrefsKeys.user);
    if (userRaw != null) {
      final row = await (db.select(db.jsonDocs)
            ..where((t) => t.key.equals(StoreKeys.docUser)))
          .getSingleOrNull();
      if (row?.payload != userRaw) {
        throw StateError('Foydalanuvchi migratsiyasi mos kelmadi');
      }
    }
    await _verifyCount(PrefsKeys.homeworkList, db.homeworkRows);
    await _verifyCount(PrefsKeys.examResults, db.examRows);
    await _verifyCount(PrefsKeys.parentAlerts, db.alertRows);
  }

  Future<void> _verifyCount(String prefsKey, TableInfo<Table, dynamic> table) async {
    final raw = prefs.getString(prefsKey);
    if (raw == null) return;
    final expected = (jsonDecode(raw) as List<dynamic>).length;
    final rows = await db.select(table).get();
    if (rows.length != expected) {
      throw StateError('$prefsKey migratsiyasi mos kelmadi');
    }
  }

  Future<void> _setMeta(String key, String value) {
    return db.into(db.metaRows).insert(
          MetaRowsCompanion.insert(key: key, value: value),
          mode: InsertMode.insertOrReplace,
        );
  }

  Future<void> _setDoc(String key, String payload) {
    return db.into(db.jsonDocs).insert(
          JsonDocsCompanion.insert(key: key, payload: payload),
          mode: InsertMode.insertOrReplace,
        );
  }
}
