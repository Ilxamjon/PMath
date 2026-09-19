import '../../../models/question_model.dart';

/// Mavzu katalogi — AI generator shu bazadan dars tanlaydi.
abstract final class CurriculumCatalog {
  static const Map<QuestionCategory, List<String>> topicsByCategory = {
    QuestionCategory.arithmetic: [
      'Natural sonlar',
      'Qo‘shish va ayirish',
      'Ko‘paytirish jadvali',
      'Bo‘lish',
      'Kasrlar asoslari',
      'Aralash hisob',
      'O‘nlik kasrlar',
      'Foizga kirish',
    ],
    QuestionCategory.geometry: [
      'Shakllarni tanish',
      'Burchaklar',
      'Perimetr',
      'To‘g‘ri to‘rtburchak yuza',
      'Kvadrat xossalari',
      'Uchburchak turlari',
      'Simmetriya',
      'Hajmga kirish',
    ],
    QuestionCategory.logic: [
      'Mantiqiy topishmoqlar',
      'Taqqoslash',
      'Ortiqcha narsani topish',
      'Shartli xulosa',
      'Jadvallar bilan mantiq',
      'Yo‘nalish va joylashuv',
      'Kodlash o‘yinlari',
      'Muammo yechish strategiyasi',
    ],
    QuestionCategory.logicSequences: [
      'Juft-toq ketma-ketlik',
      'Qo‘shish ketma-ketligi',
      'Ko‘paytirish ketma-ketligi',
      'Naqshlar',
      'Raqam piramidasi',
      'Figurali ketma-ketlik',
      'Murakkab qoida',
      'Imtihon tipidagi ketma-ketlik',
    ],
  };

  static QuestionCategory? categoryFromLabel(String labelUz) {
    for (final c in QuestionCategory.values) {
      if (c.labelUz == labelUz) return c;
    }
    // Qisqa nomlar / sinonimlar.
    if (labelUz.contains('Arifmetik')) return QuestionCategory.arithmetic;
    if (labelUz.contains('Geometr')) return QuestionCategory.geometry;
    if (labelUz.contains('ketma-ketlik') || labelUz.contains('Ketma')) {
      return QuestionCategory.logicSequences;
    }
    if (labelUz.contains('Mantiq')) return QuestionCategory.logic;
    return null;
  }

  static List<String> topicsFor(QuestionCategory category) =>
      List<String>.from(topicsByCategory[category] ?? const []);
}
