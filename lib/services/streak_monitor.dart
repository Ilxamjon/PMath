import '../models/user_model.dart';
import 'parent_alert_service.dart';
import 'storage_service.dart';

/// Streak yo‘qolishi / xavf — ota-ona Telegram/SMS.
class StreakMonitor {
  StreakMonitor({
    required StorageService storage,
    required ParentAlertService alerts,
  })  : _storage = storage,
        _alerts = alerts;

  final StorageService _storage;
  final ParentAlertService _alerts;

  /// Kunlik faollik tekshiruvi. Streak uzilsa → alert + reset.
  ///
  /// Returns: alert yuborildimi?
  Future<bool> checkAndAlert({DateTime? now}) async {
    final user = _storage.getUser();
    if (user == null) return false;

    final moment = now ?? DateTime.now();
    final today = DateTime(moment.year, moment.month, moment.day);
    final dayKey =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    final last = user.lastActiveDate;
    if (last == null) return false;

    final lastDay = DateTime(last.year, last.month, last.day);
    final gap = today.difference(lastDay).inDays;

    // Bugun yoki kecha faol — OK.
    if (gap <= 1) return false;
    if (user.streakDays <= 0) return false;

    // Bir kunda bir marta.
    if (_storage.streakAlertDay == dayKey) return false;

    await _alerts.streakAtRisk(
      user: user,
      reasonUz:
          'Oxirgi faollikdan $gap kun o‘tdi. Streak (${user.streakDays} kun) tiklanadi.',
    );
    await _storage.setStreakAlertDay(dayKey);
    await _storage.saveUser(user.copyWith(streakDays: 0));
    return true;
  }
}
