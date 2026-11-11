import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/mastery_helper.dart';
import '../../../../models/lesson_model.dart';
import '../../../../models/study_plan_bundle.dart';
import '../../../../models/study_plan_model.dart';
import '../../../../models/user_model.dart';
import '../../../../services/ai_tutor_service.dart';
import '../../../../services/parent_alert_service.dart';
import '../../../../services/storage_service.dart';
import '../../../../services/stt_service.dart';
import '../../../../services/tts_service.dart';
import '../../../exam/presentation/pages/exam_page.dart';
import '../../../gamification/presentation/pages/gamification_hub_page.dart';
import '../../../lesson/presentation/cubit/lesson_cubit.dart';
import '../../../lesson/presentation/pages/lesson_room_page.dart';
import '../../../voice_ai/domain/voice_ai_coach.dart';
import '../../../mastery_lock/presentation/widgets/mastery_lock_dialogs.dart';
import '../../../proctoring/domain/proctoring_guard.dart';
import '../../../subscription/presentation/pages/paywall_page.dart';
import '../widgets/gamification_header.dart';
import '../widgets/roadmap_node.dart';

/// Duolingo uslubidagi vertikal o‘quv xaritasi — AI rejadan.
class LearningMapPage extends StatefulWidget {
  const LearningMapPage({super.key, required this.user});

  final UserModel user;

  @override
  State<LearningMapPage> createState() => _LearningMapPageState();
}

class _LearningMapPageState extends State<LearningMapPage> {
  StudyPlanBundle? _bundle;
  late UserModel _user;

  @override
  void initState() {
    super.initState();
    _user = widget.user;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _refreshFromStorage();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _bundle ??= context.read<StorageService>().getStudyPlanBundle();
  }

  void _refreshFromStorage() {
    final storage = context.read<StorageService>();
    setState(() {
      _bundle = storage.getStudyPlanBundle();
      _user = storage.getUser() ?? _user;
    });
  }

  List<LessonModel> get _lessons {
    final fromPlan = _bundle?.lessons;
    if (fromPlan != null && fromPlan.isNotEmpty) return fromPlan;
    return LessonModel.demoRoadmap();
  }

  StudyPlanModel? get _plan => _bundle?.plan;

  RoadmapNodeStatus _statusFor(int index) {
    final lessons = _lessons;
    final lesson = lessons[index];

    if (lesson.status == LessonStatus.completed &&
        MasteryHelper.isMastered(lesson.masteryPercent)) {
      return RoadmapNodeStatus.completed;
    }
    if (lesson.status == LessonStatus.inProgress ||
        lesson.status == LessonStatus.available) {
      return RoadmapNodeStatus.active;
    }
    if (lesson.status == LessonStatus.completed) {
      // Mastery < 80% — tugallangan lekin lock ochilmagan.
      return RoadmapNodeStatus.active;
    }
    // locked
    return RoadmapNodeStatus.locked;
  }

  Future<void> _onNodeTap(LessonModel lesson, int index, RoadmapNodeStatus status) async {
    if (status == RoadmapNodeStatus.locked) {
      await _showLockReason(index);
      return;
    }

    // Sinov tugagan + obuna yo‘q → yangi dars ochilmaydi (davom etayotgan OK).
    if (!_user.hasAccessBeyondTrial &&
        lesson.status != LessonStatus.inProgress &&
        lesson.status != LessonStatus.completed) {
      final goPaywall = await showSubscriptionGateDialog(context);
      if (!mounted) return;
      if (goPaywall == true) {
        final ok = await Navigator.of(context).push<bool>(
          MaterialPageRoute(builder: (_) => const PaywallPage()),
        );
        if (!mounted) return;
        _refreshFromStorage();
        if (ok != true) return;
      } else {
        return;
      }
    }

    await _openLessonRoom(lesson);
  }

  Future<void> _showLockReason(int index) async {
    final lessons = _lessons;
    if (index <= 0) {
      await showMasteryLockDialog(
        context,
        previousLessonTitle: lessons.first.titleUz,
        previousMastery: 0,
      );
      return;
    }

    final prev = lessons[index - 1];
    final reason = MasteryHelper.reasonForLockedNode(
      previousMastery: prev.masteryPercent,
      previousCompleted: prev.status == LessonStatus.completed,
      user: _user,
    );

    if (reason == LockBlockReason.subscriptionRequired) {
      final goPaywall = await showSubscriptionGateDialog(context);
      if (!mounted) return;
      if (goPaywall == true) {
        await Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const PaywallPage()),
        );
        if (!mounted) return;
        _refreshFromStorage();
      }
      return;
    }

    await showMasteryLockDialog(
      context,
      previousLessonTitle: prev.titleUz,
      previousMastery: prev.masteryPercent,
    );
  }

  Future<void> _openLessonRoom(LessonModel lesson) async {
    if (lesson.isExam) {
      await _openExam(lesson);
      return;
    }

    final storage = context.read<StorageService>();
    final tts = context.read<TtsService>();
    final stt = context.read<SttService>();
    final proctoring = context.read<ProctoringGuard>();

    final completed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => LessonCubit(
            lesson: lesson,
            tts: tts,
            stt: stt,
            proctoring: proctoring,
            storage: storage,
            parentAlerts: context.read<ParentAlertService>(),
            voiceCoach: VoiceAiCoach(
              tutor: context.read<AiTutorService>(),
            ),
          )..start(),
          child: const LessonRoomPage(),
        ),
      ),
    );

    if (!mounted) return;
    _refreshFromStorage();

    if (completed == true) {
      final lessons = storage.getStudyPlanBundle()?.lessons ?? const [];
      final match = lessons.where((l) => l.id == lesson.id);
      final mastery =
          match.isEmpty ? 0.0 : match.first.masteryPercent;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${lesson.titleUz} — ${mastery.toStringAsFixed(0)}${AppStrings.percent}',
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  Future<void> _openExam(LessonModel lesson) async {
    final completed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ExamPage(
          lesson: lesson,
          userId: _user.id,
        ),
      ),
    );

    if (!mounted) return;
    _refreshFromStorage();

    if (completed == true) {
      final exam = context.read<StorageService>().getExamResultForLesson(lesson.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            exam == null
                ? lesson.titleUz
                : '${AppStrings.examDoneSnack}: '
                    '${exam.overallPercent.toStringAsFixed(0)}% · '
                    '${exam.league.labelUz}',
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final lessons = _lessons;
    final plan = _plan;
    final showTrialBanner = _user.subscriptionStatus == SubscriptionStatus.trial &&
        _user.trialDaysLeft <= AppConstants.freeTrialDays;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.mapBackgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              GamificationHeader(
                user: _user,
                onTap: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const GamificationHubPage(),
                    ),
                  );
                  if (mounted) _refreshFromStorage();
                },
              ),
              if (!_user.hasAccessBeyondTrial)
                _GateBanner(
                  text: AppStrings.subscriptionExpiredBanner,
                  onTap: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const PaywallPage()),
                    );
                    if (mounted) _refreshFromStorage();
                  },
                )
              else if (showTrialBanner && _user.trialDaysLeft <= 3)
                _GateBanner(
                  text: AppStrings.trialDaysLeftBanner
                      .replaceAll('{n}', '${_user.trialDaysLeft}'),
                  soft: true,
                  onTap: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const PaywallPage()),
                    );
                    if (mounted) _refreshFromStorage();
                  },
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        AppStrings.learningMapTitle,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ),
                    if (plan != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accentSoft,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${AppStrings.roadmapWeekHeader} ${plan.currentWeek}/${plan.totalWeeks}',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.accentDark,
                                    fontWeight: FontWeight.w800,
                                  ),
                        ),
                      ),
                  ],
                ),
              ),
              if (plan != null && plan.weakCategories.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '${AppStrings.roadmapFocus}: ${plan.weakCategories.join(', ')}',
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              Expanded(
                child: lessons.isEmpty
                    ? const Center(child: Text(AppStrings.roadmapEmpty))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        itemCount: lessons.length,
                        itemBuilder: (context, index) {
                          final lesson = lessons[index];
                          final status = _statusFor(index);
                          final showWeekHeader = index == 0 ||
                              lessons[index - 1].weekNumber !=
                                  lesson.weekNumber;
                          final align = index.isEven
                              ? Alignment.centerLeft
                              : Alignment.centerRight;

                          return Column(
                            children: [
                              if (showWeekHeader)
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(20, 8, 20, 12),
                                  child: Text(
                                    '${AppStrings.roadmapWeekHeader} ${lesson.weekNumber}'
                                    '${lesson.isExam ? ' · Imtihon' : ''}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(color: AppColors.primary),
                                  ),
                                ),
                              if (index > 0 && !showWeekHeader)
                                RoadmapConnector(
                                  completed: _statusFor(index - 1) ==
                                      RoadmapNodeStatus.completed,
                                ),
                              Align(
                                alignment: align,
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    left: index.isEven ? 36 : 0,
                                    right: index.isEven ? 0 : 36,
                                  ),
                                  child: RoadmapNode(
                                    lesson: lesson,
                                    status: status,
                                    onTap: () =>
                                        _onNodeTap(lesson, index, status),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GateBanner extends StatelessWidget {
  const _GateBanner({
    required this.text,
    required this.onTap,
    this.soft = false,
  });

  final String text;
  final VoidCallback onTap;
  final bool soft;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: soft ? AppColors.accentSoft : AppColors.errorSoft,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Icon(
                soft ? Icons.timer_outlined : Icons.lock_outline,
                color: soft ? AppColors.accentDark : AppColors.error,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  text,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: soft ? AppColors.accentDark : AppColors.error,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: soft ? AppColors.accentDark : AppColors.error,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
