import 'package:equatable/equatable.dart';

import 'lesson_model.dart';
import 'study_plan_model.dart';

/// Generatsiya qilingan reja + darslar to‘plami.
class StudyPlanBundle extends Equatable {
  const StudyPlanBundle({
    required this.plan,
    required this.lessons,
  });

  final StudyPlanModel plan;
  final List<LessonModel> lessons;

  List<LessonModel> lessonsForWeek(int weekNumber) =>
      lessons.where((l) => l.weekNumber == weekNumber).toList();

  Map<String, dynamic> toJson() => {
        'plan': plan.toJson(),
        'lessons': lessons.map((l) => l.toJson()).toList(),
      };

  factory StudyPlanBundle.fromJson(Map<String, dynamic> json) {
    return StudyPlanBundle(
      plan: StudyPlanModel.fromJson(json['plan'] as Map<String, dynamic>),
      lessons: (json['lessons'] as List<dynamic>)
          .map((e) => LessonModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [plan, lessons];
}
