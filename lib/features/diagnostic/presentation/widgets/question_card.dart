import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../models/question_model.dart';

/// Savol matni + ixtiyoriy LaTeX formula.
class QuestionCard extends StatelessWidget {
  const QuestionCard({super.key, required this.question});

  final QuestionModel question;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.accentSoft,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              question.category.labelUz,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.accentDark,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            question.prompt,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          if (question.latexFormula != null) ...[
            const SizedBox(height: 16),
            Center(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Math.tex(
                  question.latexFormula!,
                  mathStyle: MathStyle.display,
                  textStyle: const TextStyle(fontSize: 28),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Variant tanlash tugmalari.
class AnswerOptions extends StatelessWidget {
  const AnswerOptions({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  final List<String> options;
  final String? selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: options.map((opt) {
        final isSelected = selected == opt;
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => onSelected(opt),
              borderRadius: BorderRadius.circular(16),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.accentSoft : AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? AppColors.accent : AppColors.surfaceAlt,
                    width: isSelected ? 2.5 : 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isSelected
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off,
                      color: isSelected
                          ? AppColors.accentDark
                          : AppColors.textMuted,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        opt,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: isSelected
                                  ? AppColors.accentDark
                                  : AppColors.textPrimary,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
