import '../../../models/lesson_model.dart';
import 'socratic_bank.dart';

/// Dars xonasi uchun Sokratik kontent (to‘g‘ridan-to‘g‘ri javob bermaydi).
class LessonScript {
  const LessonScript({
    required this.introText,
    required this.socraticSteps,
    required this.hintNudge,
    required this.summaryText,
  });

  final String introText;
  final List<SocraticStep> socraticSteps;
  final String hintNudge;
  final String summaryText;

  /// Moslashuvchanlik: faqat matn ro‘yxati.
  List<String> get socraticPrompts =>
      socraticSteps.map((s) => s.prompt).toList();

  factory LessonScript.fromLesson(LessonModel lesson) {
    return LessonScript(
      introText: SocraticBank.introFor(lesson),
      socraticSteps: SocraticBank.stepsFor(lesson),
      hintNudge: SocraticBank.hintFor(lesson),
      summaryText: SocraticBank.summaryFor(lesson),
    );
  }
}
