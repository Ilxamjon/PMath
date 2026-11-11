import 'package:flutter_test/flutter_test.dart';
import 'package:pmath/models/user_model.dart';
import 'package:pmath/services/parent_alert_service.dart';
import 'package:pmath/services/storage_service.dart';
import 'package:pmath/services/streak_monitor.dart';
import 'package:pmath/models/parent_alert_log.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('StreakMonitor uzilganda alert yuboradi', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = await StorageService.init();
    final alerts = StubParentAlertService();

    await storage.saveUser(
      UserModel(
        id: 'u1',
        studentName: 'Ali',
        grade: StudentGrade.grade3,
        targetSchool: 'PM',
        parentPhone: '+998901234567',
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        streakDays: 5,
        lastActiveDate: DateTime.now().subtract(const Duration(days: 3)),
      ),
    );

    final hit = await StreakMonitor(storage: storage, alerts: alerts)
        .checkAndAlert();
    expect(hit, isTrue);
    expect(
      alerts.sentLog.any((e) => e.type == ParentAlertType.streakAtRisk),
      isTrue,
    );
    expect(storage.getUser()!.streakDays, 0);
  });
}
