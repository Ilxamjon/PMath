import '../../../models/grading_result.dart';
import '../../../models/homework_model.dart';
import '../../../services/gamification_service.dart';

/// AI qadamma-qadam baholash.
abstract class AiGradingService {
  Future<GradingResult> grade({
    required HomeworkModel homework,
    required List<String> studentSteps,
  });
}

/// Lokal stub — GPT-4o o‘rniga qoida asosida tekshiradi.
///
/// Keyinroq: OpenAI grading prompt + expected solution JSON.
class LocalAiGradingService implements AiGradingService {
  LocalAiGradingService({GamificationService? gamification})
      : _gamification = gamification ?? GamificationService();

  final GamificationService _gamification;

  static const modelName = 'local-grader-v1';

  @override
  Future<GradingResult> grade({
    required HomeworkModel homework,
    required List<String> studentSteps,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 900));

    final expected = _expectedSteps(homework);
    final graded = <GradedStep>[];

    for (var i = 0; i < studentSteps.length; i++) {
      final student = studentSteps[i];
      final expect = i < expected.length ? expected[i] : null;
      final check = _checkStep(
        index: i,
        student: student,
        expected: expect,
        isLast: i == studentSteps.length - 1,
        homework: homework,
      );
      graded.add(check);
    }

    // Yetishmayotgan qadamlar — xato hisoblanadi.
    if (studentSteps.length < expected.length) {
      for (var i = studentSteps.length; i < expected.length; i++) {
        graded.add(
          GradedStep(
            stepIndex: i,
            studentStep: '(yo‘q)',
            isCorrect: false,
            explanationUz: 'Bu qadam yozilmagan yoki ko‘rinmagan.',
            correctHintUz: expected[i],
          ),
        );
      }
    }

    final correct = graded.where((g) => g.isCorrect).length;
    final denom = graded.isEmpty ? 1 : graded.length;
    var raw = (correct / denom) * 100;

    // Vision ishonchi bilan biroz yumshatish.
    final conf = homework.visionConfidence.clamp(0.5, 1.0);
    raw = (raw * (0.9 + 0.1 * conf)).clamp(0.0, 100.0);

    // Demo: kamida bitta xato bo‘lsa mastery 100 bo‘lmasin.
    if (graded.any((g) => !g.isCorrect) && raw > 95) {
      raw = 88;
    }

    final mastery = double.parse(raw.toStringAsFixed(1));
    final coins = _gamification.rewardForMastery(mastery);

    final feedback = mastery >= 80
        ? 'Ajoyib! Uyga vazifa ${mastery.toStringAsFixed(0)}% — Mastery Lock ochildi.'
        : mastery >= 50
            ? 'Yaxshi urinish. ${graded.where((g) => !g.isCorrect).length} ta qadamni tuzating.'
            : 'Qayta ishlash kerak. Xatolarni diqqat bilan o‘qing.';

    return GradingResult(
      masteryPercent: mastery,
      steps: graded,
      coinsEarned: coins,
      feedbackUz: feedback,
      modelName: modelName,
      expectedSteps: expected,
    );
  }

  GradedStep _checkStep({
    required int index,
    required String student,
    required String? expected,
    required bool isLast,
    required HomeworkModel homework,
  }) {
    final s = student.toLowerCase();

    // Aniq xato belgilari (stub Vision ba'zan shunday beradi).
    if (s.contains('xato') ||
        s.contains('noto‘g‘ri') ||
        s.contains('notogri') ||
        RegExp(r'=\s*999\b').hasMatch(s) ||
        RegExp(r'=\s*0\b').hasMatch(s) && isLast) {
      return GradedStep(
        stepIndex: index,
        studentStep: student,
        isCorrect: false,
        explanationUz: 'Bu qadamda hisob yoki mantiq xato.',
        correctHintUz: expected ?? _fallbackHint(homework, index),
      );
    }

    if (expected == null) {
      // Extra step — oxirgi bo‘lsa kutilgan javob bilan solishtirish.
      if (isLast) {
        final allExpected = _expectedSteps(homework);
        final answerNums = allExpected.isEmpty
            ? <int>{}
            : _extractNumbers(allExpected.last);
        if (answerNums.isNotEmpty) {
          final stu = _extractNumbers(student);
          final hit = answerNums.any(stu.contains);
          if (!hit) {
            return GradedStep(
              stepIndex: index,
              studentStep: student,
              isCorrect: false,
              explanationUz: 'Yakuniy javob noto‘g‘ri.',
              correctHintUz: allExpected.last,
            );
          }
        }
      }
      final ok = _extractNumbers(student).isNotEmpty || student.length > 8;
      return GradedStep(
        stepIndex: index,
        studentStep: student,
        isCorrect: ok,
        explanationUz: ok ? null : 'Qo‘shimcha qadam tushunarsiz.',
        correctHintUz: ok ? null : 'Faqat kerakli qadamlarni yozing.',
      );
    }

    final expNums = _extractNumbers(expected);
    final stuNums = _extractNumbers(student);

    // Oxirgi qadam: javob raqami mos kelishi kerak.
    if (isLast && expNums.isNotEmpty) {
      final answer = expNums.last;
      if (!stuNums.contains(answer)) {
        return GradedStep(
          stepIndex: index,
          studentStep: student,
          isCorrect: false,
          explanationUz: 'Yakuniy javob mos kelmadi (kutilgan: $answer).',
          correctHintUz: expected,
        );
      }
    }

    // Oraliq: kutilgan raqamlarning kamida yarmi bor.
    if (expNums.isNotEmpty) {
      final hits = expNums.where(stuNums.contains).length;
      final ratio = hits / expNums.length;
      if (ratio < 0.4) {
        return GradedStep(
          stepIndex: index,
          studentStep: student,
          isCorrect: false,
          explanationUz: 'Qadamdagi qiymatlar kutilgan yechimdan farq qiladi.',
          correctHintUz: expected,
        );
      }
    }

    // Kalit so‘zlar.
    final keywords = _keywords(expected);
    if (keywords.isNotEmpty) {
      final hit = keywords.any((k) => s.contains(k));
      if (!hit && expNums.isEmpty) {
        return GradedStep(
          stepIndex: index,
          studentStep: student,
          isCorrect: false,
          explanationUz: 'Bu qadamda kerakli mantiq yo‘q.',
          correctHintUz: expected,
        );
      }
    }

    return GradedStep(
      stepIndex: index,
      studentStep: student,
      isCorrect: true,
    );
  }

  List<String> _expectedSteps(HomeworkModel hw) {
    final text = '${hw.problemStatement ?? ''} ${hw.latexFormula ?? ''}';
    final t = text.toLowerCase();

    if (t.contains('perimetr') || t.contains('p = 2')) {
      return const [
        'P = 2(a + b)',
        'P = 2(12 + 8)',
        'P = 2 · 20',
        'P = 40',
      ];
    }
    if (t.contains(r'\frac') || t.contains('kasr') || t.contains('3/4')) {
      return const [
        r'3/4 + 1/4',
        r'(3+1)/4',
        r'4/4',
        r'= 1',
      ];
    }
    if (RegExp(r'\d+\s*[×x*]\s*\d+').hasMatch(text) || t.contains('hisoblang')) {
      final m = RegExp(r'(\d+)\s*[×x*]\s*(\d+)').firstMatch(text);
      if (m != null) {
        final a = int.parse(m.group(1)!);
        final b = int.parse(m.group(2)!);
        return [
          '$a × $b',
          '${a}ni $b marta qo‘shish',
          'Javob: ${a * b}',
        ];
      }
    }
    if (t.contains('ketma-ket') || t.contains('2, 4, 8')) {
      return const [
        'Har bir had ×2',
        '8 × 2 = 16',
        '16 × 2 = 32',
        'Keyingi: 32',
      ];
    }
    if (t.contains('yuz') || t.contains('s = a')) {
      return const [
        'S = a × b',
        'S = 5 × 7',
        'S = 35',
      ];
    }

    return const [
      'Masalani o‘qish',
      'Ma’lumotlarni yozish',
      'Hisoblash',
      'Javobni tekshirish',
    ];
  }

  String _fallbackHint(HomeworkModel hw, int index) {
    final e = _expectedSteps(hw);
    if (index < e.length) return e[index];
    return 'Qadamni qayta yozing.';
  }

  Set<int> _extractNumbers(String text) {
    return RegExp(r'\d+')
        .allMatches(text)
        .map((m) => int.tryParse(m.group(0)!) ?? -1)
        .where((n) => n >= 0)
        .toSet();
  }

  List<String> _keywords(String expected) {
    final e = expected.toLowerCase();
    final keys = <String>[];
    for (final k in [
      'perimetr',
      'yuz',
      'qo‘sh',
      'qosh',
      'ayir',
      'ko‘pay',
      'kopay',
      'javob',
      'had',
      'kasr',
    ]) {
      if (e.contains(k)) keys.add(k);
    }
    return keys;
  }
}
