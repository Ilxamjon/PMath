import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../models/homework_model.dart';
import '../../../../models/vision_analysis_result.dart';
import '../../../grading/presentation/pages/grading_page.dart';

/// Vision AI qadamlar natijasi (JSON ko‘rinishida).
class ScanResultPage extends StatelessWidget {
  const ScanResultPage({
    super.key,
    required this.homework,
    required this.analysis,
  });

  final HomeworkModel homework;
  final VisionAnalysisResult analysis;

  @override
  Widget build(BuildContext context) {
    final map = Map<String, dynamic>.from(analysis.toJson())
      ..remove('imagePath')
      ..['homeworkId'] = homework.id
      ..['status'] = homework.status.name;
    final jsonPretty = const JsonEncoder.withIndent('  ').convert(map);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text(AppStrings.visionResultTitle)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (homework.imagePath != null &&
              File(homework.imagePath!).existsSync() &&
              !homework.imagePath!.endsWith('.txt'))
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.file(
                File(homework.imagePath!),
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(
                  AppStrings.visionStepsTitle,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.successSoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${AppStrings.visionConfidence}: ${(analysis.confidence * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(
                    color: AppColors.success,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...analysis.steps.asMap().entries.map((e) {
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.surfaceAlt),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: AppColors.accent,
                    child: Text(
                      '${e.key + 1}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      e.value,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 8),
          Text(
            AppStrings.visionJsonPreview,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryDark,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              jsonPretty,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 11,
                color: AppColors.accent,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.accentSoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              AppStrings.visionReadyForGrade,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.accentDark,
                  ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: () async {
                final graded = await Navigator.of(context).push<bool>(
                  MaterialPageRoute(
                    builder: (_) => GradingPage(homework: homework),
                  ),
                );
                if (!context.mounted) return;
                Navigator.of(context).pop(graded ?? true);
              },
              child: const Text(AppStrings.visionGoGrade),
            ),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(AppStrings.visionBackScanner),
          ),
        ],
      ),
    );
  }
}
