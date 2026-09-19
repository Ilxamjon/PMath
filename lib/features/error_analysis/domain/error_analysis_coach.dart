import '../../../models/homework_model.dart';

/// Bitta xato uchun bolalarga mos tahlil paketi.
class AnalyzedError {
  const AnalyzedError({
    required this.source,
    required this.titleUz,
    required this.simpleExplainUz,
    required this.socraticQuestions,
    required this.nudgeUz,
    this.softHintUz,
    this.fullHintUz,
  });

  final HomeworkErrorStep source;
  final String titleUz;
  final String simpleExplainUz;
  final List<String> socraticQuestions;
  final String nudgeUz;
  final String? softHintUz;
  final String? fullHintUz;

  int get stepNumber => source.stepIndex + 1;
}

/// Xatolarni sodda o‘zbekcha + Sokratik yo‘naltirishga aylantiradi.
///
/// To‘g‘ridan-to‘g‘ri javob bermaydi — avval o‘ylash, keyin yumshoq ishora.
class ErrorAnalysisCoach {
  const ErrorAnalysisCoach();

  List<AnalyzedError> buildFor(HomeworkModel homework) {
    return homework.errorSteps
        .map((e) => analyze(homework: homework, error: e))
        .toList();
  }

  AnalyzedError analyze({
    required HomeworkModel homework,
    required HomeworkErrorStep error,
  }) {
    final topic = _topicHint(homework);
    final student = error.studentStep;
    final base = error.explanationUz;
    final correct = error.correctHintUz;

    final simple = _kidExplain(
      base: base,
      student: student,
      topic: topic,
    );

    final questions = _socraticFor(
      topic: topic,
      student: student,
      correct: correct,
      stepIndex: error.stepIndex,
    );

    final soft = _softHint(correct: correct, topic: topic);
    final nudge =
        'Javobni darhol aytmayman. Avval o‘zingiz o‘ylab ko‘ring — '
        'qaysi joyda chalkashdingiz?';

    return AnalyzedError(
      source: error,
      titleUz: '${error.stepIndex + 1}-qadamda xato',
      simpleExplainUz: simple,
      socraticQuestions: questions,
      nudgeUz: nudge,
      softHintUz: soft,
      fullHintUz: correct,
    );
  }

  String _topicHint(HomeworkModel hw) {
    final t = '${hw.problemStatement ?? ''} ${hw.titleUz} ${hw.latexFormula ?? ''}'
        .toLowerCase();
    if (t.contains('perimetr')) return 'perimetr';
    if (t.contains('yuz') || t.contains('s =')) return 'yuz';
    if (t.contains('×') || t.contains(r'\times') || t.contains('ko‘pay')) {
      return 'ko‘paytirish';
    }
    if (t.contains('kasr') || t.contains(r'\frac')) return 'kasr';
    if (t.contains('ketma-ket')) return 'ketma-ketlik';
    return 'umumiy';
  }

  String _kidExplain({
    required String base,
    required String student,
    required String topic,
  }) {
    final shortStudent = student.length > 60
        ? '${student.substring(0, 60)}…'
        : student;

    final topicLine = switch (topic) {
      'perimetr' =>
        'Perimetr — shaklning atrofini o‘lchash. Formula va qo‘yishni tekshiring.',
      'yuz' =>
        'Yuz — ichki maydon. Ko‘paytirishda a va b ni to‘g‘ri qo‘ydingizmi?',
      'ko‘paytirish' =>
        'Ko‘paytirishda birlik va o‘nliklarni alohida hisoblab, keyin qo‘shish kerak.',
      'kasr' =>
        'Kasrlarda maxraj bir xil bo‘lishi kerak, so‘ng suratlar qo‘shiladi.',
      'ketma-ketlik' =>
        'Ketma-ketlikda qoida (masalan, ×2) har qadamda bir xil bo‘lishi kerak.',
      _ => 'Bu qadamda hisob yoki mantiq biroz chalkashgan.',
    };

    return 'Siz yozdingiz: «$shortStudent».\n\n'
        '$topicLine\n\n'
        '${base.isNotEmpty ? base : 'Bu yerda natija kutilgan yechimdan farq qiladi.'}';
  }

  List<String> _socraticFor({
    required String topic,
    required String student,
    required String? correct,
    required int stepIndex,
  }) {
    final common = <String>[
      'Bu qadamda nima qilmoqchi edingiz?',
      'Qaysi sonlar berilgan edi?',
      'Javobingizni qanday tekshirishingiz mumkin?',
    ];

    final topical = switch (topic) {
      'perimetr' => [
          'Atrofni topish uchun qaysi formula kerak?',
          'Tomoni qo‘shasizmi yoki ko‘paytirasizmi?',
        ],
      'yuz' => [
          'Yuz uchun qaysi ikkita o‘lchov kerak?',
          'Natijani qanday birlikda yozasiz?',
        ],
      'ko‘paytirish' => [
          'Birliklar ustunini alohida ko‘paytirdingizmi?',
          'Yakuniy javobni taxminan tekshirish uchun yaxlitlash mumkinmi?',
        ],
      'kasr' => [
          'Maxrajlar bir xilmi?',
          'Suratlarni qo‘shganda nima bo‘ladi?',
        ],
      'ketma-ketlik' => [
          'Har bir had oldingisiga qanday bog‘langan?',
          'Keyingi hadni topish uchun qoida nima?',
        ],
      _ => [
          'Oldingi qadam to‘g‘ri edi-mi?',
          'Bu qadamda qanday amal kerak edi?',
        ],
    };

    final fromCorrect = <String>[];
    if (correct != null && correct.isNotEmpty) {
      fromCorrect.add(
        'To‘g‘ri yo‘l «${_short(correct)}» ga o‘xshash bo‘lishi mumkin. '
        'Sizning yozganingizdan nima farq qiladi?',
      );
    }

    // 3–4 savol: topical + common + optional
    final out = <String>[
      ...topical.take(2),
      common[stepIndex % common.length],
      ...fromCorrect.take(1),
    ];
    return out.take(4).toList();
  }

  String? _softHint({required String? correct, required String topic}) {
    if (correct == null || correct.isEmpty) {
      return switch (topic) {
        'perimetr' => 'Ishora: avval formulani yozing, keyin sonlarni qo‘ying.',
        'ko‘paytirish' =>
          'Ishora: javobni kichikroq misol bilan solishtirib ko‘ring.',
        'kasr' => 'Ishora: maxrajni bir xil qiling.',
        _ => 'Ishora: oldingi to‘g‘ri qadamdan davom eting.',
      };
    }
    // To‘liq javobni ochmasdan yumshoq ishora.
    final nums = RegExp(r'\d+').allMatches(correct).map((m) => m.group(0)).toList();
    if (nums.isNotEmpty) {
      return 'Ishora: yakuniy javobda ${nums.last} soni bo‘lishi mumkin. '
          'Qanday hisoblab chiqasiz?';
    }
    return 'Ishora: «${_short(correct, 28)}…» yo‘nalishiga qarang — lekin o‘zingiz yozing.';
  }

  String _short(String s, [int max = 40]) {
    final t = s.trim();
    if (t.length <= max) return t;
    return '${t.substring(0, max)}…';
  }
}
