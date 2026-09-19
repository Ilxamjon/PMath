import '../../../core/constants/app_constants.dart';
import '../../../models/exam_result_model.dart';
import '../../../models/lesson_model.dart';
import '../../../models/question_model.dart';
import '../../../services/gamification_service.dart';

/// Imtihon baholash + liga o‘rni.
abstract final class ExamScorer {
  static const peerPool = 120;

  static ExamResultModel build({
    required String id,
    required String userId,
    required LessonModel lesson,
    required List<QuestionModel> questions,
    required Map<String, String> selectedAnswers,
    required int durationSeconds,
    bool timeUp = false,
    GamificationService? gamification,
  }) {
    final game = gamification ?? GamificationService();
    var correct = 0;
    final byCatCorrect = <QuestionCategory, int>{};
    final byCatTotal = <QuestionCategory, int>{};

    for (final q in questions) {
      byCatTotal[q.category] = (byCatTotal[q.category] ?? 0) + 1;
      final ans = selectedAnswers[q.id];
      if (ans != null && q.checkAnswer(ans)) {
        correct++;
        byCatCorrect[q.category] = (byCatCorrect[q.category] ?? 0) + 1;
      }
    }

    final total = questions.isEmpty ? 1 : questions.length;
    final percent = (correct / total) * 100;
    final categoryScores = <QuestionCategory, double>{};
    for (final cat in byCatTotal.keys) {
      final t = byCatTotal[cat]!;
      final c = byCatCorrect[cat] ?? 0;
      categoryScores[cat] = (c / t) * 100;
    }

    final league = leagueFor(percent);
    final rank = estimatedRank(percent);
    final coins = game.rewardForMastery(percent) +
        (percent >= 90 ? 20 : 0) +
        (lesson.coinsReward ~/ 2);

    return ExamResultModel(
      id: id,
      userId: userId,
      lessonId: lesson.id,
      weekNumber: lesson.weekNumber,
      titleUz: lesson.titleUz,
      completedAt: DateTime.now(),
      overallPercent: double.parse(percent.toStringAsFixed(1)),
      correctCount: correct,
      totalQuestions: questions.length,
      durationSeconds: durationSeconds,
      categoryScores: categoryScores,
      league: league,
      estimatedRank: rank,
      peerPool: peerPool,
      coinsEarned: coins,
      timeUp: timeUp,
    );
  }

  static LeagueTier leagueFor(double percent) {
    if (percent >= 90) return LeagueTier.diamond;
    if (percent >= 80) return LeagueTier.gold;
    if (percent >= 60) return LeagueTier.silver;
    return LeagueTier.bronze;
  }

  /// Taxminiy o‘rin: yuqori ball → yaxshiroq (kichikroq) rank.
  static int estimatedRank(double percent) {
    final p = percent.clamp(0, 100);
    final rank = ((100 - p) / 100 * (peerPool - 1)).round() + 1;
    return rank.clamp(1, peerPool);
  }

  static int durationSecondsDefault() =>
      AppConstants.examDurationMinutes * 60;
}
