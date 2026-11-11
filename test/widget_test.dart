import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:math';

import 'package:pmath/core/constants/app_constants.dart';
import 'package:pmath/core/utils/mastery_helper.dart';
import 'package:pmath/features/diagnostic/data/diagnostic_question_bank.dart';
import 'package:pmath/features/diagnostic/data/diagnostic_repository.dart';
import 'package:pmath/features/diagnostic/domain/diagnostic_scorer.dart';
import 'package:pmath/features/error_analysis/domain/error_analysis_coach.dart';
import 'package:pmath/features/exam/data/exam_question_bank.dart';
import 'package:pmath/features/exam/domain/exam_scorer.dart';
import 'package:pmath/features/grading/domain/ai_grading_service.dart';
import 'package:pmath/features/homework/data/homework_service.dart';
import 'package:pmath/features/homework/domain/homework_assigner.dart';
import 'package:pmath/features/lesson/domain/lesson_script.dart';
import 'package:pmath/features/practice/domain/practice_question_factory.dart';
import 'package:pmath/features/proctoring/domain/proctoring_guard.dart';
import 'package:pmath/features/study_plan/data/study_plan_repository.dart';
import 'package:pmath/features/study_plan/domain/ai_study_plan_generator.dart';
import 'package:pmath/main.dart';
import 'package:pmath/models/diagnostic_result_model.dart';
import 'package:pmath/models/exam_result_model.dart';
import 'package:pmath/models/homework_model.dart';
import 'package:pmath/models/lesson_model.dart';
import 'package:pmath/models/question_model.dart';
import 'package:pmath/models/parent_alert_log.dart';
import 'package:pmath/models/user_model.dart';
import 'package:pmath/features/gamification/domain/avatar_catalog.dart';
import 'package:pmath/features/lesson/domain/socratic_bank.dart';
import 'package:pmath/features/lesson/presentation/cubit/lesson_cubit.dart';
import 'package:pmath/features/voice_ai/domain/voice_ai_coach.dart';
import 'package:pmath/services/ai_tutor_service.dart';
import 'package:pmath/services/auth_service.dart';
import 'package:pmath/services/gamification_service.dart';
import 'package:pmath/services/parent_alert_service.dart';
import 'package:pmath/services/storage_service.dart';
import 'package:pmath/services/streak_monitor.dart';
import 'package:pmath/services/stt_service.dart';
import 'package:pmath/services/tts_service.dart';
import 'package:pmath/services/vision_ai_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<List<RepositoryProvider<dynamic>>> providers() async {
    final storage = await StorageService.init();
    final alerts = StubParentAlertService();
    return [
      RepositoryProvider<StorageService>.value(value: storage),
      RepositoryProvider<AuthService>.value(value: StubAuthService()),
      RepositoryProvider<DiagnosticRepository>.value(
        value: LocalDiagnosticRepository(storage),
      ),
      RepositoryProvider<StudyPlanRepository>.value(
        value: LocalStudyPlanRepository(
          storage: storage,
          generator: LocalAiStudyPlanGenerator(),
        ),
      ),
      RepositoryProvider<TtsService>.value(value: StubTtsService()),
      RepositoryProvider<SttService>.value(value: StubSttService()),
      RepositoryProvider<ProctoringGuard>.value(value: StubProctoringGuard()),
      RepositoryProvider<ParentAlertService>.value(value: alerts),
      RepositoryProvider<AiTutorService>.value(value: AiTutorService()),
      RepositoryProvider<HomeworkService>.value(
        value: HomeworkService(storage: storage, alerts: alerts),
      ),
      RepositoryProvider<VisionAiService>.value(value: StubVisionAiService()),
      RepositoryProvider<AiGradingService>.value(
        value: LocalAiGradingService(),
      ),
    ];
  }

  testWidgets('Onboarding welcome ekrani ochiladi', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final repos = await providers();

    await tester.pumpWidget(
      MultiRepositoryProvider(
        providers: repos,
        child: const PMathApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('PMath'), findsWidgets);
    expect(find.text('Boshlash'), findsOneWidget);
  });

  test('Diagnostik scorer kategoriya foizlarini hisoblaydi', () {
    final questions = DiagnosticQuestionBank.all;
    final answers = <String, String>{
      for (final q in questions) q.id: q.correctAnswer,
    };

    final result = DiagnosticScorer.buildResult(
      id: 'test',
      userId: 'u1',
      questions: questions,
      selectedAnswers: answers,
      durationSeconds: 120,
    );

    expect(result.correctCount, 10);
    expect(result.overallPercent, 100);
    expect(result.strongCategories.length, greaterThan(0));
    expect(result.weakCategories, isEmpty);
  });

  test('Savollar banki 10 ta va 4 kategoriya', () {
    final all = DiagnosticQuestionBank.all;
    expect(all.length, 10);
    final cats = all.map((q) => q.category).toSet();
    expect(cats.length, 4);
  });

  test('AI study plan 24 hafta va zaif mavzuni ustuvorlashtiradi', () async {
    final diagnostic = DiagnosticResultModel(
      id: 'd1',
      userId: 'u1',
      completedAt: DateTime.now(),
      answers: const [],
      categoryScores: {
        QuestionCategory.geometry.labelUz: 30,
        QuestionCategory.arithmetic.labelUz: 90,
        QuestionCategory.logic.labelUz: 70,
        QuestionCategory.logicSequences.labelUz: 50,
      },
      overallPercent: 60,
      correctCount: 6,
      totalCount: 10,
      weakCategories: [QuestionCategory.geometry.labelUz],
      strongCategories: [QuestionCategory.arithmetic.labelUz],
    );

    final generator = LocalAiStudyPlanGenerator();
    final bundle = await generator.generate(
      userId: 'u1',
      diagnostic: diagnostic,
    );

    expect(bundle.plan.totalWeeks, 24);
    expect(bundle.lessons, isNotEmpty);
    expect(bundle.lessons.first.status.name, 'available');
    expect(bundle.plan.weakCategories, contains('Geometriya'));

    // Dastlabki oddiy haftalarda geometriya ko‘proq uchrashi kerak.
    final earlyTopics = bundle.lessons
        .where((l) => l.weekNumber <= 8 && l.topic != 'Imtihon')
        .map((l) => l.topic)
        .toList();
    final geoCount = earlyTopics.where((t) => t == 'Geometriya').length;
    final arithCount = earlyTopics.where((t) => t == 'Arifmetika').length;
    expect(geoCount, greaterThanOrEqualTo(arithCount));
  });

  test('LessonScript Sokratik promptlarni bankdan oladi', () {
    const lesson = LessonModel(
      id: 'l1',
      titleUz: 'Perimetr',
      orderIndex: 1,
      topic: 'Geometriya',
      weekNumber: 1,
      socraticPrompts: ['Nima berilgan?', 'Qanday boshlaysiz?'],
      audioScriptUz: 'Eski matn.',
    );
    final script = LessonScript.fromLesson(lesson);
    expect(script.introText.toLowerCase(), contains('perimetr'));
    expect(script.socraticSteps.length, 10);
    expect(script.socraticSteps.any((s) => s.hasVisual), isTrue);
    expect(script.summaryText, contains('Perimetr'));
  });

  test('Shakllarni tanish savollarida chizma bor', () {
    const lesson = LessonModel(
      id: 'l2',
      titleUz: 'Shakllarni tanish',
      orderIndex: 1,
      topic: 'Geometriya',
      weekNumber: 1,
    );
    final steps = SocraticBank.stepsFor(lesson);
    expect(steps.length, 10);
    expect(steps.every((s) => s.hasVisual), isTrue);
    expect(
      steps.any((s) => s.visual == LessonVisualKind.angleRight),
      isTrue,
    );
  });

  test('ProctoringGuard session start/end', () {
    final guard = StubProctoringGuard();
    final events = <ProctoringEvent>[];
    guard.addListener(events.add);
    guard.startSession(lessonId: 'l1');
    expect(guard.isActive, isTrue);
    guard.endSession();
    expect(guard.isActive, isFalse);
    expect(events, contains(ProctoringEvent.sessionStarted));
    expect(events, contains(ProctoringEvent.sessionEnded));
  });

  test('ProctoringGuard noFace da pauza va ogohlantirish', () {
    final guard = StubProctoringGuard();
    final events = <ProctoringEvent>[];
    guard.addListener(events.add);
    guard.startSession(lessonId: 'exam1');
    guard.simulate(ProctoringEvent.noFace);
    expect(guard.isPaused, isTrue);
    expect(guard.sessionWarningCount, 1);
    expect(events, contains(ProctoringEvent.noFace));
    guard.resumeAfterWarning();
    expect(guard.isPaused, isFalse);
    expect(events, contains(ProctoringEvent.resumed));
  });

  test('PracticeQuestionFactory 15 ta savol qaytaradi', () {
    const lesson = LessonModel(
      id: 'l1',
      titleUz: 'Ko‘paytirish jadvali',
      orderIndex: 1,
      topic: 'Arifmetika',
      weekNumber: 1,
    );
    final qs = PracticeQuestionFactory.forLesson(lesson, random: Random(42));
    expect(qs.length, 15);
    expect(qs.every((q) => q.options.isNotEmpty), isTrue);
  });

  test('HomeworkAssigner muddat va notebook turi beradi', () {
    const lesson = LessonModel(
      id: 'l1',
      titleUz: 'Perimetr',
      orderIndex: 1,
      topic: 'Geometriya',
      weekNumber: 1,
    );
    final now = DateTime(2026, 7, 24, 12);
    final hw = HomeworkAssigner.fromLesson(lesson, now: now);
    expect(hw.type, HomeworkType.notebook);
    expect(hw.status, HomeworkStatus.assigned);
    expect(hw.dueAt, now.add(const Duration(days: 1)));
    expect(hw.problemStatement, isNotEmpty);
    expect(hw.isPendingScan, isTrue);
  });

  test('Vision AI qadamlarni JSON qilib qaytaradi', () async {
    final hw = HomeworkModel.demo();
    final result = await StubVisionAiService().analyzeNotebookPage(
      imagePath: '/tmp/demo.jpg',
      homework: hw,
    );
    expect(result.steps, isNotEmpty);
    expect(result.toJson()['steps'], isA<List>());
    expect(result.confidence, greaterThan(0.5));
  });

  test('AI Grading mastery va xato qadamlarni qaytaradi', () async {
    final hw = HomeworkModel.demo().copyWith(
      extractedSteps: const [
        'Berilgan: 24 × 15',
        '24ni 15 marta qo‘shish',
        'Oraliq: 336',
        'Javob: 363',
      ],
      visionConfidence: 0.9,
    );
    final result = await LocalAiGradingService().grade(
      homework: hw,
      studentSteps: hw.extractedSteps,
    );
    expect(result.masteryPercent, inInclusiveRange(0, 100));
    expect(result.steps, isNotEmpty);
    expect(result.errorCount, greaterThan(0));
    expect(result.coinsEarned, greaterThanOrEqualTo(0));
    expect(result.feedbackUz, isNotEmpty);
  });

  test('ErrorAnalysisCoach har xato uchun Sokratik savol beradi', () {
    final hw = HomeworkModel.demo().copyWith(
      errorSteps: const [
        HomeworkErrorStep(
          stepIndex: 2,
          studentStep: 'Javob: 363',
          explanationUz: 'Yakuniy javob mos kelmadi.',
          correctHintUz: 'Javob: 360',
        ),
      ],
    );
    final items = const ErrorAnalysisCoach().buildFor(hw);
    expect(items, hasLength(1));
    expect(items.first.simpleExplainUz, contains('363'));
    expect(items.first.socraticQuestions, isNotEmpty);
    expect(items.first.softHintUz, isNotNull);
  });

  test('Mastery Lock: 79% ochilmaydi, 80% ochiladi', () {
    expect(MasteryHelper.isMastered(79), isFalse);
    expect(MasteryHelper.isMastered(80), isTrue);
    expect(MasteryHelper.remainingToUnlock(79), 1);
    expect(MasteryHelper.remainingToUnlock(80), 0);

    final now = DateTime.now();
    final trialUser = UserModel(
      id: 'u1',
      studentName: 'Ali',
      grade: StudentGrade.grade3,
      targetSchool: 'PM',
      parentPhone: '+998901234567',
      createdAt: now,
      subscriptionStatus: SubscriptionStatus.trial,
      trialStartedAt: now,
      subscriptionExpiresAt: now.add(const Duration(days: 7)),
      serverNowAtFetch: now,
      deviceObservedAt: now,
    );
    expect(
      MasteryHelper.canUnlockNext(currentMastery: 80, user: trialUser),
      isTrue,
    );

    final expired = trialUser.copyWith(
      subscriptionStatus: SubscriptionStatus.expired,
      subscriptionExpiresAt: now.subtract(const Duration(days: 1)),
      serverNowAtFetch: now,
      deviceObservedAt: now,
    );
    expect(
      MasteryHelper.reasonBlockingUnlock(currentMastery: 85, user: expired),
      LockBlockReason.subscriptionRequired,
    );
    expect(
      MasteryHelper.reasonBlockingUnlock(currentMastery: 79, user: trialUser),
      LockBlockReason.masteryTooLow,
    );
  });

  test('ExamScorer ball, liga va ranking hisoblaydi', () {
    const lesson = LessonModel(
      id: 'lesson_w4_exam',
      titleUz: 'Oy 1 mini-imtihon',
      orderIndex: 8,
      topic: 'Imtihon',
      weekNumber: 4,
      coinsReward: 40,
    );
    expect(lesson.isExam, isTrue);

    final questions = ExamQuestionBank.forWeek(4);
    expect(questions.length, 10);

    final answers = <String, String>{
      for (final q in questions) q.id: q.correctAnswer,
    };
    final result = ExamScorer.build(
      id: 'ex1',
      userId: 'u1',
      lesson: lesson,
      questions: questions,
      selectedAnswers: answers,
      durationSeconds: 600,
    );
    expect(result.overallPercent, 100);
    expect(result.league, LeagueTier.diamond);
    expect(result.estimatedRank, 1);
    expect(result.coinsEarned, greaterThan(0));
  });

  test('Missed homework → ota-ona overdue alert', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = await StorageService.init();
    final alerts = StubParentAlertService();
    final hwService = HomeworkService(storage: storage, alerts: alerts);

    final user = UserModel(
      id: 'u1',
      studentName: 'Ali',
      grade: StudentGrade.grade3,
      targetSchool: 'PM',
      parentPhone: '+998901234567',
      createdAt: DateTime.now(),
      streakDays: 3,
    );
    await storage.saveUser(user);

    final overdue = HomeworkModel.demo().copyWith(
      id: 'hw-late',
      dueAt: DateTime.now().subtract(const Duration(days: 2)),
      status: HomeworkStatus.assigned,
    );
    await storage.upsertHomework(overdue);

    final n = await hwService.checkOverdueAndAlert();
    expect(n, 1);
    expect(alerts.sentLog.any((e) => e.type == ParentAlertType.homeworkOverdue),
        isTrue);
    expect(alerts.sentLog.any((e) => e.type == ParentAlertType.streakAtRisk),
        isTrue);

    // Dedupe: ikkinchi chaqiriqda qayta yubormasligi kerak.
    final n2 = await hwService.checkOverdueAndAlert();
    expect(n2, 0);
  });

  test('StreakMonitor uzilganda alert yuboradi', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = await StorageService.init();
    final alerts = StubParentAlertService();

    await storage.saveUser(
      UserModel(
        id: 'u1',
        studentName: 'Ali',
        grade: StudentGrade.grade3,
        targetSchool: 'PM',
        parentPhone: '+998901234567',
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        streakDays: 5,
        lastActiveDate: DateTime.now().subtract(const Duration(days: 3)),
      ),
    );

    final hit = await StreakMonitor(storage: storage, alerts: alerts)
        .checkAndAlert();
    expect(hit, isTrue);
    expect(
      alerts.sentLog.any((e) => e.type == ParentAlertType.streakAtRisk),
      isTrue,
    );
    expect(storage.getUser()!.streakDays, 0);
  });

  test('Gamification streak: kechagi faollik +1', () {
    final game = GamificationService();
    final now = DateTime(2026, 7, 24, 10);
    expect(
      game.updateStreak(
        currentStreak: 4,
        lastActive: DateTime(2026, 7, 23, 18),
        now: now,
      ),
      5,
    );
    expect(
      game.updateStreak(
        currentStreak: 4,
        lastActive: now,
        now: now,
      ),
      4,
    );
    expect(
      game.updateStreak(
        currentStreak: 4,
        lastActive: DateTime(2026, 7, 20),
        now: now,
      ),
      1,
    );
  });

  test('Avatar unlock: streak / level / coins', () {
    final fox = AvatarCatalog.byId('fox');
    expect(
      fox.isUnlocked(
        streakDays: 2,
        level: 1,
        coins: 0,
        unlockedIds: {},
      ),
      isFalse,
    );
    expect(
      fox.isUnlocked(
        streakDays: 3,
        level: 1,
        coins: 0,
        unlockedIds: {},
      ),
      isTrue,
    );

    final rocket = AvatarCatalog.byId('rocket');
    expect(
      rocket.isUnlocked(
        streakDays: 0,
        level: 3,
        coins: 0,
        unlockedIds: {},
      ),
      isTrue,
    );

    final dragon = AvatarCatalog.byId('dragon');
    expect(
      dragon.isUnlocked(
        streakDays: 0,
        level: 1,
        coins: 199,
        unlockedIds: {},
      ),
      isFalse,
    );
    expect(
      dragon.isUnlocked(
        streakDays: 0,
        level: 1,
        coins: 200,
        unlockedIds: {},
      ),
      isTrue,
    );
  });

  test('applyDailyActivity streak + avatar ochadi', () {
    final game = GamificationService();
    final user = UserModel(
      id: 'u1',
      studentName: 'Ali',
      grade: StudentGrade.grade3,
      targetSchool: 'PM',
      parentPhone: '+998901234567',
      createdAt: DateTime(2026, 7, 1),
      streakDays: 2,
      lastActiveDate: DateTime(2026, 7, 23),
      coins: 0,
      xp: 0,
      level: 1,
    );

    final reward = game.applyDailyActivity(
      user: user,
      unlockedAvatarIds: {'default'},
      now: DateTime(2026, 7, 24, 9),
    );

    expect(reward.user.streakDays, 3);
    expect(reward.streakIncreased, isTrue);
    expect(reward.coinsGained, greaterThan(0));
    expect(
      reward.newlyUnlockedAvatars.any((a) => a.id == 'fox'),
      isTrue,
    );
  });

  test('Haftalik liga: foydalanuvchi jadvalda', () {
    final game = GamificationService();
    final user = UserModel(
      id: 'u1',
      studentName: 'Ali',
      grade: StudentGrade.grade3,
      targetSchool: 'PM',
      parentPhone: '+998901234567',
      createdAt: DateTime(2026, 7, 1),
    );
    final board = game.buildWeeklyLeaderboard(user: user, weeklyXp: 120);
    expect(board.length, 10);
    expect(board.where((e) => e.isMe).length, 1);
    expect(board.first.rank, 1);
    expect(board.last.rank, 10);
    final me = board.firstWhere((e) => e.isMe);
    expect(me.nameUz, 'Ali');
    expect(me.weeklyXp, 120);
  });

  test('VoiceAiCoach: ovozli savol → o‘zbekcha javob', () async {
    final coach = VoiceAiCoach(tutor: AiTutorService());
    final lesson = LessonModel(
      id: 'l1',
      titleUz: 'Taqqoslash',
      topic: 'Mantiq',
      weekNumber: 1,
      orderIndex: 0,
      durationMinutes: 15,
      coinsReward: 20,
    );

    final help = await coach.answer(
      transcript: 'Men tushunmadim, yordam bering',
      lesson: lesson,
      currentPrompt: 'Nimalar taqqoslanmoqda?',
    );
    expect(help.answerUz.isNotEmpty, isTrue);
    expect(help.heardText.contains('tushunmadim'), isTrue);

    final how = await coach.answer(
      transcript: 'Qanday yechamiz?',
      lesson: lesson,
    );
    expect(how.answerUz.toLowerCase(), contains('formula'));

    final empty = await coach.answer(transcript: '   ', lesson: lesson);
    expect(empty.answerUz.contains('Eshitmadim'), isTrue);
  });

  test('SocraticBank: Taqqoslash uchun 10 ta savol', () {
    final lesson = LessonModel(
      id: 'l1',
      titleUz: 'Taqqoslash',
      topic: 'Mantiq',
      weekNumber: 1,
      orderIndex: 0,
    );
    final prompts = SocraticBank.promptsFor(lesson);
    expect(prompts.length, 10);
    expect(SocraticBank.introFor(lesson).toLowerCase(), contains('taqqos'));
  });

  test('Practice 15 ta: 5/5/5 daraja', () {
    final lesson = LessonModel(
      id: 'l1',
      titleUz: 'Taqqoslash',
      topic: 'Mantiq',
      weekNumber: 1,
      orderIndex: 0,
    );
    final qs = PracticeQuestionFactory.forLesson(lesson, random: Random(1));
    expect(qs.length, AppConstants.practiceExerciseMax);
    expect(qs.where((q) => q.difficulty == QuestionDifficulty.easy).length, 5);
    expect(
        qs.where((q) => q.difficulty == QuestionDifficulty.medium).length, 5);
    expect(qs.where((q) => q.difficulty == QuestionDifficulty.hard).length, 5);
  });

  test('Uyga vazifa 15 ta har xil daraja', () {
    final lesson = LessonModel(
      id: 'l1',
      titleUz: 'Taqqoslash',
      topic: 'Mantiq',
      weekNumber: 1,
      orderIndex: 0,
    );
    final set = HomeworkAssigner.setForLesson(lesson);
    expect(set.length, 15);
    expect(
      set.where((h) => h.difficulty == QuestionDifficulty.easy).length,
      5,
    );
    expect(
      set.where((h) => h.difficulty == QuestionDifficulty.hard).length,
      5,
    );
  });

  test('Stub STT + askVoiceCoach: savol → TTS javob', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = await StorageService.init();
    final tts = StubTtsService();
    final stt = StubSttService(simulatedText: 'Bu masalani qanday yechamiz?');
    final cubit = LessonCubit(
      lesson: LessonModel(
        id: 'l1',
        titleUz: 'Kasrlar',
        topic: 'Kasrlar',
        weekNumber: 1,
        orderIndex: 0,
        durationMinutes: 10,
        coinsReward: 10,
      ),
      tts: tts,
      stt: stt,
      proctoring: StubProctoringGuard(),
      storage: storage,
    );

    await cubit.start();
    await cubit.askVoiceCoach('Qanday yechamiz?');

    expect(cubit.state.lastHeardText, 'Qanday yechamiz?');
    expect(cubit.state.voiceReplyText.isNotEmpty, isTrue);
    expect(cubit.state.hasVoiceReply, isTrue);

    await cubit.toggleVoiceAsk();
    await Future<void>.delayed(const Duration(milliseconds: 250));
    expect(cubit.state.lastHeardText, contains('qanday'));
    expect(cubit.state.voiceReplyText.isNotEmpty, isTrue);

    await cubit.close();
  });
}
