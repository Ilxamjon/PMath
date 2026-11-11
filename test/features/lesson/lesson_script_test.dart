import 'package:flutter_test/flutter_test.dart';
import 'package:pmath/features/lesson/domain/lesson_script.dart';
import 'package:pmath/features/lesson/domain/socratic_bank.dart';
import 'package:pmath/models/lesson_model.dart';

void main() {
  test('LessonScript Sokratik promptlarni bankdan oladi', () {
    const lesson = LessonModel(
      id: 'l1',
      titleUz: 'Perimetr',
      orderIndex: 1,
      topic: 'Geometriya',
      weekNumber: 1,
      socraticPrompts: ['Nima berilgan?', 'Qanday boshlaysiz?'],
      audioScriptUz: 'Eski matn.',
    );
    final script = LessonScript.fromLesson(lesson);
    expect(script.introText.toLowerCase(), contains('perimetr'));
    expect(script.socraticSteps.length, 10);
    expect(script.socraticSteps.any((s) => s.hasVisual), isTrue);
    expect(script.summaryText, contains('Perimetr'));
  });

  test('Shakllarni tanish savollarida chizma bor', () {
    const lesson = LessonModel(
      id: 'l2',
      titleUz: 'Shakllarni tanish',
      orderIndex: 1,
      topic: 'Geometriya',
      weekNumber: 1,
    );
    final steps = SocraticBank.stepsFor(lesson);
    expect(steps.length, 10);
    expect(steps.every((s) => s.hasVisual), isTrue);
    expect(
      steps.any((s) => s.visual == LessonVisualKind.angleRight),
      isTrue,
    );
  });

  test('SocraticBank: Taqqoslash uchun 10 ta savol', () {
    final lesson = LessonModel(
      id: 'l1',
      titleUz: 'Taqqoslash',
      topic: 'Mantiq',
      weekNumber: 1,
      orderIndex: 0,
    );
    final prompts = SocraticBank.promptsFor(lesson);
    expect(prompts.length, 10);
    expect(SocraticBank.introFor(lesson).toLowerCase(), contains('taqqos'));
  });
}
