import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:pmath/core/constants/app_constants.dart';
import 'package:pmath/features/practice/domain/practice_question_factory.dart';
import 'package:pmath/models/lesson_model.dart';
import 'package:pmath/models/question_model.dart';

void main() {
  test('PracticeQuestionFactory 15 ta savol qaytaradi', () {
    const lesson = LessonModel(
      id: 'l1',
      titleUz: 'Ko‘paytirish jadvali',
      orderIndex: 1,
      topic: 'Arifmetika',
      weekNumber: 1,
    );
    final qs = PracticeQuestionFactory.forLesson(lesson, random: Random(42));
    expect(qs.length, 15);
    expect(qs.every((q) => q.options.isNotEmpty), isTrue);
  });

  test('Practice 15 ta: 5/5/5 daraja', () {
    final lesson = LessonModel(
      id: 'l1',
      titleUz: 'Taqqoslash',
      topic: 'Mantiq',
      weekNumber: 1,
      orderIndex: 0,
    );
    final qs = PracticeQuestionFactory.forLesson(lesson, random: Random(1));
    expect(qs.length, AppConstants.practiceExerciseMax);
    expect(qs.where((q) => q.difficulty == QuestionDifficulty.easy).length, 5);
    expect(
        qs.where((q) => q.difficulty == QuestionDifficulty.medium).length, 5);
    expect(qs.where((q) => q.difficulty == QuestionDifficulty.hard).length, 5);
  });
}
