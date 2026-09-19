import 'dart:math';

import '../../../core/constants/app_constants.dart';
import '../../../models/lesson_model.dart';
import '../../../models/question_model.dart';

/// Dars mavzusiga mos 15 ta mashq: 5 oson + 5 o‘rtacha + 5 qiyin.
abstract final class PracticeQuestionFactory {
  static List<QuestionModel> forLesson(
    LessonModel lesson, {
    Random? random,
  }) {
    final rng = random ?? Random(lesson.id.hashCode ^ DateTime.now().day);
    final pool = _poolFor(lesson);

    List<QuestionModel> pick(QuestionDifficulty d, int n) {
      final items = pool.where((q) => q.difficulty == d).toList()..shuffle(rng);
      if (items.length >= n) return items.take(n).toList();
      // Zaxira: boshqa darajadan to‘ldirish.
      final extra = pool.where((q) => q.difficulty != d).toList()..shuffle(rng);
      return [...items, ...extra].take(n).toList();
    }

    final result = [
      ...pick(QuestionDifficulty.easy, AppConstants.practiceEasyCount),
      ...pick(QuestionDifficulty.medium, AppConstants.practiceMediumCount),
      ...pick(QuestionDifficulty.hard, AppConstants.practiceHardCount),
    ];
    // Daraja tartibida: oson → o‘rta → qiyin (shuffle ichida emas).
    return result;
  }

  static List<QuestionModel> _poolFor(LessonModel lesson) {
    final topic = '${lesson.topic} ${lesson.titleUz}'.toLowerCase();

    if (topic.contains('imtihon')) {
      return [..._arithmetic, ..._geometry, ..._logic, ..._sequences];
    }
    if (topic.contains('taqqos') ||
        topic.contains('mantiq') ||
        topic.contains('topishmoq') ||
        topic.contains('ortiqcha') ||
        topic.contains('jadval')) {
      return _logic;
    }
    if (topic.contains('ketma') || topic.contains('naqsh')) {
      return _sequences;
    }
    if (topic.contains('geometr') ||
        topic.contains('perimetr') ||
        topic.contains('burchak') ||
        topic.contains('shakl') ||
        topic.contains('yuza') ||
        topic.contains('kvadrat') ||
        topic.contains('simmetr')) {
      return _geometry;
    }
    return _arithmetic;
  }

  // —— 15 arifmetika ——
  static const _arithmetic = [
    QuestionModel(
      id: 'pr_ar_e1',
      prompt: 'Hisoblang:',
      latexFormula: r'15 + 27',
      category: QuestionCategory.arithmetic,
      difficulty: QuestionDifficulty.easy,
      correctAnswer: '42',
      options: ['41', '42', '43', '52'],
      explanationUz: '15+27=42',
    ),
    QuestionModel(
      id: 'pr_ar_e2',
      prompt: 'Hisoblang:',
      latexFormula: r'9 \times 6',
      category: QuestionCategory.arithmetic,
      difficulty: QuestionDifficulty.easy,
      correctAnswer: '54',
      options: ['45', '54', '56', '63'],
    ),
    QuestionModel(
      id: 'pr_ar_e3',
      prompt: 'Hisoblang:',
      latexFormula: r'100 - 37',
      category: QuestionCategory.arithmetic,
      difficulty: QuestionDifficulty.easy,
      correctAnswer: '63',
      options: ['73', '63', '67', '53'],
    ),
    QuestionModel(
      id: 'pr_ar_e4',
      prompt: 'Hisoblang:',
      latexFormula: r'8 \times 7',
      category: QuestionCategory.arithmetic,
      difficulty: QuestionDifficulty.easy,
      correctAnswer: '56',
      options: ['54', '56', '64', '49'],
    ),
    QuestionModel(
      id: 'pr_ar_e5',
      prompt: 'Hisoblang:',
      latexFormula: r'45 + 19',
      category: QuestionCategory.arithmetic,
      difficulty: QuestionDifficulty.easy,
      correctAnswer: '64',
      options: ['54', '64', '74', '63'],
    ),
    QuestionModel(
      id: 'pr_ar_m1',
      prompt: 'Kasrni soddalashtiring:',
      latexFormula: r'\dfrac{2}{4}',
      category: QuestionCategory.arithmetic,
      difficulty: QuestionDifficulty.medium,
      correctAnswer: '1/2',
      options: ['1/4', '1/2', '2/2', '3/4'],
    ),
    QuestionModel(
      id: 'pr_ar_m2',
      prompt: 'Hisoblang:',
      latexFormula: r'12 \times 11',
      category: QuestionCategory.arithmetic,
      difficulty: QuestionDifficulty.medium,
      correctAnswer: '132',
      options: ['121', '132', '122', '144'],
    ),
    QuestionModel(
      id: 'pr_ar_m3',
      prompt: 'Hisoblang:',
      latexFormula: r'144 \div 12',
      category: QuestionCategory.arithmetic,
      difficulty: QuestionDifficulty.medium,
      correctAnswer: '12',
      options: ['10', '11', '12', '14'],
    ),
    QuestionModel(
      id: 'pr_ar_m4',
      prompt: 'Qaysi biri 3/4 ga teng?',
      category: QuestionCategory.arithmetic,
      difficulty: QuestionDifficulty.medium,
      correctAnswer: '6/8',
      options: ['2/4', '6/8', '3/8', '4/3'],
    ),
    QuestionModel(
      id: 'pr_ar_m5',
      prompt: 'Hisoblang:',
      latexFormula: r'25 \times 4 + 10',
      category: QuestionCategory.arithmetic,
      difficulty: QuestionDifficulty.medium,
      correctAnswer: '110',
      options: ['100', '110', '90', '140'],
    ),
    QuestionModel(
      id: 'pr_ar_h1',
      prompt: 'Hisoblang:',
      latexFormula: r'48 \times 15',
      category: QuestionCategory.arithmetic,
      difficulty: QuestionDifficulty.hard,
      correctAnswer: '720',
      options: ['700', '720', '680', '760'],
    ),
    QuestionModel(
      id: 'pr_ar_h2',
      prompt: 'Sonning 20 foizi 16. Son qancha?',
      category: QuestionCategory.arithmetic,
      difficulty: QuestionDifficulty.hard,
      correctAnswer: '80',
      options: ['32', '64', '80', '96'],
    ),
    QuestionModel(
      id: 'pr_ar_h3',
      prompt: 'Hisoblang:',
      latexFormula: r'(36 + 14) \times 3 - 20',
      category: QuestionCategory.arithmetic,
      difficulty: QuestionDifficulty.hard,
      correctAnswer: '130',
      options: ['120', '130', '140', '150'],
    ),
    QuestionModel(
      id: 'pr_ar_h4',
      prompt: '1/2 + 1/3 = ?',
      latexFormula: r'\dfrac{1}{2}+\dfrac{1}{3}',
      category: QuestionCategory.arithmetic,
      difficulty: QuestionDifficulty.hard,
      correctAnswer: '5/6',
      options: ['2/5', '1/5', '5/6', '3/6'],
    ),
    QuestionModel(
      id: 'pr_ar_h5',
      prompt: 'Kitob 240 so‘m. 15% chegirma. Yangi narx?',
      category: QuestionCategory.arithmetic,
      difficulty: QuestionDifficulty.hard,
      correctAnswer: '204',
      options: ['200', '204', '210', '225'],
    ),
  ];

  // —— 15 geometriya ——
  static const _geometry = [
    QuestionModel(
      id: 'pr_ge_e1',
      prompt: 'Kvadrat tomoni 6 sm. Perimetri?',
      latexFormula: r'P = 4 \times 6',
      category: QuestionCategory.geometry,
      difficulty: QuestionDifficulty.easy,
      correctAnswer: '24',
      options: ['12', '18', '24', '36'],
    ),
    QuestionModel(
      id: 'pr_ge_e2',
      prompt: 'To‘g‘ri burchak necha gradus?',
      category: QuestionCategory.geometry,
      difficulty: QuestionDifficulty.easy,
      correctAnswer: '90',
      options: ['45', '60', '90', '180'],
    ),
    QuestionModel(
      id: 'pr_ge_e3',
      prompt: 'Kvadratning nechta tomoni teng?',
      category: QuestionCategory.geometry,
      difficulty: QuestionDifficulty.easy,
      correctAnswer: '4',
      options: ['2', '3', '4', '5'],
    ),
    QuestionModel(
      id: 'pr_ge_e4',
      prompt: 'Uchburchakning nechta burchagi bor?',
      category: QuestionCategory.geometry,
      difficulty: QuestionDifficulty.easy,
      correctAnswer: '3',
      options: ['2', '3', '4', '5'],
    ),
    QuestionModel(
      id: 'pr_ge_e5',
      prompt: 'Doira nechta uchga ega?',
      category: QuestionCategory.geometry,
      difficulty: QuestionDifficulty.easy,
      correctAnswer: '0',
      options: ['0', '1', '2', '4'],
    ),
    QuestionModel(
      id: 'pr_ge_m1',
      prompt: 'Uchburchak burchaklari yig‘indisi?',
      category: QuestionCategory.geometry,
      difficulty: QuestionDifficulty.medium,
      correctAnswer: '180',
      options: ['90', '180', '270', '360'],
    ),
    QuestionModel(
      id: 'pr_ge_m2',
      prompt: 'To‘g‘ri to‘rtburchak: a=5, b=3. Yuza?',
      latexFormula: r'S = a \times b',
      category: QuestionCategory.geometry,
      difficulty: QuestionDifficulty.medium,
      correctAnswer: '15',
      options: ['8', '15', '16', '30'],
    ),
    QuestionModel(
      id: 'pr_ge_m3',
      prompt: 'Kvadrat tomoni 9. Yuza?',
      latexFormula: r'S = 9 \times 9',
      category: QuestionCategory.geometry,
      difficulty: QuestionDifficulty.medium,
      correctAnswer: '81',
      options: ['36', '72', '81', '90'],
    ),
    QuestionModel(
      id: 'pr_ge_m4',
      prompt: 'To‘g‘ri to‘rtburchak perimetri: a=7, b=4?',
      category: QuestionCategory.geometry,
      difficulty: QuestionDifficulty.medium,
      correctAnswer: '22',
      options: ['11', '28', '22', '18'],
    ),
    QuestionModel(
      id: 'pr_ge_m5',
      prompt: 'O‘tkir burchak qaysi oraliqda?',
      category: QuestionCategory.geometry,
      difficulty: QuestionDifficulty.medium,
      correctAnswer: '0°–90°',
      options: ['0°–90°', '90°', '90°–180°', '180°'],
    ),
    QuestionModel(
      id: 'pr_ge_h1',
      prompt: 'Uchburchak: 40° va 65°. Uchinchi burchak?',
      category: QuestionCategory.geometry,
      difficulty: QuestionDifficulty.hard,
      correctAnswer: '75',
      options: ['65', '75', '85', '105'],
    ),
    QuestionModel(
      id: 'pr_ge_h2',
      prompt: 'Kvadrat perimetri 36. Tomoni? Yuza?',
      category: QuestionCategory.geometry,
      difficulty: QuestionDifficulty.hard,
      correctAnswer: '9 va 81',
      options: ['6 va 36', '9 va 81', '12 va 36', '8 va 64'],
    ),
    QuestionModel(
      id: 'pr_ge_h3',
      prompt: 'To‘g‘ri to‘rtburchak yuza 48, a=8. b=?',
      category: QuestionCategory.geometry,
      difficulty: QuestionDifficulty.hard,
      correctAnswer: '6',
      options: ['4', '6', '8', '12'],
    ),
    QuestionModel(
      id: 'pr_ge_h4',
      prompt: 'Simmetriya o‘qi eng ko‘p qaysi shaklda?',
      category: QuestionCategory.geometry,
      difficulty: QuestionDifficulty.hard,
      correctAnswer: 'Doira',
      options: ['Uchburchak', 'Kvadrat', 'Doira', 'Trapetsiya'],
    ),
    QuestionModel(
      id: 'pr_ge_h5',
      prompt: 'L-shakl: katta 6×4, kichik teshik 2×2. Yuza?',
      category: QuestionCategory.geometry,
      difficulty: QuestionDifficulty.hard,
      correctAnswer: '20',
      options: ['24', '20', '16', '28'],
      explanationUz: '6×4=24, 2×2=4, 24-4=20',
    ),
  ];

  // —— 15 mantiq / taqqoslash ——
  static const _logic = [
    QuestionModel(
      id: 'pr_lo_e1',
      prompt: '3 olma va 5 nok. Qaysi meva ko‘proq?',
      category: QuestionCategory.logic,
      difficulty: QuestionDifficulty.easy,
      correctAnswer: 'Nok',
      options: ['Olma', 'Nok', 'Teng', 'Noma’lum'],
    ),
    QuestionModel(
      id: 'pr_lo_e2',
      prompt: 'Qaysi biri shakl emas?',
      category: QuestionCategory.logic,
      difficulty: QuestionDifficulty.easy,
      correctAnswer: 'Olma',
      options: ['Doira', 'Olma', 'Kvadrat', 'Uchburchak'],
    ),
    QuestionModel(
      id: 'pr_lo_e3',
      prompt: 'Eng katta son?',
      category: QuestionCategory.logic,
      difficulty: QuestionDifficulty.easy,
      correctAnswer: '99',
      options: ['19', '91', '99', '90'],
    ),
    QuestionModel(
      id: 'pr_lo_e4',
      prompt: '120 sm va 1 m. Kim uzunroq chiziq?',
      category: QuestionCategory.logic,
      difficulty: QuestionDifficulty.easy,
      correctAnswer: '120 sm',
      options: ['120 sm', '1 m', 'Teng', 'Noma’lum'],
    ),
    QuestionModel(
      id: 'pr_lo_e5',
      prompt: 'Stolda 5 qalam. 2 tasini oldingiz. Nechta qoldi?',
      category: QuestionCategory.logic,
      difficulty: QuestionDifficulty.easy,
      correctAnswer: '3',
      options: ['2', '3', '5', '7'],
    ),
    QuestionModel(
      id: 'pr_lo_m1',
      prompt: '2 kg va 1500 g. Qaysi og‘irroq?',
      category: QuestionCategory.logic,
      difficulty: QuestionDifficulty.medium,
      correctAnswer: '2 kg',
      options: ['2 kg', '1500 g', 'Teng', 'Noma’lum'],
    ),
    QuestionModel(
      id: 'pr_lo_m2',
      prompt: 'A > B, B > C. A va C?',
      category: QuestionCategory.logic,
      difficulty: QuestionDifficulty.medium,
      correctAnswer: 'A > C',
      options: ['A < C', 'A = C', 'A > C', 'Noma’lum'],
    ),
    QuestionModel(
      id: 'pr_lo_m3',
      prompt: '8 sm va 1 dm. Qaysi uzunroq?',
      category: QuestionCategory.logic,
      difficulty: QuestionDifficulty.medium,
      correctAnswer: '1 dm',
      options: ['8 sm', '1 dm', 'Teng', 'Noma’lum'],
    ),
    QuestionModel(
      id: 'pr_lo_m4',
      prompt: 'Ortiqchasini toping: mushuk, it, qush, stol',
      category: QuestionCategory.logic,
      difficulty: QuestionDifficulty.medium,
      correctAnswer: 'Stol',
      options: ['Mushuk', 'It', 'Qush', 'Stol'],
    ),
    QuestionModel(
      id: 'pr_lo_m5',
      prompt: 'Ballar: 12, 18, 15. Eng yuqori?',
      category: QuestionCategory.logic,
      difficulty: QuestionDifficulty.medium,
      correctAnswer: '18',
      options: ['12', '15', '18', '45'],
    ),
    QuestionModel(
      id: 'pr_lo_h1',
      prompt: 'Ali 3 yoshga katta Bekdan. Bek 9. Ali nechida?',
      category: QuestionCategory.logic,
      difficulty: QuestionDifficulty.hard,
      correctAnswer: '12',
      options: ['6', '9', '12', '15'],
    ),
    QuestionModel(
      id: 'pr_lo_h2',
      prompt: 'Quti A: 4 kitob (har biri 200 g). Quti B: 900 g. Qaysi og‘ir?',
      category: QuestionCategory.logic,
      difficulty: QuestionDifficulty.hard,
      correctAnswer: 'A',
      options: ['A', 'B', 'Teng', 'Noma’lum'],
    ),
    QuestionModel(
      id: 'pr_lo_h3',
      prompt: '14:00 va tushdan keyin 2:00 — bir xilmi?',
      category: QuestionCategory.logic,
      difficulty: QuestionDifficulty.hard,
      correctAnswer: 'Ha',
      options: ['Ha', 'Yo‘q', 'Faqat yozda', 'Noma’lum'],
    ),
    QuestionModel(
      id: 'pr_lo_h4',
      prompt: '3 ta o‘quvchi: 70, 85, 85. Nechtasi eng yuqori ballga ega?',
      category: QuestionCategory.logic,
      difficulty: QuestionDifficulty.hard,
      correctAnswer: '2',
      options: ['1', '2', '3', '0'],
    ),
    QuestionModel(
      id: 'pr_lo_h5',
      prompt: 'Agar har kuni 2 sm o‘ssa, 5 kunda necha sm?',
      category: QuestionCategory.logic,
      difficulty: QuestionDifficulty.hard,
      correctAnswer: '10',
      options: ['5', '7', '10', '12'],
    ),
  ];

  // —— 15 ketma-ketlik ——
  static const _sequences = [
    QuestionModel(
      id: 'pr_sq_e1',
      prompt: 'Davom ettiring:',
      latexFormula: r'1,\ 2,\ 3,\ 4,\ ?',
      category: QuestionCategory.logicSequences,
      difficulty: QuestionDifficulty.easy,
      correctAnswer: '5',
      options: ['4', '5', '6', '7'],
    ),
    QuestionModel(
      id: 'pr_sq_e2',
      prompt: 'Davom ettiring:',
      latexFormula: r'5,\ 10,\ 15,\ 20,\ ?',
      category: QuestionCategory.logicSequences,
      difficulty: QuestionDifficulty.easy,
      correctAnswer: '25',
      options: ['22', '25', '30', '35'],
    ),
    QuestionModel(
      id: 'pr_sq_e3',
      prompt: 'Davom ettiring:',
      latexFormula: r'10,\ 8,\ 6,\ 4,\ ?',
      category: QuestionCategory.logicSequences,
      difficulty: QuestionDifficulty.easy,
      correctAnswer: '2',
      options: ['0', '1', '2', '3'],
    ),
    QuestionModel(
      id: 'pr_sq_e4',
      prompt: 'Davom ettiring:',
      latexFormula: r'1,\ 3,\ 5,\ 7,\ ?',
      category: QuestionCategory.logicSequences,
      difficulty: QuestionDifficulty.easy,
      correctAnswer: '9',
      options: ['8', '9', '10', '11'],
    ),
    QuestionModel(
      id: 'pr_sq_e5',
      prompt: 'Davom ettiring:',
      latexFormula: r'2,\ 4,\ 6,\ 8,\ ?',
      category: QuestionCategory.logicSequences,
      difficulty: QuestionDifficulty.easy,
      correctAnswer: '10',
      options: ['9', '10', '12', '14'],
    ),
    QuestionModel(
      id: 'pr_sq_m1',
      prompt: 'Davom ettiring:',
      latexFormula: r'2,\ 4,\ 8,\ 16,\ ?',
      category: QuestionCategory.logicSequences,
      difficulty: QuestionDifficulty.medium,
      correctAnswer: '32',
      options: ['24', '30', '32', '18'],
    ),
    QuestionModel(
      id: 'pr_sq_m2',
      prompt: 'Davom ettiring:',
      latexFormula: r'3,\ 6,\ 12,\ 24,\ ?',
      category: QuestionCategory.logicSequences,
      difficulty: QuestionDifficulty.medium,
      correctAnswer: '48',
      options: ['36', '42', '48', '30'],
    ),
    QuestionModel(
      id: 'pr_sq_m3',
      prompt: 'Davom ettiring:',
      latexFormula: r'1,\ 4,\ 9,\ 16,\ ?',
      category: QuestionCategory.logicSequences,
      difficulty: QuestionDifficulty.medium,
      correctAnswer: '25',
      options: ['20', '24', '25', '36'],
    ),
    QuestionModel(
      id: 'pr_sq_m4',
      prompt: 'Davom ettiring:',
      latexFormula: r'81,\ 27,\ 9,\ 3,\ ?',
      category: QuestionCategory.logicSequences,
      difficulty: QuestionDifficulty.medium,
      correctAnswer: '1',
      options: ['0', '1', '2', '6'],
    ),
    QuestionModel(
      id: 'pr_sq_m5',
      prompt: 'Davom ettiring:',
      latexFormula: r'7,\ 10,\ 13,\ 16,\ ?',
      category: QuestionCategory.logicSequences,
      difficulty: QuestionDifficulty.medium,
      correctAnswer: '19',
      options: ['17', '18', '19', '20'],
    ),
    QuestionModel(
      id: 'pr_sq_h1',
      prompt: 'Davom ettiring:',
      latexFormula: r'1,\ 1,\ 2,\ 3,\ 5,\ ?',
      category: QuestionCategory.logicSequences,
      difficulty: QuestionDifficulty.hard,
      correctAnswer: '8',
      options: ['6', '7', '8', '9'],
      explanationUz: 'Fibonacci: har biri oldingi ikkisining yig‘indisi',
    ),
    QuestionModel(
      id: 'pr_sq_h2',
      prompt: 'Davom ettiring:',
      latexFormula: r'2,\ 3,\ 5,\ 8,\ 12,\ ?',
      category: QuestionCategory.logicSequences,
      difficulty: QuestionDifficulty.hard,
      correctAnswer: '17',
      options: ['15', '16', '17', '18'],
      explanationUz: '+1,+2,+3,+4,+5',
    ),
    QuestionModel(
      id: 'pr_sq_h3',
      prompt: 'Davom ettiring:',
      latexFormula: r'100,\ 50,\ 52,\ 26,\ 28,\ ?',
      category: QuestionCategory.logicSequences,
      difficulty: QuestionDifficulty.hard,
      correctAnswer: '14',
      options: ['12', '14', '16', '30'],
    ),
    QuestionModel(
      id: 'pr_sq_h4',
      prompt: 'Qoida: har safar ×2 +1. 3 dan keyin:',
      latexFormula: r'3,\ 7,\ 15,\ ?',
      category: QuestionCategory.logicSequences,
      difficulty: QuestionDifficulty.hard,
      correctAnswer: '31',
      options: ['29', '30', '31', '32'],
    ),
    QuestionModel(
      id: 'pr_sq_h5',
      prompt: 'Juft o‘rinlar 2 ga, toq o‘rinlar 3 ga ortadi: 1,3,5,8,?,13',
      category: QuestionCategory.logicSequences,
      difficulty: QuestionDifficulty.hard,
      correctAnswer: '10',
      options: ['9', '10', '11', '12'],
    ),
  ];
}
