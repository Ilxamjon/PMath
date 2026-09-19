import '../../../models/question_model.dart';

/// 3–4-sinf uchun diagnostik savollar banki (10 ta).
///
/// Taqsimot: Arifmetika 3 · Geometriya 2 · Mantiq 3 · Ketma-ketlik 2
abstract final class DiagnosticQuestionBank {
  static List<QuestionModel> get all => const [
        // —— Arifmetika ——
        QuestionModel(
          id: 'diag_ar_1',
          prompt: 'Hisoblang:',
          latexFormula: r'48 + 37',
          category: QuestionCategory.arithmetic,
          difficulty: QuestionDifficulty.easy,
          correctAnswer: '85',
          options: ['75', '85', '95', '83'],
          explanationUz: '48 + 37 = 85. Birliklarni qo‘shing: 8+7=15, o‘nlikka 1 o‘tadi.',
        ),
        QuestionModel(
          id: 'diag_ar_2',
          prompt: 'Ko‘paytmani toping:',
          latexFormula: r'7 \times 8',
          category: QuestionCategory.arithmetic,
          difficulty: QuestionDifficulty.easy,
          correctAnswer: '56',
          options: ['54', '56', '63', '48'],
          explanationUz: '7×8=56. Ko‘paytirish jadvalini eslang.',
        ),
        QuestionModel(
          id: 'diag_ar_3',
          prompt: 'Kasrlarni qo‘shing:',
          latexFormula: r'\dfrac{1}{2} + \dfrac{1}{4}',
          category: QuestionCategory.arithmetic,
          difficulty: QuestionDifficulty.medium,
          correctAnswer: '3/4',
          options: ['1/4', '2/4', '3/4', '1'],
          explanationUz:
              '1/2 = 2/4. Keyin 2/4 + 1/4 = 3/4.',
        ),

        // —— Geometriya ——
        QuestionModel(
          id: 'diag_ge_1',
          prompt:
              'Kvadratning bir tomoni 5 sm. Uning perimetri necha sm?',
          latexFormula: r'P = 4 \times a',
          category: QuestionCategory.geometry,
          difficulty: QuestionDifficulty.easy,
          correctAnswer: '20',
          options: ['10', '15', '20', '25'],
          explanationUz: 'Kvadratda 4 ta teng tomon: 4×5=20 sm.',
        ),
        QuestionModel(
          id: 'diag_ge_2',
          prompt:
              'Uchburchakning ichki burchaklari yig‘indisi necha gradus?',
          latexFormula: r'\angle A + \angle B + \angle C = ?',
          category: QuestionCategory.geometry,
          difficulty: QuestionDifficulty.medium,
          correctAnswer: '180',
          options: ['90', '180', '270', '360'],
          explanationUz:
              'Har qanday uchburchakda ichki burchaklar yig‘indisi 180°.',
        ),

        // —— Mantiq ——
        QuestionModel(
          id: 'diag_lo_1',
          prompt:
              'Qaysi so‘z qolganlaridan farq qiladi?',
          category: QuestionCategory.logic,
          difficulty: QuestionDifficulty.easy,
          correctAnswer: 'Olma',
          options: ['Doira', 'Kvadrat', 'Olma', 'Uchburchak'],
          explanationUz:
              'Doira, kvadrat, uchburchak — shakllar. Olma — meva.',
        ),
        QuestionModel(
          id: 'diag_lo_2',
          prompt:
              'Agar barcha mushuklar hayvon bo‘lsa va Barsik mushuk bo‘lsa, Barsik nima?',
          category: QuestionCategory.logic,
          difficulty: QuestionDifficulty.medium,
          correctAnswer: 'Hayvon',
          options: ['Odam', 'Hayvon', 'Qush', 'Baliq'],
          explanationUz:
              'Mushuk → hayvon. Barsik mushuk → demak hayvon.',
        ),
        QuestionModel(
          id: 'diag_lo_3',
          prompt:
              'Stolda 3 ta olma bor. 2 tasini oldingiz. Stolda nechta olma qoldi?',
          category: QuestionCategory.logic,
          difficulty: QuestionDifficulty.medium,
          correctAnswer: '1',
          options: ['0', '1', '2', '3'],
          explanationUz: '3 − 2 = 1 olma stolda qoladi.',
        ),

        // —— Mantiqiy ketma-ketlik ——
        QuestionModel(
          id: 'diag_sq_1',
          prompt: 'Ketma-ketlikni davom ettiring:',
          latexFormula: r'2,\ 4,\ 6,\ 8,\ ?',
          category: QuestionCategory.logicSequences,
          difficulty: QuestionDifficulty.easy,
          correctAnswer: '10',
          options: ['9', '10', '12', '14'],
          explanationUz: 'Har safar +2: 8+2=10.',
        ),
        QuestionModel(
          id: 'diag_sq_2',
          prompt: 'Ketma-ketlikni davom ettiring:',
          latexFormula: r'3,\ 6,\ 12,\ 24,\ ?',
          category: QuestionCategory.logicSequences,
          difficulty: QuestionDifficulty.hard,
          correctAnswer: '48',
          options: ['36', '42', '48', '30'],
          explanationUz: 'Har bir son oldingisining 2 barobari: 24×2=48.',
        ),
      ];
}
