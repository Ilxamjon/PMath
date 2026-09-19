import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../domain/proctoring_guard.dart';

/// Yuz/e’tibor buzilganda to‘liq ekran modal — test pauzalanadi.
Future<void> showProctoringWarningDialog(
  BuildContext context, {
  required ProctoringEvent reason,
  required int warningCount,
  required VoidCallback onResume,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) {
      return PopScope(
        canPop: false,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.errorSoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: AppColors.error,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  reason.titleUz,
                  style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                reason.bodyUz,
                style: Theme.of(ctx).textTheme.titleMedium,
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.accentSoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${AppStrings.proctoringWarningCount}: $warningCount',
                  style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                        color: AppColors.accentDark,
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                AppStrings.proctoringParentNotified,
                style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                onResume();
              },
              child: const Text(AppStrings.proctoringResume),
            ),
          ],
        ),
      );
    },
  );
}
