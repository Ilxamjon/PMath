import 'package:flutter_test/flutter_test.dart';
import 'package:pmath/features/grading/domain/ai_grading_service.dart';
import 'package:pmath/models/homework_model.dart';

void main() {
  test('AI Grading mastery va xato qadamlarni qaytaradi', () async {
    final hw = HomeworkModel.demo().copyWith(
      extractedSteps: const [
        'Berilgan: 24 × 15',
        '24ni 15 marta qo‘shish',
        'Oraliq: 336',
        'Javob: 363',
      ],
      visionConfidence: 0.9,
    );
    final result = await LocalAiGradingService().grade(
      homework: hw,
      studentSteps: hw.extractedSteps,
    );
    expect(result.masteryPercent, inInclusiveRange(0, 100));
    expect(result.steps, isNotEmpty);
    expect(result.errorCount, greaterThan(0));
    expect(result.coinsEarned, greaterThanOrEqualTo(0));
    expect(result.feedbackUz, isNotEmpty);
  });

  test('to‘g‘ri qadamlarning hammasi qabul qilinadi', () async {
    final hw = _multiply();
    final result = await LocalAiGradingService().grade(
      homework: hw,
      studentSteps: const [
        '24 × 15',
        '24ni 15 marta qo‘shish',
        'Javob: 360',
      ],
    );
    expect(result.steps.every((step) => step.isCorrect), isTrue);
    expect(result.errorCount, 0);
    expect(result.masteryPercent, greaterThanOrEqualTo(80));
  });

  test('noto‘g‘ri yakuniy javob xato qadam bo‘ladi', () async {
    final result = await LocalAiGradingService().grade(
      homework: _multiply(),
      studentSteps: const [
        '24 × 15',
        '24ni 15 marta qo‘shish',
        'Javob: 363',
      ],
    );
    expect(result.steps.last.isCorrect, isFalse);
    expect(result.steps.last.explanationUz, contains('360'));
    expect(result.errorCount, greaterThan(0));
  });

  test('bo‘sh kirish yozilmagan qadamlarni xato qiladi', () async {
    final result = await LocalAiGradingService().grade(
      homework: _multiply(),
      studentSteps: const [],
    );
    expect(result.steps, isNotEmpty);
    expect(result.steps.every((step) => step.isCorrect), isFalse);
    expect(result.masteryPercent, 0);
    expect(result.feedbackUz, contains('Qayta ishlash'));
  });
}

HomeworkModel _multiply() {
  return HomeworkModel(
    id: 'g1',
    lessonId: 'l1',
    titleUz: 'Ko‘paytirish',
    assignedAt: DateTime.utc(2026, 11, 11),
    problemStatement: '24 × 15 ni hisoblang',
    visionConfidence: 1,
  );
}
