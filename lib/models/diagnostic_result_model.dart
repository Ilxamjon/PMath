import 'package:equatable/equatable.dart';

import 'question_model.dart';

/// Bitta savolga berilgan javob.
class DiagnosticAnswer extends Equatable {
  const DiagnosticAnswer({
    required this.questionId,
    required this.selectedAnswer,
    required this.isCorrect,
    required this.category,
  });

  final String questionId;
  final String selectedAnswer;
  final bool isCorrect;
  final QuestionCategory category;

  Map<String, dynamic> toJson() => {
        'questionId': questionId,
        'selectedAnswer': selectedAnswer,
        'isCorrect': isCorrect,
        'category': category.name,
      };

  factory DiagnosticAnswer.fromJson(Map<String, dynamic> json) {
    return DiagnosticAnswer(
      questionId: json['questionId'] as String,
      selectedAnswer: json['selectedAnswer'] as String,
      isCorrect: json['isCorrect'] as bool,
      category: QuestionCategory.values.firstWhere(
        (e) => e.name == json['category'],
      ),
    );
  }

  @override
  List<Object?> get props =>
      [questionId, selectedAnswer, isCorrect, category];
}

/// Diagnostik test yakuniy hisoboti.
class DiagnosticResultModel extends Equatable {
  const DiagnosticResultModel({
    required this.id,
    required this.userId,
    required this.completedAt,
    required this.answers,
    required this.categoryScores,
    required this.overallPercent,
    required this.correctCount,
    required this.totalCount,
    required this.weakCategories,
    required this.strongCategories,
    this.durationSeconds = 0,
  });

  final String id;
  final String userId;
  final DateTime completedAt;
  final List<DiagnosticAnswer> answers;

  /// Kategoriya nomi → foiz (0–100).
  final Map<String, double> categoryScores;
  final double overallPercent;
  final int correctCount;
  final int totalCount;
  final List<String> weakCategories;
  final List<String> strongCategories;
  final int durationSeconds;

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'completedAt': completedAt.toIso8601String(),
        'answers': answers.map((a) => a.toJson()).toList(),
        'categoryScores': categoryScores,
        'overallPercent': overallPercent,
        'correctCount': correctCount,
        'totalCount': totalCount,
        'weakCategories': weakCategories,
        'strongCategories': strongCategories,
        'durationSeconds': durationSeconds,
      };

  factory DiagnosticResultModel.fromJson(Map<String, dynamic> json) {
    final scoresRaw = json['categoryScores'] as Map<String, dynamic>? ?? {};
    return DiagnosticResultModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      completedAt: DateTime.parse(json['completedAt'] as String),
      answers: (json['answers'] as List<dynamic>)
          .map((e) => DiagnosticAnswer.fromJson(e as Map<String, dynamic>))
          .toList(),
      categoryScores: scoresRaw.map(
        (k, v) => MapEntry(k, (v as num).toDouble()),
      ),
      overallPercent: (json['overallPercent'] as num).toDouble(),
      correctCount: json['correctCount'] as int,
      totalCount: json['totalCount'] as int,
      weakCategories: (json['weakCategories'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      strongCategories: (json['strongCategories'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      durationSeconds: json['durationSeconds'] as int? ?? 0,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        completedAt,
        answers,
        categoryScores,
        overallPercent,
        correctCount,
        totalCount,
        weakCategories,
        strongCategories,
        durationSeconds,
      ];
}
