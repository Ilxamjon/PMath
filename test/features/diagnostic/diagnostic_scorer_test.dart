import 'package:flutter_test/flutter_test.dart';
import 'package:pmath/features/diagnostic/data/diagnostic_question_bank.dart';
import 'package:pmath/features/diagnostic/domain/diagnostic_scorer.dart';

void main() {
  test('Diagnostik scorer kategoriya foizlarini hisoblaydi', () {
    final questions = DiagnosticQuestionBank.all;
    final answers = <String, String>{
      for (final q in questions) q.id: q.correctAnswer,
    };

    final result = DiagnosticScorer.buildResult(
      id: 'test',
      userId: 'u1',
      questions: questions,
      selectedAnswers: answers,
      durationSeconds: 120,
    );

    expect(result.correctCount, 10);
    expect(result.overallPercent, 100);
    expect(result.strongCategories.length, greaterThan(0));
    expect(result.weakCategories, isEmpty);
  });

  test('Savollar banki 10 ta va 4 kategoriya', () {
    final all = DiagnosticQuestionBank.all;
    expect(all.length, 10);
    final cats = all.map((q) => q.category).toSet();
    expect(cats.length, 4);
  });
}
