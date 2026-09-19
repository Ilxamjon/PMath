import 'package:equatable/equatable.dart';

import 'question_model.dart';

/// Liga darajasi (imtihon natijasidan).
enum LeagueTier {
  bronze,
  silver,
  gold,
  diamond;

  String get labelUz => switch (this) {
        LeagueTier.bronze => 'Bronza liga',
        LeagueTier.silver => 'Kumush liga',
        LeagueTier.gold => 'Oltin liga',
        LeagueTier.diamond => 'Olmos liga',
      };

  String get emoji => switch (this) {
        LeagueTier.bronze => '🥉',
        LeagueTier.silver => '🥈',
        LeagueTier.gold => '🥇',
        LeagueTier.diamond => '💎',
      };
}

/// Mini-imtihon yakuni + ranking.
class ExamResultModel extends Equatable {
  const ExamResultModel({
    required this.id,
    required this.userId,
    required this.lessonId,
    required this.weekNumber,
    required this.titleUz,
    required this.completedAt,
    required this.overallPercent,
    required this.correctCount,
    required this.totalQuestions,
    required this.durationSeconds,
    required this.categoryScores,
    required this.league,
    required this.estimatedRank,
    required this.peerPool,
    this.coinsEarned = 0,
    this.timeUp = false,
  });

  final String id;
  final String userId;
  final String lessonId;
  final int weekNumber;
  final String titleUz;
  final DateTime completedAt;
  final double overallPercent;
  final int correctCount;
  final int totalQuestions;
  final int durationSeconds;
  final Map<QuestionCategory, double> categoryScores;
  final LeagueTier league;
  final int estimatedRank;
  final int peerPool;
  final int coinsEarned;
  final bool timeUp;

  bool get isPassed => overallPercent >= 80.0;

  String get rankLabelUz =>
      '$estimatedRank / $peerPool · ${league.emoji} ${league.labelUz}';

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'lessonId': lessonId,
        'weekNumber': weekNumber,
        'titleUz': titleUz,
        'completedAt': completedAt.toIso8601String(),
        'overallPercent': overallPercent,
        'correctCount': correctCount,
        'totalQuestions': totalQuestions,
        'durationSeconds': durationSeconds,
        'categoryScores': {
          for (final e in categoryScores.entries) e.key.name: e.value,
        },
        'league': league.name,
        'estimatedRank': estimatedRank,
        'peerPool': peerPool,
        'coinsEarned': coinsEarned,
        'timeUp': timeUp,
      };

  factory ExamResultModel.fromJson(Map<String, dynamic> json) {
    final rawCats = json['categoryScores'] as Map<String, dynamic>? ?? {};
    final cats = <QuestionCategory, double>{};
    for (final e in rawCats.entries) {
      final cat = QuestionCategory.values.firstWhere(
        (c) => c.name == e.key,
        orElse: () => QuestionCategory.arithmetic,
      );
      cats[cat] = (e.value as num).toDouble();
    }

    return ExamResultModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      lessonId: json['lessonId'] as String,
      weekNumber: json['weekNumber'] as int? ?? 0,
      titleUz: json['titleUz'] as String? ?? 'Imtihon',
      completedAt: DateTime.parse(json['completedAt'] as String),
      overallPercent: (json['overallPercent'] as num).toDouble(),
      correctCount: json['correctCount'] as int? ?? 0,
      totalQuestions: json['totalQuestions'] as int? ?? 0,
      durationSeconds: json['durationSeconds'] as int? ?? 0,
      categoryScores: cats,
      league: LeagueTier.values.firstWhere(
        (e) => e.name == json['league'],
        orElse: () => LeagueTier.bronze,
      ),
      estimatedRank: json['estimatedRank'] as int? ?? 1,
      peerPool: json['peerPool'] as int? ?? 100,
      coinsEarned: json['coinsEarned'] as int? ?? 0,
      timeUp: json['timeUp'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        lessonId,
        weekNumber,
        titleUz,
        completedAt,
        overallPercent,
        correctCount,
        totalQuestions,
        durationSeconds,
        categoryScores,
        league,
        estimatedRank,
        peerPool,
        coinsEarned,
        timeUp,
      ];
}
