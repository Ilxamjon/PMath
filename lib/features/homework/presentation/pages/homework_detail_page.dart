import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/navigation/app_shell_nav.dart';
import '../../../../core/utils/mastery_helper.dart';
import '../../../../models/homework_model.dart';
import '../../../../services/storage_service.dart';
import '../../../error_analysis/presentation/pages/error_analysis_page.dart';
import '../../../grading/presentation/pages/grading_page.dart';
import '../../data/homework_service.dart';

/// Yozma uyga vazifa tafsiloti — daftarga yozish + skaner.
class HomeworkDetailPage extends StatelessWidget {
  const HomeworkDetailPage({
    super.key,
    required this.homework,
    this.popToScanner = false,
  });

  final HomeworkModel homework;
  final bool popToScanner;

  @override
  Widget build(BuildContext context) {
    final dueLabel = _dueLabel(homework);
    final overdue = homework.isOverdue;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text(AppStrings.homeworkTitle)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  homework.titleUz,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.textOnPrimary,
                      ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      overdue ? Icons.warning_amber : Icons.event,
                      color: overdue ? AppColors.accent : AppColors.accent,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${AppStrings.homeworkDue}: $dueLabel',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.accent,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '${AppStrings.homeworkStatus}: ${homework.status.labelUz}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textOnPrimary.withValues(alpha: 0.85),
                      ),
                ),
              ],
            ),
          ),
          if (overdue) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.errorSoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${AppStrings.homeworkOverdue}. ${AppStrings.homeworkMissedStreak}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.error,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
          ],
          const SizedBox(height: 20),
          Text(
            AppStrings.homeworkWriteInNotebook,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.surfaceAlt),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  homework.problemStatement ?? '',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                if (homework.latexFormula != null) ...[
                  const SizedBox(height: 16),
                  Center(
                    child: Math.tex(
                      homework.latexFormula!,
                      mathStyle: MathStyle.display,
                      textStyle: const TextStyle(fontSize: 26),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.accentSoft,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              AppStrings.homeworkStepsHint,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.accentDark,
                  ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            AppStrings.homeworkParentAlert,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 28),
          if (homework.isPendingScan)
            SizedBox(
              height: 52,
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _goScan(context),
                icon: const Icon(Icons.document_scanner),
                label: const Text(AppStrings.homeworkGoScan),
              ),
            )
          else if (homework.status == HomeworkStatus.grading &&
              homework.hasVisionExtract)
            SizedBox(
              height: 52,
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => GradingPage(homework: homework),
                    ),
                  );
                  if (context.mounted) Navigator.of(context).pop(true);
                },
                icon: const Icon(Icons.grading),
                label: const Text(AppStrings.visionGoGrade),
              ),
            )
          else if (homework.status == HomeworkStatus.graded ||
              homework.status == HomeworkStatus.needsRevision)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: homework.isPassed
                    ? AppColors.successSoft
                    : AppColors.accentSoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    '${AppStrings.masteryPercent}: '
                    '${homework.masteryPercent.toStringAsFixed(0)}% · '
                    '${MasteryHelper.masteryLabelUz(homework.masteryPercent)}',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: homework.isPassed
                              ? AppColors.success
                              : AppColors.accentDark,
                        ),
                  ),
                  if (homework.aiFeedbackUz != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      homework.aiFeedbackUz!,
                      textAlign: TextAlign.center,
                    ),
                  ],
                  if (homework.errorSteps.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  ErrorAnalysisPage(homework: homework),
                            ),
                          );
                        },
                        icon: const Icon(Icons.psychology_alt),
                        label: const Text(AppStrings.gradingOpenErrors),
                      ),
                    ),
                  ],
                ],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.successSoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                AppStrings.homeworkSubmittedWait,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.success,
                    ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _goScan(BuildContext context) async {
    if (popToScanner) {
      Navigator.of(context).pop(homework);
      return;
    }
    await context.read<StorageService>().setPendingShellTab(1);
    AppShellNav.openScanner();
    Navigator.of(context).popUntil((r) => r.isFirst);
  }

  String _dueLabel(HomeworkModel hw) {
    if (hw.dueAt == null) return '—';
    final days = hw.daysUntilDue;
    if (days < 0) return AppStrings.homeworkOverdue;
    if (days == 0) return AppStrings.homeworkToday;
    if (days == 1) return AppStrings.homeworkTomorrow;
    return DateFormat('dd.MM.yyyy').format(hw.dueAt!);
  }
}

/// Ro‘yxatdan vazifa ochish yordamchisi.
Future<void> openHomeworkDetail(
  BuildContext context,
  HomeworkModel homework,
) async {
  final result = await Navigator.of(context).push<Object?>(
    MaterialPageRoute(
      builder: (_) => HomeworkDetailPage(homework: homework),
    ),
  );

  if (!context.mounted) return;
  if (result is Map && result['openScanner'] == true) {
    // MainShell IndexedStack — skaner tabiga o‘tish parent orqali.
    // Caller handle qiladi; bu yerda snackbar.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(AppStrings.homeworkGoScan),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

/// HomeworkService ni context dan olish.
HomeworkService homeworkServiceOf(BuildContext context) =>
    context.read<HomeworkService>();
