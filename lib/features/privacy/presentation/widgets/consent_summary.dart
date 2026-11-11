import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';

/// Rozilik ekranidagi qoralama izoh. Yuridik matn emas.
class ConsentSummary extends StatelessWidget {
  const ConsentSummary({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.warning.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            AppStrings.privacyDraft,
            style: text.bodyMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
        ),
        const SizedBox(height: 12),
        const _ConsentRow(
          title: AppStrings.privacyNameTitle,
          why: AppStrings.privacyNameWhy,
          keep: AppStrings.privacyNameKeep,
        ),
        const _ConsentRow(
          title: AppStrings.privacyGradeTitle,
          why: AppStrings.privacyGradeWhy,
          keep: AppStrings.privacyGradeKeep,
        ),
        const _ConsentRow(
          title: AppStrings.privacyPhoneTitle,
          why: AppStrings.privacyPhoneWhy,
          keep: AppStrings.privacyPhoneKeep,
        ),
        const _ConsentRow(
          title: AppStrings.privacyImageTitle,
          why: AppStrings.privacyImageWhy,
          keep: AppStrings.privacyImageKeep,
        ),
        const _ConsentRow(
          title: AppStrings.privacyFaceTitle,
          why: AppStrings.privacyFaceWhy,
          keep: AppStrings.privacyFaceKeep,
        ),
        const SizedBox(height: 8),
        Text(AppStrings.privacyDeclineHint, style: text.bodyMedium),
      ],
    );
  }
}

class _ConsentRow extends StatelessWidget {
  const _ConsentRow({
    required this.title,
    required this.why,
    required this.keep,
  });

  final String title;
  final String why;
  final String keep;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: text.titleMedium),
          const SizedBox(height: 2),
          Text('${AppStrings.privacyWhy}: $why', style: text.bodyMedium),
          Text('${AppStrings.privacyKeep}: $keep', style: text.bodyMedium),
        ],
      ),
    );
  }
}
