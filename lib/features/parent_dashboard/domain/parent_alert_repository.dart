import '../../../models/parent_alert_log.dart';

/// Ota-ona ogohlantirish jurnali.
abstract class ParentAlertRepository {
  List<ParentAlertLogEntry> getParentAlertLogs();

  Future<void> appendParentAlertLog(ParentAlertLogEntry entry);

  Set<String> getOverdueAlertedIds();

  Future<void> markOverdueAlerted(String homeworkId);

  String? get streakAlertDay;

  Future<void> setStreakAlertDay(String dayKey);
}
