import 'package:uuid/uuid.dart';

import '../../../core/constants/app_constants.dart';
import '../../../models/diagnostic_result_model.dart';
import '../../../models/lesson_model.dart';
import '../../../models/question_model.dart';
import '../../../models/study_plan_bundle.dart';
import '../../../models/study_plan_model.dart';
import '../../lesson/domain/socratic_bank.dart';
import 'curriculum_catalog.dart';

/// AI o‘quv reja generatori abstraksiyasi.
abstract class StudyPlanGenerator {
  Future<StudyPlanBundle> generate({
    required String userId,
    required DiagnosticResultModel diagnostic,
  });
}

/// Lokal rule-based generator — har darsga 10 ta Sokratik savol.
class LocalAiStudyPlanGenerator implements StudyPlanGenerator {
  LocalAiStudyPlanGenerator({Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  final Uuid _uuid;

  @override
  Future<StudyPlanBundle> generate({
    required String userId,
    required DiagnosticResultModel diagnostic,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 900));

    final priority = _buildPriorityQueue(diagnostic);
    final topicCursors = {
      for (final c in QuestionCategory.values) c: 0,
    };

    final weeks = <WeeklyPlan>[];
    final lessons = <LessonModel>[];
    var orderIndex = 0;

    for (var w = 1; w <= AppConstants.studyPlanWeeks; w++) {
      final isExam = w % AppConstants.examEveryNWeeks == 0;

      if (isExam) {
        orderIndex++;
        final examId = 'lesson_w${w}_exam';
        final month = ((w - 1) ~/ 4) + 1;
        final examLesson = LessonModel(
          id: examId,
          titleUz: 'Oy $month mini-imtihon',
          orderIndex: orderIndex,
          topic: 'Imtihon',
          weekNumber: w,
          status: orderIndex == 1
              ? LessonStatus.available
              : LessonStatus.locked,
          coinsReward: 40,
          durationMinutes: 25,
        );
        lessons.add(
          examLesson.copyWith(
            socraticPrompts: SocraticBank.promptsFor(examLesson),
            audioScriptUz: SocraticBank.introFor(examLesson),
          ),
        );
        weeks.add(
          WeeklyPlan(
            weekNumber: w,
            titleUz: 'Hafta $w: Mini-imtihon',
            focusTopics: const ['Imtihon', 'Aralash'],
            lessonIds: [examId],
            isExamWeek: true,
          ),
        );
        continue;
      }

      final weekTopics = <String>[];
      final weekLessonIds = <String>[];

      for (var i = 0; i < AppConstants.lessonsPerWeek; i++) {
        final category = priority[(w + i) % priority.length];
        final catalog = CurriculumCatalog.topicsFor(category);
        final cursor = topicCursors[category]! % catalog.length;
        topicCursors[category] = cursor + 1;
        final topicTitle = catalog[cursor];
        weekTopics.add(category.labelUz);

        orderIndex++;
        final id = 'lesson_w${w}_$i';
        weekLessonIds.add(id);

        final draft = LessonModel(
          id: id,
          titleUz: topicTitle,
          orderIndex: orderIndex,
          topic: category.labelUz,
          weekNumber: w,
          status: orderIndex == 1
              ? LessonStatus.available
              : LessonStatus.locked,
          coinsReward: 15 + (orderIndex % 5) * 5,
          durationMinutes: 15,
        );
        lessons.add(
          draft.copyWith(
            socraticPrompts: SocraticBank.promptsFor(draft),
            audioScriptUz: SocraticBank.introFor(draft),
          ),
        );
      }

      final uniqueFocus = weekTopics.toSet().toList();
      weeks.add(
        WeeklyPlan(
          weekNumber: w,
          titleUz: 'Hafta $w: ${uniqueFocus.join(' + ')}',
          focusTopics: uniqueFocus,
          lessonIds: weekLessonIds,
        ),
      );
    }

    final plan = StudyPlanModel(
      id: _uuid.v4(),
      userId: userId,
      createdAt: DateTime.now(),
      weeks: weeks,
      weakCategories: diagnostic.weakCategories,
      strongCategories: diagnostic.strongCategories,
      currentWeek: 1,
      overallProgress: 0,
    );

    await Future<void>.delayed(const Duration(milliseconds: 600));
    return StudyPlanBundle(plan: plan, lessons: lessons);
  }

  List<QuestionCategory> _buildPriorityQueue(DiagnosticResultModel d) {
    final scores = <QuestionCategory, double>{};
    for (final c in QuestionCategory.values) {
      scores[c] = d.categoryScores[c.labelUz] ?? 50.0;
    }

    final sorted = scores.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));

    final queue = <QuestionCategory>[];
    for (final e in sorted) {
      final weight = e.value < AppConstants.weakCategoryThreshold
          ? 3
          : e.value < AppConstants.strongCategoryThreshold
              ? 2
              : 1;
      for (var i = 0; i < weight; i++) {
        queue.add(e.key);
      }
    }
    return queue.isEmpty ? QuestionCategory.values.toList() : queue;
  }
}
