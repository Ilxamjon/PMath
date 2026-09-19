import 'package:equatable/equatable.dart';

import '../core/utils/mastery_helper.dart';
import 'lesson_model.dart';

/// Haftalik reja bloki (6 oylik AI roadmap ichida).
class WeeklyPlan extends Equatable {
  const WeeklyPlan({
    required this.weekNumber,
    required this.titleUz,
    required this.focusTopics,
    required this.lessonIds,
    this.isExamWeek = false,
    this.completed = false,
  });

  final int weekNumber;
  final String titleUz;
  final List<String> focusTopics;
  final List<String> lessonIds;
  final bool isExamWeek;
  final bool completed;

  Map<String, dynamic> toJson() => {
        'weekNumber': weekNumber,
        'titleUz': titleUz,
        'focusTopics': focusTopics,
        'lessonIds': lessonIds,
        'isExamWeek': isExamWeek,
        'completed': completed,
      };

  factory WeeklyPlan.fromJson(Map<String, dynamic> json) {
    return WeeklyPlan(
      weekNumber: json['weekNumber'] as int,
      titleUz: json['titleUz'] as String,
      focusTopics: (json['focusTopics'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      lessonIds: (json['lessonIds'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      isExamWeek: json['isExamWeek'] as bool? ?? false,
      completed: json['completed'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props =>
      [weekNumber, titleUz, focusTopics, lessonIds, isExamWeek, completed];
}

/// 6 oylik AI shaxsiy o‘quv rejasi.
class StudyPlanModel extends Equatable {
  const StudyPlanModel({
    required this.id,
    required this.userId,
    required this.createdAt,
    required this.weeks,
    this.weakCategories = const [],
    this.strongCategories = const [],
    this.currentWeek = 1,
    this.overallProgress = 0.0,
  });

  final String id;
  final String userId;
  final DateTime createdAt;
  final List<WeeklyPlan> weeks;
  final List<String> weakCategories;
  final List<String> strongCategories;
  final int currentWeek;
  final double overallProgress;

  int get totalWeeks => weeks.length;

  WeeklyPlan? get activeWeek {
    try {
      return weeks.firstWhere((w) => w.weekNumber == currentWeek);
    } catch (_) {
      return weeks.isEmpty ? null : weeks.first;
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'createdAt': createdAt.toIso8601String(),
        'weeks': weeks.map((w) => w.toJson()).toList(),
        'weakCategories': weakCategories,
        'strongCategories': strongCategories,
        'currentWeek': currentWeek,
        'overallProgress': overallProgress,
      };

  factory StudyPlanModel.fromJson(Map<String, dynamic> json) {
    return StudyPlanModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      weeks: (json['weeks'] as List<dynamic>)
          .map((e) => WeeklyPlan.fromJson(e as Map<String, dynamic>))
          .toList(),
      weakCategories: (json['weakCategories'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      strongCategories: (json['strongCategories'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      currentWeek: json['currentWeek'] as int? ?? 1,
      overallProgress: (json['overallProgress'] as num?)?.toDouble() ?? 0.0,
    );
  }

  StudyPlanModel copyWith({
    String? id,
    String? userId,
    DateTime? createdAt,
    List<WeeklyPlan>? weeks,
    List<String>? weakCategories,
    List<String>? strongCategories,
    int? currentWeek,
    double? overallProgress,
  }) {
    return StudyPlanModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      weeks: weeks ?? this.weeks,
      weakCategories: weakCategories ?? this.weakCategories,
      strongCategories: strongCategories ?? this.strongCategories,
      currentWeek: currentWeek ?? this.currentWeek,
      overallProgress: overallProgress ?? this.overallProgress,
    );
  }

  /// Demo 6-haftalik skeleton (keyinchalik AI to‘ldiradi).
  factory StudyPlanModel.demo({required String userId}) {
    final weeks = List.generate(8, (i) {
      final n = i + 1;
      return WeeklyPlan(
        weekNumber: n,
        titleUz: 'Hafta $n: Asosiy mavzular',
        focusTopics: n <= 2
            ? ['Arifmetika', 'Mantiq']
            : n <= 4
                ? ['Geometriya', 'Ketma-ketlik']
                : ['Aralash', 'Imtihon tayyorlash'],
        lessonIds: ['lesson_${n}_1', 'lesson_${n}_2', 'lesson_${n}_3'],
        isExamWeek: n % 4 == 0,
        completed: n < 2,
      );
    });

    return StudyPlanModel(
      id: 'plan-demo-001',
      userId: userId,
      createdAt: DateTime.now(),
      weeks: weeks,
      weakCategories: ['Geometriya', 'Mantiqiy ketma-ketlik'],
      strongCategories: ['Arifmetika'],
      currentWeek: 2,
      overallProgress: 18.0,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        createdAt,
        weeks,
        weakCategories,
        strongCategories,
        currentWeek,
        overallProgress,
      ];
}

/// Roadmap tugmasi holati (Duolingo uslubidagi xarita).
enum RoadmapNodeStatus {
  locked,
  active,
  completed;

  /// Mastery Lock qoidasi bilan hisoblash.
  static RoadmapNodeStatus fromLesson(LessonModel lesson, LessonModel? previous) {
    if (lesson.status == LessonStatus.completed &&
        MasteryHelper.isMastered(lesson.masteryPercent)) {
      return RoadmapNodeStatus.completed;
    }
    if (lesson.status == LessonStatus.locked) {
      return RoadmapNodeStatus.locked;
    }
    if (previous == null ||
        (previous.status == LessonStatus.completed &&
            MasteryHelper.isMastered(previous.masteryPercent))) {
      return RoadmapNodeStatus.active;
    }
    return RoadmapNodeStatus.locked;
  }
}
