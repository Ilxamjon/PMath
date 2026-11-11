import '../../../core/storage/local_snapshot.dart';
import '../../../models/parent_alert_log.dart';
import '../domain/parent_alert_repository.dart';

class DriftParentAlertRepository implements ParentAlertRepository {
  DriftParentAlertRepository(this._store);

  final LocalSnapshot _store;

  @override
  List<ParentAlertLogEntry> getParentAlertLogs() {
    return [..._store.alerts]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<void> appendParentAlertLog(ParentAlertLogEntry entry) async {
    final list = List<ParentAlertLogEntry>.from(getParentAlertLogs());
    list.insert(0, entry);
    await _store.saveAlerts(list.take(50).toList());
  }

  @override
  Set<String> getOverdueAlertedIds() => Set<String>.of(_store.overdueIds);

  @override
  Future<void> markOverdueAlerted(String homeworkId) async {
    final ids = getOverdueAlertedIds()..add(homeworkId);
    await _store.saveOverdueIds(ids);
  }

  @override
  String? get streakAlertDay => _store.streakAlertDay;

  @override
  Future<void> setStreakAlertDay(String dayKey) =>
      _store.setStreakAlertDay(dayKey);
}
