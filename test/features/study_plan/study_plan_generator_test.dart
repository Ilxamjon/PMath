import 'package:flutter_test/flutter_test.dart';
import 'package:pmath/features/study_plan/domain/ai_study_plan_generator.dart';
import 'package:pmath/models/diagnostic_result_model.dart';
import 'package:pmath/models/question_model.dart';

void main() {
  test('AI study plan 24 hafta va zaif mavzuni ustuvorlashtiradi', () async {
    final diagnostic = DiagnosticResultModel(
      id: 'd1',
      userId: 'u1',
      completedAt: DateTime.now(),
      answers: const [],
      categoryScores: {
        QuestionCategory.geometry.labelUz: 30,
        QuestionCategory.arithmetic.labelUz: 90,
        QuestionCategory.logic.labelUz: 70,
        QuestionCategory.logicSequences.labelUz: 50,
      },
      overallPercent: 60,
      correctCount: 6,
      totalCount: 10,
      weakCategories: [QuestionCategory.geometry.labelUz],
      strongCategories: [QuestionCategory.arithmetic.labelUz],
    );

    final generator = LocalAiStudyPlanGenerator();
    final bundle = await generator.generate(
      userId: 'u1',
      diagnostic: diagnostic,
    );

    expect(bundle.plan.totalWeeks, 24);
    expect(bundle.lessons, isNotEmpty);
    expect(bundle.lessons.first.status.name, 'available');
    expect(bundle.plan.weakCategories, contains('Geometriya'));

    // Dastlabki oddiy haftalarda geometriya ko‘proq uchrashi kerak.
    final earlyTopics = bundle.lessons
        .where((l) => l.weekNumber <= 8 && l.topic != 'Imtihon')
        .map((l) => l.topic)
        .toList();
    final geoCount = earlyTopics.where((t) => t == 'Geometriya').length;
    final arithCount = earlyTopics.where((t) => t == 'Arifmetika').length;
    expect(geoCount, greaterThanOrEqualTo(arithCount));
  });
}
