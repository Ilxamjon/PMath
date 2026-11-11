import 'package:flutter_test/flutter_test.dart';
import 'package:pmath/core/utils/mastery_helper.dart';
import 'package:pmath/models/user_model.dart';

void main() {
  test('soatni orqaga surish trialni uzaytirmaydi', () {
    final serverNow = DateTime.utc(2026, 11, 5, 12);
    final observed = DateTime(2026, 11, 5, 17);
    final user = UserModel(
      id: 'u1',
      studentName: 'Ali',
      grade: StudentGrade.grade3,
      targetSchool: 'PM',
      parentPhone: '+998901234567',
      createdAt: serverNow,
      trialStartedAt: serverNow,
      subscriptionExpiresAt: serverNow.add(const Duration(days: 1)),
      serverNowAtFetch: serverNow,
      deviceObservedAt: observed,
    );

    final days = user.trialDaysLeftAt(observed);
    expect(days, 1);
    expect(
      user.trialDaysLeftAt(observed.subtract(const Duration(days: 30))),
      days,
    );
    expect(
      user.hasAccessAt(observed.add(const Duration(days: 2))),
      isFalse,
    );
    expect(
      MasteryHelper.reasonBlockingUnlock(
        currentMastery: 90,
        user: user.copyWith(
          subscriptionExpiresAt: serverNow.subtract(const Duration(hours: 1)),
          serverNowAtFetch: serverNow,
          deviceObservedAt: observed,
        ),
      ),
      LockBlockReason.subscriptionRequired,
    );
  });
}
