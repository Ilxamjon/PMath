import 'package:flutter_test/flutter_test.dart';
import 'package:pmath/features/homework/domain/homework_assigner.dart';
import 'package:pmath/models/homework_model.dart';
import 'package:pmath/models/lesson_model.dart';
import 'package:pmath/models/question_model.dart';

void main() {
  test('HomeworkAssigner muddat va notebook turi beradi', () {
    const lesson = LessonModel(
      id: 'l1',
      titleUz: 'Perimetr',
      orderIndex: 1,
      topic: 'Geometriya',
      weekNumber: 1,
    );
    final now = DateTime(2026, 7, 24, 12);
    final hw = HomeworkAssigner.fromLesson(lesson, now: now);
    expect(hw.type, HomeworkType.notebook);
    expect(hw.status, HomeworkStatus.assigned);
    expect(hw.dueAt, now.add(const Duration(days: 1)));
    expect(hw.problemStatement, isNotEmpty);
    expect(hw.isPendingScan, isTrue);
  });

  test('Uyga vazifa 15 ta har xil daraja', () {
    final lesson = LessonModel(
      id: 'l1',
      titleUz: 'Taqqoslash',
      topic: 'Mantiq',
      weekNumber: 1,
      orderIndex: 0,
    );
    final set = HomeworkAssigner.setForLesson(lesson);
    expect(set.length, 15);
    expect(
      set.where((h) => h.difficulty == QuestionDifficulty.easy).length,
      5,
    );
    expect(
      set.where((h) => h.difficulty == QuestionDifficulty.hard).length,
      5,
    );
  });
}
