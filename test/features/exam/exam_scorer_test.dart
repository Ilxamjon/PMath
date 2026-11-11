import 'package:flutter_test/flutter_test.dart';
import 'package:pmath/features/exam/data/exam_question_bank.dart';
import 'package:pmath/features/exam/domain/exam_scorer.dart';
import 'package:pmath/models/exam_result_model.dart';
import 'package:pmath/models/lesson_model.dart';

void main() {
  test('ExamScorer ball, liga va ranking hisoblaydi', () {
    const lesson = LessonModel(
      id: 'lesson_w4_exam',
      titleUz: 'Oy 1 mini-imtihon',
      orderIndex: 8,
      topic: 'Imtihon',
      weekNumber: 4,
      coinsReward: 40,
    );
    expect(lesson.isExam, isTrue);

    final questions = ExamQuestionBank.forWeek(4);
    expect(questions.length, 10);

    final answers = <String, String>{
      for (final q in questions) q.id: q.correctAnswer,
    };
    final result = ExamScorer.build(
      id: 'ex1',
      userId: 'u1',
      lesson: lesson,
      questions: questions,
      selectedAnswers: answers,
      durationSeconds: 600,
    );
    expect(result.overallPercent, 100);
    expect(result.league, LeagueTier.diamond);
    expect(result.estimatedRank, 1);
    expect(result.coinsEarned, greaterThan(0));
  });
}
