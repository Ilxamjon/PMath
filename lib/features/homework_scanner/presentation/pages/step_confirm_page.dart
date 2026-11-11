import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../models/homework_model.dart';
import '../../../../models/vision_analysis_result.dart';
import '../../../grading/presentation/pages/grading_page.dart';
import '../../../homework/data/homework_service.dart';

/// Past ishonch: qadamlarni tahrirlab, keyin baholash.
class StepConfirmPage extends StatefulWidget {
  const StepConfirmPage({
    super.key,
    required this.homework,
    required this.analysis,
  });

  final HomeworkModel homework;
  final VisionAnalysisResult analysis;

  @override
  State<StepConfirmPage> createState() => _StepConfirmPageState();
}

class _StepConfirmPageState extends State<StepConfirmPage> {
  late final List<TextEditingController> _steps;
  var _saving = false;

  @override
  void initState() {
    super.initState();
    _steps = widget.analysis.steps
        .map((step) => TextEditingController(text: step))
        .toList();
  }

  @override
  void dispose() {
    for (final controller in _steps) {
      controller.dispose();
    }
    super.dispose();
  }

  bool get _canGrade =>
      _steps.isNotEmpty && _steps.every((item) => item.text.trim().isNotEmpty);

  Future<void> _confirm() async {
    if (!_canGrade || _saving) return;
    setState(() => _saving = true);
    try {
      final updated = await context.read<HomeworkService>().replaceExtractedSteps(
            homework: widget.homework,
            steps: _steps.map((item) => item.text.trim()).toList(),
          );
      if (!mounted) return;
      final graded = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (_) => GradingPage(homework: updated),
        ),
      );
      if (!mounted) return;
      Navigator.of(context).pop(graded ?? true);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.somethingWrong)),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text(AppStrings.visionConfirmTitle)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            AppStrings.visionConfirmHint,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            '${AppStrings.visionConfidence}: ${(widget.analysis.confidence * 100).toStringAsFixed(0)}%',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: 16),
          ..._steps.asMap().entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TextField(
                controller: entry.value,
                minLines: 2,
                maxLines: 4,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  labelText: 'Qadam ${entry.key + 1}',
                  filled: true,
                  fillColor: AppColors.surface,
                ),
              ),
            );
          }),
          const SizedBox(height: 8),
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: _canGrade && !_saving ? _confirm : null,
              child: Text(
                _saving ? AppStrings.loading : AppStrings.visionConfirmGrade,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
