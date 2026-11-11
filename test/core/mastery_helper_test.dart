import 'package:flutter_test/flutter_test.dart';
import 'package:pmath/core/utils/mastery_helper.dart';
import 'package:pmath/models/user_model.dart';

void main() {
  test('Mastery Lock: 79% ochilmaydi, 80% ochiladi', () {
    expect(MasteryHelper.isMastered(79), isFalse);
    expect(MasteryHelper.isMastered(80), isTrue);
    expect(MasteryHelper.remainingToUnlock(79), 1);
    expect(MasteryHelper.remainingToUnlock(80), 0);

    final now = DateTime.now();
    final trialUser = UserModel(
      id: 'u1',
      studentName: 'Ali',
      grade: StudentGrade.grade3,
      targetSchool: 'PM',
      parentPhone: '+998901234567',
      createdAt: now,
      subscriptionStatus: SubscriptionStatus.trial,
      trialStartedAt: now,
      subscriptionExpiresAt: now.add(const Duration(days: 7)),
      serverNowAtFetch: now,
      deviceObservedAt: now,
    );
    expect(
      MasteryHelper.canUnlockNext(currentMastery: 80, user: trialUser),
      isTrue,
    );

    final expired = trialUser.copyWith(
      subscriptionStatus: SubscriptionStatus.expired,
      subscriptionExpiresAt: now.subtract(const Duration(days: 1)),
      serverNowAtFetch: now,
      deviceObservedAt: now,
    );
    expect(
      MasteryHelper.reasonBlockingUnlock(currentMastery: 85, user: expired),
      LockBlockReason.subscriptionRequired,
    );
    expect(
      MasteryHelper.reasonBlockingUnlock(currentMastery: 79, user: trialUser),
      LockBlockReason.masteryTooLow,
    );
  });

  test('79.9% bloklaydi, 80.0% ochadi', () {
    final user = _withAccess(DateTime.now());
    expect(MasteryHelper.isMastered(79.9), isFalse);
    expect(MasteryHelper.isMastered(80), isTrue);
    expect(
      MasteryHelper.reasonBlockingUnlock(currentMastery: 79.9, user: user),
      LockBlockReason.masteryTooLow,
    );
    expect(
      MasteryHelper.reasonBlockingUnlock(currentMastery: 80, user: user),
      LockBlockReason.none,
    );
    expect(MasteryHelper.canUnlockNext(currentMastery: 80, user: user), isTrue);
  });

  test('80% bo‘lsa ham muddati tugagan obuna ochmaydi', () {
    final now = DateTime.now();
    final expired = _user(now).copyWith(
      subscriptionExpiresAt: now,
      serverNowAtFetch: now,
      deviceObservedAt: now,
    );
    expect(
      MasteryHelper.reasonBlockingUnlock(currentMastery: 80, user: expired),
      LockBlockReason.subscriptionRequired,
    );
    expect(
      MasteryHelper.canUnlockNext(currentMastery: 80, user: expired),
      isFalse,
    );
  });

  test('server sanasi yo‘q bo‘lsa 80% ham obuna talab qiladi', () {
    final user = _user(DateTime.now());
    expect(
      MasteryHelper.reasonBlockingUnlock(currentMastery: 79, user: user),
      LockBlockReason.masteryTooLow,
    );
    expect(
      MasteryHelper.reasonBlockingUnlock(currentMastery: 80, user: user),
      LockBlockReason.subscriptionRequired,
    );
  });
}

UserModel _user(DateTime now) {
  return UserModel(
    id: 'u1',
    studentName: 'Ali',
    grade: StudentGrade.grade4,
    targetSchool: 'Prezident maktabi',
    parentPhone: '+998901234567',
    createdAt: now,
  );
}

UserModel _withAccess(DateTime now) {
  return _user(now).copyWith(
    trialStartedAt: now,
    subscriptionExpiresAt: now.add(const Duration(days: 7)),
    serverNowAtFetch: now,
    deviceObservedAt: now,
  );
}
