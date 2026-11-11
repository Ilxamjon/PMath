import 'package:flutter_test/flutter_test.dart';
import 'package:pmath/features/error_analysis/domain/error_analysis_coach.dart';
import 'package:pmath/models/homework_model.dart';

void main() {
  test('ErrorAnalysisCoach har xato uchun Sokratik savol beradi', () {
    final hw = HomeworkModel.demo().copyWith(
      errorSteps: const [
        HomeworkErrorStep(
          stepIndex: 2,
          studentStep: 'Javob: 363',
          explanationUz: 'Yakuniy javob mos kelmadi.',
          correctHintUz: 'Javob: 360',
        ),
      ],
    );
    final items = const ErrorAnalysisCoach().buildFor(hw);
    expect(items, hasLength(1));
    expect(items.first.simpleExplainUz, contains('363'));
    expect(items.first.socraticQuestions, isNotEmpty);
    expect(items.first.softHintUz, isNotNull);
  });
}
