import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/mastery_helper.dart';

/// Mastery Lock: 80% yetmaganda o‘zbekcha blok modal.
Future<void> showMasteryLockDialog(
  BuildContext context, {
  required String previousLessonTitle,
  required double previousMastery,
}) {
  final remaining = MasteryHelper.remainingToUnlock(previousMastery);
  final threshold = MasteryHelper.threshold.toStringAsFixed(0);

  return showDialog<void>(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.accentSoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.lock_rounded, color: AppColors.accentDark),
            ),
            const SizedBox(width: 12),
            const Expanded(child: Text(AppStrings.masteryLockTitle)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.masteryLockBody
                  .replaceAll('{title}', previousLessonTitle)
                  .replaceAll('{pct}', previousMastery.toStringAsFixed(0))
                  .replaceAll('{need}', threshold),
              style: Theme.of(ctx).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: (previousMastery / 100).clamp(0.0, 1.0),
                minHeight: 10,
                backgroundColor: AppColors.surfaceAlt,
                color: MasteryHelper.colorFor(previousMastery),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              remaining > 0
                  ? AppStrings.masteryLockRemaining
                      .replaceAll('{left}', remaining.toStringAsFixed(0))
                  : AppStrings.masteryRequired,
              style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              AppStrings.masteryLockHint,
              style: Theme.of(ctx).textTheme.bodyMedium,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(AppStrings.ok),
          ),
        ],
      );
    },
  );
}

/// 7 kundan keyin obuna talab qilinadi.
Future<bool?> showSubscriptionGateDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.errorSoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.workspace_premium, color: AppColors.error),
            ),
            const SizedBox(width: 12),
            const Expanded(child: Text(AppStrings.subscriptionGateTitle)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.subscriptionGateBody
                  .replaceAll('{days}', '${AppConstants.freeTrialDays}'),
              style: Theme.of(ctx).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Text(
              AppStrings.subscriptionGatePrices
                  .replaceAll(
                    '{m}',
                    _formatPrice(AppConstants.monthlyPriceUzs),
                  )
                  .replaceAll(
                    '{s}',
                    _formatPrice(AppConstants.sixMonthPriceUzs),
                  ),
              style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(AppStrings.subscriptionGateCta),
          ),
        ],
      );
    },
  );
}

String _formatPrice(int uzs) {
  final s = uzs.toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    final fromEnd = s.length - i;
    buf.write(s[i]);
    if (fromEnd > 1 && fromEnd % 3 == 1) buf.write(' ');
  }
  return '$buf so‘m';
}
