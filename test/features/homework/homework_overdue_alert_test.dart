import 'package:flutter_test/flutter_test.dart';
import 'package:pmath/features/homework/data/homework_service.dart';
import 'package:pmath/models/homework_model.dart';
import 'package:pmath/models/parent_alert_log.dart';
import 'package:pmath/models/user_model.dart';
import 'package:pmath/services/parent_alert_service.dart';
import 'package:pmath/services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Missed homework → ota-ona overdue alert', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = await StorageService.init();
    final alerts = StubParentAlertService();
    final hwService = HomeworkService(storage: storage, alerts: alerts);

    final user = UserModel(
      id: 'u1',
      studentName: 'Ali',
      grade: StudentGrade.grade3,
      targetSchool: 'PM',
      parentPhone: '+998901234567',
      createdAt: DateTime.now(),
      streakDays: 3,
    );
    await storage.saveUser(user);

    final overdue = HomeworkModel.demo().copyWith(
      id: 'hw-late',
      dueAt: DateTime.now().subtract(const Duration(days: 2)),
      status: HomeworkStatus.assigned,
    );
    await storage.upsertHomework(overdue);

    final n = await hwService.checkOverdueAndAlert();
    expect(n, 1);
    expect(alerts.sentLog.any((e) => e.type == ParentAlertType.homeworkOverdue),
        isTrue);
    expect(alerts.sentLog.any((e) => e.type == ParentAlertType.streakAtRisk),
        isTrue);

    // Dedupe: ikkinchi chaqiriqda qayta yubormasligi kerak.
    final n2 = await hwService.checkOverdueAndAlert();
    expect(n2, 0);
  });
}
