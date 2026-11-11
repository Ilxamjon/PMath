import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pmath/core/storage/store_keys.dart';
import 'package:pmath/core/utils/iso_week.dart';
import 'package:pmath/models/homework_model.dart';
import 'package:pmath/models/user_model.dart';
import 'package:pmath/services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('prefs bir marta SQLite ga ko‘chadi, keyin prefs e’tiborsiz', () async {
    final dir = await Directory.systemTemp.createTemp('pmath_mig');
    final file = File('${dir.path}${Platform.pathSeparator}pmath.sqlite');
    final now = DateTime.utc(2026, 11, 11, 8);
    final user = UserModel(
      id: 'u1',
      studentName: 'Ali',
      grade: StudentGrade.grade4,
      targetSchool: 'Prezident maktabi',
      parentPhone: '+998901234567',
      createdAt: now,
      coins: 3,
    );
    final homework = HomeworkModel(
      id: 'hw-1',
      lessonId: 'l1',
      titleUz: 'Qo‘shish',
      assignedAt: now,
    );

    SharedPreferences.setMockInitialValues({
      PrefsKeys.user: jsonEncode(user.toJson()),
      PrefsKeys.homeworkList: jsonEncode([homework.toJson()]),
      PrefsKeys.onboardingDone: true,
      PrefsKeys.weeklyXp: 12,
      PrefsKeys.weeklyXpWeek: isoWeekKey(now),
    });
    final prefs = await SharedPreferences.getInstance();
    final first = await StorageService.open(
      prefs: prefs,
      executor: NativeDatabase(file),
      now: () => now,
    );

    expect(first.getUser()?.studentName, 'Ali');
    expect(first.getUser()?.coins, 3);
    expect(first.getHomeworkList().single.titleUz, 'Qo‘shish');
    expect(first.isOnboardingDone, isTrue);
    expect(first.getWeeklyXp(), 12);
    await first.close();

    await prefs.setString(
      PrefsKeys.user,
      jsonEncode(user.copyWith(studentName: 'Boshqa', coins: 99).toJson()),
    );
    await prefs.setString(PrefsKeys.homeworkList, '[]');
    await prefs.setBool(PrefsKeys.onboardingDone, false);
    await prefs.setInt(PrefsKeys.weeklyXp, 1);
    final second = await StorageService.open(
      prefs: prefs,
      executor: NativeDatabase(file),
      now: () => now,
    );

    expect(second.getUser()?.studentName, 'Ali');
    expect(second.getUser()?.coins, 3);
    expect(second.getHomeworkList().single.id, 'hw-1');
    expect(second.isOnboardingDone, isTrue);
    expect(second.getWeeklyXp(), 12);
    await second.close();
    await dir.delete(recursive: true);
  });
}
