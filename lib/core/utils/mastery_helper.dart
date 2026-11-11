import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_constants.dart';
import '../../models/user_model.dart';

/// Nima uchun keyingi dars ochilmayapti.
enum LockBlockReason {
  none,
  masteryTooLow,
  subscriptionRequired,
}

/// `applyPracticeResult` / unlock natijasi.
class UnlockAttempt {
  const UnlockAttempt({
    required this.unlocked,
    this.blockedBy = LockBlockReason.none,
  });

  final bool unlocked;
  final LockBlockReason blockedBy;

  static const failedMastery = UnlockAttempt(
    unlocked: false,
    blockedBy: LockBlockReason.masteryTooLow,
  );

  static const failedSubscription = UnlockAttempt(
    unlocked: false,
    blockedBy: LockBlockReason.subscriptionRequired,
  );

  static const success = UnlockAttempt(unlocked: true);

  static const noNext = UnlockAttempt(unlocked: false);
}

/// Mastery Lock + sinov muddati obuna qoidalari.
abstract final class MasteryHelper {
  static double get threshold => AppConstants.masteryLockThreshold;

  static bool isMastered(double masteryPercent) {
    return masteryPercent >= threshold;
  }

  /// 80% gacha qolgan foiz (0 agar allaqachon ochiq).
  static double remainingToUnlock(double masteryPercent) {
    final left = threshold - masteryPercent;
    return left <= 0 ? 0 : left;
  }

  /// Serverdan kelgan sinov holati. Kesh bo‘lmasa kirish yo‘q.
  static bool hasSubscriptionAccess(UserModel user) {
    return user.hasAccessBeyondTrial;
  }

  static bool canUnlockNext({
    required double currentMastery,
    required UserModel user,
  }) {
    return reasonBlockingUnlock(
          currentMastery: currentMastery,
          user: user,
        ) ==
        LockBlockReason.none;
  }

  static LockBlockReason reasonBlockingUnlock({
    required double currentMastery,
    required UserModel user,
  }) {
    if (!isMastered(currentMastery)) {
      return LockBlockReason.masteryTooLow;
    }
    if (!hasSubscriptionAccess(user)) {
      return LockBlockReason.subscriptionRequired;
    }
    return LockBlockReason.none;
  }

  /// Xaritada tugma bosilganda: mastery yoki obuna.
  static LockBlockReason reasonForLockedNode({
    required double? previousMastery,
    required bool previousCompleted,
    required UserModel user,
  }) {
    if (previousMastery == null ||
        !previousCompleted ||
        !isMastered(previousMastery)) {
      return LockBlockReason.masteryTooLow;
    }
    if (!hasSubscriptionAccess(user)) {
      return LockBlockReason.subscriptionRequired;
    }
    // Mastery yetarli, lekin hali ochilmagan — odatda obuna yoki sync.
    return LockBlockReason.masteryTooLow;
  }

  static String masteryLabelUz(double percent) {
    if (percent >= 90) return 'A’lo';
    if (percent >= threshold) return 'Yaxshi';
    if (percent >= 60) return 'O‘rtacha';
    if (percent >= 40) return 'Zaif';
    return 'Boshlanish';
  }

  static Color colorFor(double percent) {
    if (percent >= threshold) return AppColors.success;
    if (percent >= 50) return AppColors.accent;
    return AppColors.error;
  }
}
