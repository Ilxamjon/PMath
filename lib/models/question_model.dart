import 'package:equatable/equatable.dart';

/// Savol kategoriyasi (diagnostik + mashqlar).
enum QuestionCategory {
  logic,
  geometry,
  arithmetic,
  logicSequences;

  String get labelUz => switch (this) {
        QuestionCategory.logic => 'Mantiq',
        QuestionCategory.geometry => 'Geometriya',
        QuestionCategory.arithmetic => 'Arifmetika',
        QuestionCategory.logicSequences => 'Mantiqiy ketma-ketlik',
      };
}

/// Savol qiyinlik darajasi.
enum QuestionDifficulty {
  easy,
  medium,
  hard;

  String get labelUz => switch (this) {
        QuestionDifficulty.easy => 'Oson',
        QuestionDifficulty.medium => 'O‘rtacha',
        QuestionDifficulty.hard => 'Qiyin',
      };
}

/// Bitta savol modeli — LaTeX qo‘llab-quvvatlaydi.
class QuestionModel extends Equatable {
  const QuestionModel({
    required this.id,
    required this.prompt,
    required this.category,
    required this.difficulty,
    required this.correctAnswer,
    this.options = const [],
    this.latexFormula,
    this.explanationUz,
    this.imageAsset,
    this.points = 10,
  });

  final String id;

  /// Oddiy matn yoki aralash matn (LaTeX alohida maydonda).
  final String prompt;

  /// Masalan: r'\frac{1}{2} + \frac{1}{4}'
  final String? latexFormula;

  final QuestionCategory category;
  final QuestionDifficulty difficulty;

  /// To‘g‘ri javob (matn yoki indeks string ko‘rinishida).
  final String correctAnswer;

  /// Variantlar (bo‘sh bo‘lsa — ochiq javob).
  final List<String> options;

  /// Sodda o‘zbekcha tushuntirish (xato tahlili uchun).
  final String? explanationUz;

  final String? imageAsset;
  final int points;

  bool get isMultipleChoice => options.isNotEmpty;

  bool checkAnswer(String userAnswer) {
    return userAnswer.trim().toLowerCase() ==
        correctAnswer.trim().toLowerCase();
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'prompt': prompt,
        'latexFormula': latexFormula,
        'category': category.name,
        'difficulty': difficulty.name,
        'correctAnswer': correctAnswer,
        'options': options,
        'explanationUz': explanationUz,
        'imageAsset': imageAsset,
        'points': points,
      };

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['id'] as String,
      prompt: json['prompt'] as String,
      latexFormula: json['latexFormula'] as String?,
      category: QuestionCategory.values.firstWhere(
        (e) => e.name == json['category'],
      ),
      difficulty: QuestionDifficulty.values.firstWhere(
        (e) => e.name == json['difficulty'],
      ),
      correctAnswer: json['correctAnswer'] as String,
      options: (json['options'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      explanationUz: json['explanationUz'] as String?,
      imageAsset: json['imageAsset'] as String?,
      points: json['points'] as int? ?? 10,
    );
  }

  @override
  List<Object?> get props => [
        id,
        prompt,
        latexFormula,
        category,
        difficulty,
        correctAnswer,
        options,
        explanationUz,
        imageAsset,
        points,
      ];
}
