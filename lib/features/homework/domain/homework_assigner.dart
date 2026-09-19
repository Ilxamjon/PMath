import 'package:uuid/uuid.dart';

import '../../../core/constants/app_constants.dart';
import '../../../models/homework_model.dart';
import '../../../models/lesson_model.dart';
import '../../../models/question_model.dart';

/// Darsdan keyin 15 ta yozma uyga vazifa (5 oson + 5 o‘rta + 5 qiyin).
abstract final class HomeworkAssigner {
  /// Bitta (eski API) — birinchi vazifani qaytaradi.
  static HomeworkModel fromLesson(
    LessonModel lesson, {
    DateTime? now,
    Uuid? uuid,
  }) {
    return setForLesson(lesson, now: now, uuid: uuid).first;
  }

  /// 15 ta alohida daftarga yoziladigan vazifa.
  static List<HomeworkModel> setForLesson(
    LessonModel lesson, {
    DateTime? now,
    Uuid? uuid,
  }) {
    final at = now ?? DateTime.now();
    final idGen = uuid ?? const Uuid();
    final problems = _problemsFor(lesson);
    assert(problems.length >= AppConstants.homeworkPerLesson);

    return List.generate(AppConstants.homeworkPerLesson, (i) {
      final p = problems[i];
      final diffLabel = p.difficulty.labelUz;
      return HomeworkModel(
        id: idGen.v4(),
        lessonId: lesson.id,
        titleUz: '${lesson.titleUz} · ${i + 1}/15 ($diffLabel)',
        assignedAt: at,
        dueAt: at.add(const Duration(days: AppConstants.homeworkDueDays)),
        type: HomeworkType.notebook,
        status: HomeworkStatus.assigned,
        problemStatement: p.statement,
        latexFormula: p.latex,
        difficulty: p.difficulty,
      );
    });
  }

  static List<_HwProblem> _problemsFor(LessonModel lesson) {
    final topic = '${lesson.topic} ${lesson.titleUz}'.toLowerCase();
    if (topic.contains('taqqos') || topic.contains('mantiq')) {
      return _logicProblems;
    }
    if (topic.contains('ketma') || topic.contains('naqsh')) {
      return _sequenceProblems;
    }
    if (topic.contains('geometr') ||
        topic.contains('perimetr') ||
        topic.contains('yuza') ||
        topic.contains('shakl')) {
      return _geometryProblems;
    }
    if (topic.contains('imtihon')) {
      return _examProblems;
    }
    return _arithmeticProblems;
  }

  static const _arithmeticProblems = <_HwProblem>[
    _HwProblem('Oson: 36 + 47 ni ustun usulida yeching.', r'36+47', QuestionDifficulty.easy),
    _HwProblem('Oson: 9 × 8 ni yozib hisoblang.', r'9\times8', QuestionDifficulty.easy),
    _HwProblem('Oson: 100 − 58.', r'100-58', QuestionDifficulty.easy),
    _HwProblem('Oson: 72 ÷ 8.', r'72\div8', QuestionDifficulty.easy),
    _HwProblem('Oson: 15 × 4 + 6.', r'15\times4+6', QuestionDifficulty.easy),
    _HwProblem('O‘rta: 48 × 12 ni qadamma-qadam yeching.', r'48\times12', QuestionDifficulty.medium),
    _HwProblem('O‘rta: 2/4 ni soddalashtiring va tushuntiring.', r'\frac{2}{4}', QuestionDifficulty.medium),
    _HwProblem('O‘rta: 144 ÷ 12 va tekshiruv yozing.', r'144\div12', QuestionDifficulty.medium),
    _HwProblem('O‘rta: 25 × 4 + 10.', r'25\times4+10', QuestionDifficulty.medium),
    _HwProblem('O‘rta: 3/4 va 6/8 tengligini isbotlang.', null, QuestionDifficulty.medium),
    _HwProblem('Qiyin: 48 × 15.', r'48\times15', QuestionDifficulty.hard),
    _HwProblem('Qiyin: Sonning 20% i 16. Sonni toping.', null, QuestionDifficulty.hard),
    _HwProblem('Qiyin: (36+14)×3−20.', r'(36+14)\times3-20', QuestionDifficulty.hard),
    _HwProblem('Qiyin: 1/2 + 1/3.', r'\frac{1}{2}+\frac{1}{3}', QuestionDifficulty.hard),
    _HwProblem('Qiyin: 240 so‘mlik kitobga 15% chegirma. Yangi narx?', null, QuestionDifficulty.hard),
  ];

  static const _logicProblems = <_HwProblem>[
    _HwProblem('Oson: 3 olma va 5 nok — qaysi ko‘proq? Chizing.', null, QuestionDifficulty.easy),
    _HwProblem('Oson: 120 sm va 1 m — qaysi uzun? Birlikni yozing.', null, QuestionDifficulty.easy),
    _HwProblem('Oson: Eng katta: 19, 91, 99, 90.', null, QuestionDifficulty.easy),
    _HwProblem('Oson: Ortiqcha: mushuk, it, qush, stol.', null, QuestionDifficulty.easy),
    _HwProblem('Oson: Stolda 5 qalam, 2 sini oldingiz. Nechta qoldi?', null, QuestionDifficulty.easy),
    _HwProblem('O‘rta: 2 kg va 1500 g — qaysi og‘ir? Hisob yozing.', null, QuestionDifficulty.medium),
    _HwProblem('O‘rta: A>B, B>C bo‘lsa A va C?', null, QuestionDifficulty.medium),
    _HwProblem('O‘rta: 8 sm va 1 dm taqqoslang.', null, QuestionDifficulty.medium),
    _HwProblem('O‘rta: Ballar 12, 18, 15 — eng yuqori va o‘rtacha.', null, QuestionDifficulty.medium),
    _HwProblem('O‘rta: O‘zingiz 2 narsani 1 belgi bo‘yicha taqqoslang.', null, QuestionDifficulty.medium),
    _HwProblem('Qiyin: Ali Bekdan 3 yosh katta, Bek 9. Ali?', null, QuestionDifficulty.hard),
    _HwProblem('Qiyin: 4×200 g kitob vs 900 g sumka — qaysi og‘ir?', null, QuestionDifficulty.hard),
    _HwProblem('Qiyin: 14:00 va tushdan keyin 2:00 bir xilmi? Izoh.', null, QuestionDifficulty.hard),
    _HwProblem('Qiyin: Jadval tuzing: 3 o‘quvchi ballari va eng yaxshisi.', null, QuestionDifficulty.hard),
    _HwProblem('Qiyin: Har kuni 2 sm o‘sadi. 5 kunda? Chizma + yechim.', null, QuestionDifficulty.hard),
  ];

  static const _geometryProblems = <_HwProblem>[
    _HwProblem('Oson: Kvadrat tomoni 7 sm. Perimetr. Chizing.', r'P=4\times7', QuestionDifficulty.easy),
    _HwProblem('Oson: To‘g‘ri burchak necha gradus? Chizing.', null, QuestionDifficulty.easy),
    _HwProblem('Oson: Uchburchak burchaklari soni?', null, QuestionDifficulty.easy),
    _HwProblem('Oson: Kvadrat tomoni 5. Yuza?', r'S=5\times5', QuestionDifficulty.easy),
    _HwProblem('Oson: Doiraning uchi bormi? Izoh.', null, QuestionDifficulty.easy),
    _HwProblem('O‘rta: To‘g‘ri to‘rtburchak a=5, b=3. Yuza va perimetr.', null, QuestionDifficulty.medium),
    _HwProblem('O‘rta: Uchburchak burchaklari yig‘indisi. Misollar.', null, QuestionDifficulty.medium),
    _HwProblem('O‘rta: Kvadrat tomoni 9. Yuza.', r'9\times9', QuestionDifficulty.medium),
    _HwProblem('O‘rta: a=7, b=4 perimetr.', null, QuestionDifficulty.medium),
    _HwProblem('O‘rta: O‘tkir va o‘tmas burchakni chizing.', null, QuestionDifficulty.medium),
    _HwProblem('Qiyin: Burchaklar 40° va 65°. Uchinchi?', null, QuestionDifficulty.hard),
    _HwProblem('Qiyin: Perimetr 36 bo‘lgan kvadratning yuzi?', null, QuestionDifficulty.hard),
    _HwProblem('Qiyin: Yuza 48, a=8. b=?', null, QuestionDifficulty.hard),
    _HwProblem('Qiyin: L-shakl: 6×4 dan 2×2 ayirilgan. Yuza.', null, QuestionDifficulty.hard),
    _HwProblem('Qiyin: Xonangiz stolining taxminiy yuzini o‘lchab hisoblang.', null, QuestionDifficulty.hard),
  ];

  static const _sequenceProblems = <_HwProblem>[
    _HwProblem('Oson: 1,2,3,4,? Qoida va javob.', r'1,2,3,4,?', QuestionDifficulty.easy),
    _HwProblem('Oson: 5,10,15,20,?', r'5,10,15,20,?', QuestionDifficulty.easy),
    _HwProblem('Oson: 10,8,6,4,?', r'10,8,6,4,?', QuestionDifficulty.easy),
    _HwProblem('Oson: 1,3,5,7,?', r'1,3,5,7,?', QuestionDifficulty.easy),
    _HwProblem('Oson: 2,4,6,8,?', r'2,4,6,8,?', QuestionDifficulty.easy),
    _HwProblem('O‘rta: 2,4,8,16,?', r'2,4,8,16,?', QuestionDifficulty.medium),
    _HwProblem('O‘rta: 3,6,12,24,… keyingi 3 ta had.', r'3,6,12,24', QuestionDifficulty.medium),
    _HwProblem('O‘rta: 1,4,9,16,?', r'1,4,9,16,?', QuestionDifficulty.medium),
    _HwProblem('O‘rta: 81,27,9,3,?', r'81,27,9,3,?', QuestionDifficulty.medium),
    _HwProblem('O‘rta: 7,10,13,16,? Qoidani yozing.', r'7,10,13,16,?', QuestionDifficulty.medium),
    _HwProblem('Qiyin: 1,1,2,3,5,? (Fibonacci). Izoh.', r'1,1,2,3,5,?', QuestionDifficulty.hard),
    _HwProblem('Qiyin: 2,3,5,8,12,?', r'2,3,5,8,12,?', QuestionDifficulty.hard),
    _HwProblem('Qiyin: 100,50,52,26,28,?', r'100,50,52,26,28,?', QuestionDifficulty.hard),
    _HwProblem('Qiyin: Qoida ×2+1: 3,7,15,?', r'3,7,15,?', QuestionDifficulty.hard),
    _HwProblem('Qiyin: O‘zingiz 6 hadli murakkab ketma-ketlik tuzing.', null, QuestionDifficulty.hard),
  ];

  static const _examProblems = <_HwProblem>[
    ..._arithmeticProblems,
  ];
}

class _HwProblem {
  const _HwProblem(this.statement, this.latex, this.difficulty);
  final String statement;
  final String? latex;
  final QuestionDifficulty difficulty;
}
