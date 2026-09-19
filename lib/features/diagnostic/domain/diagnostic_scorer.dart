import '../../../core/constants/app_constants.dart';
import '../../../models/diagnostic_result_model.dart';
import '../../../models/question_model.dart';

/// Diagnostik javoblardan foiz va zaif/kuchli kategoriyalarni hisoblash.
abstract final class DiagnosticScorer {
  static DiagnosticResultModel buildResult({
    required String id,
    required String userId,
    required List<QuestionModel> questions,
    required Map<String, String> selectedAnswers,
    required int durationSeconds,
  }) {
    final answers = <DiagnosticAnswer>[];

    for (final q in questions) {
      final selected = selectedAnswers[q.id] ?? '';
      answers.add(
        DiagnosticAnswer(
          questionId: q.id,
          selectedAnswer: selected,
          isCorrect: selected.isNotEmpty && q.checkAnswer(selected),
          category: q.category,
        ),
      );
    }

    final correctCount = answers.where((a) => a.isCorrect).length;
    final totalCount = questions.length;
    final overall =
        totalCount == 0 ? 0.0 : (correctCount / totalCount) * 100;

    final categoryScores = <String, double>{};
    for (final cat in QuestionCategory.values) {
      final inCat = answers.where((a) => a.category == cat).toList();
      if (inCat.isEmpty) continue;
      final ok = inCat.where((a) => a.isCorrect).length;
      categoryScores[cat.labelUz] = (ok / inCat.length) * 100;
    }

    final weak = <String>[];
    final strong = <String>[];
    categoryScores.forEach((label, score) {
      if (score < AppConstants.weakCategoryThreshold) {
        weak.add(label);
      } else if (score >= AppConstants.strongCategoryThreshold) {
        strong.add(label);
      }
    });

    return DiagnosticResultModel(
      id: id,
      userId: userId,
      completedAt: DateTime.now(),
      answers: answers,
      categoryScores: categoryScores,
      overallPercent: overall,
      correctCount: correctCount,
      totalCount: totalCount,
      weakCategories: weak,
      strongCategories: strong,
      durationSeconds: durationSeconds,
    );
  }
}
