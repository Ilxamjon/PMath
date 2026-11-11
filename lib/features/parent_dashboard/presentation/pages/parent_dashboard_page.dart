import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/mastery_helper.dart';
import '../../../../models/homework_model.dart';
import '../../../../models/lesson_model.dart';
import '../../../../models/parent_alert_log.dart';
import '../../../../models/study_plan_model.dart';
import '../../../../models/user_model.dart';
import '../../../../services/parent_alert_service.dart';
import '../../../../services/storage_service.dart';
import '../../../homework/data/homework_service.dart';
import '../../../homework/presentation/pages/homework_detail_page.dart';
import '../../domain/telegram_link_service.dart';

/// Ota-ona paneli: real progress, zaif mavzu, Telegram alertlar.
class ParentDashboardPage extends StatefulWidget {
  const ParentDashboardPage({super.key, required this.user});

  final UserModel user;

  @override
  State<ParentDashboardPage> createState() => _ParentDashboardPageState();
}

class _ParentDashboardPageState extends State<ParentDashboardPage> {
  var _busy = false;
  var _waiting = false;
  Timer? _poll;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<HomeworkService>().checkOverdueAndAlert();
      _refreshLink();
    });
  }

  @override
  void dispose() {
    _poll?.cancel();
    super.dispose();
  }

  Future<void> _refreshLink() async {
    final status = await context.read<TelegramLinkService>().refresh();
    if (!mounted || !status.reachable) return;
    setState(() => _waiting = false);
  }

  Future<void> _connectTelegram() async {
    setState(() => _busy = true);
    final links = context.read<TelegramLinkService>();
    final session = await links.startLink();
    if (!mounted) return;
    if (session == null) {
      setState(() => _busy = false);
      _snack(AppStrings.telegramLinkFailed, AppColors.error);
      return;
    }

    var opened = false;
    try {
      opened = await launchUrl(
        session.url,
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {
      opened = false;
    }
    if (!mounted) return;
    if (!opened) {
      setState(() => _busy = false);
      _snack(AppStrings.telegramOpenFailed, AppColors.error);
      return;
    }

    setState(() {
      _busy = false;
      _waiting = true;
    });
    _poll?.cancel();
    var ticks = 0;
    _poll = Timer.periodic(const Duration(seconds: 3), (timer) async {
      ticks += 1;
      final status = await links.refresh();
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (status.linked) {
        timer.cancel();
        setState(() => _waiting = false);
        _snack(AppStrings.telegramLinked, AppColors.success);
      } else if (ticks >= 200) {
        timer.cancel();
        setState(() => _waiting = false);
      }
    });
  }

  Future<void> _sendTest() async {
    setState(() => _busy = true);
    final storage = context.read<StorageService>();
    final alerts = context.read<ParentAlertService>();
    final user = storage.getUser() ?? widget.user;
    await alerts.sendTestMessage(user: user);
    if (!mounted) return;
    setState(() => _busy = false);
    _snack(AppStrings.telegramTestSent, AppColors.info);
  }

  void _snack(String text, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final storage = context.read<StorageService>();
    final alerts = context.read<ParentAlertService>();
    final links = context.read<TelegramLinkService>();
    final liveUser = storage.getUser() ?? widget.user;
    final diagnostic = storage.getDiagnosticResult();
    final studyBundle = storage.getStudyPlanBundle();
    final plan = studyBundle?.plan ?? StudyPlanModel.demo(userId: liveUser.id);
    final lessons = studyBundle?.lessons ?? const <LessonModel>[];

    final completedLessons = lessons
        .where((l) => l.status == LessonStatus.completed)
        .toList();
    final avgMastery = completedLessons.isEmpty
        ? (diagnostic?.overallPercent ?? plan.overallProgress)
        : completedLessons
                .map((l) => l.masteryPercent)
                .reduce((a, b) => a + b) /
            completedLessons.length;

    final hours = liveUser.totalStudyMinutes ~/ 60;
    final mins = liveUser.totalStudyMinutes % 60;
    final overallPercent = avgMastery;
    final overall = (overallPercent / 100).clamp(0.0, 1.0);
    final weakTopics = diagnostic?.weakCategories ?? plan.weakCategories;
    final strongTopics = diagnostic?.strongCategories ?? plan.strongCategories;
    final pendingHw = storage.pendingHomework;
    final overdueHw = storage.overdueHomework;
    final gradedHw = storage
        .getHomeworkList()
        .where(
          (h) =>
              h.status == HomeworkStatus.graded ||
              h.status == HomeworkStatus.needsRevision,
        )
        .toList();
    final latestExam = storage.getLatestExamResult();
    final alertLogs = alerts.recentLogs.take(8).toList();
    final tgReady = alerts.isTelegramConfigured;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text(AppStrings.parentTitle)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _StudentCard(user: liveUser),
          const SizedBox(height: 16),
          if (pendingHw.isNotEmpty || overdueHw.isNotEmpty) ...[
            _SectionCard(
              title: AppStrings.homeworkPending,
              child: Column(
                children: [
                  ...pendingHw.take(5).map(
                    (hw) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        hw.isOverdue
                            ? Icons.warning_amber
                            : Icons.menu_book_outlined,
                        color: hw.isOverdue
                            ? AppColors.error
                            : AppColors.accentDark,
                      ),
                      title: Text(hw.titleUz),
                      subtitle: Text(
                        hw.isOverdue
                            ? AppStrings.homeworkOverdue
                            : '${AppStrings.homeworkDue}: ${hw.daysUntilDue == 0 ? AppStrings.homeworkToday : AppStrings.homeworkTomorrow}',
                      ),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                HomeworkDetailPage(homework: hw),
                          ),
                        );
                      },
                    ),
                  ),
                  if (overdueHw.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        AppStrings.homeworkMissedStreak,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.error,
                            ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (gradedHw.isNotEmpty) ...[
            _SectionCard(
              title: AppStrings.gradingRecent,
              child: Column(
                children: [
                  ...gradedHw.take(5).map(
                    (hw) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircularPercentIndicator(
                        radius: 22,
                        lineWidth: 5,
                        percent: (hw.masteryPercent / 100).clamp(0.0, 1.0),
                        progressColor:
                            MasteryHelper.colorFor(hw.masteryPercent),
                        backgroundColor: AppColors.surfaceAlt,
                        center: Text(
                          hw.masteryPercent.toStringAsFixed(0),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      title: Text(hw.titleUz),
                      subtitle: Text(
                        '${hw.status.labelUz} · '
                        '${MasteryHelper.masteryLabelUz(hw.masteryPercent)}',
                      ),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                HomeworkDetailPage(homework: hw),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (latestExam != null) ...[
            _SectionCard(
              title: AppStrings.examRecent,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    latestExam.titleUz,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${latestExam.overallPercent.toStringAsFixed(0)}% · '
                    '${latestExam.correctCount}/${latestExam.totalQuestions} · '
                    '${latestExam.league.emoji} ${latestExam.league.labelUz}',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          _SectionCard(
            title: AppStrings.progressOverview,
            child: Row(
              children: [
                CircularPercentIndicator(
                  radius: 52,
                  lineWidth: 10,
                  percent: overall,
                  progressColor: MasteryHelper.colorFor(overallPercent),
                  backgroundColor: AppColors.surfaceAlt,
                  circularStrokeCap: CircularStrokeCap.round,
                  center: Text(
                    '${overallPercent.toStringAsFixed(0)}%',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _InfoRow(
                        label: AppStrings.parentLessonsProgress,
                        value:
                            '${completedLessons.length}/${lessons.isEmpty ? '—' : lessons.length}',
                      ),
                      _InfoRow(
                        label: AppStrings.masteryPercent,
                        value: MasteryHelper.masteryLabelUz(overallPercent),
                      ),
                      _InfoRow(
                        label: AppStrings.hoursSpent,
                        value:
                            '$hours ${AppStrings.hours} $mins ${AppStrings.minutes}',
                      ),
                      _InfoRow(
                        label: AppStrings.parentStreakLabel,
                        value: '🔥 ${liveUser.streakDays}',
                      ),
                      _InfoRow(
                        label: AppStrings.cheatingAttempts,
                        value: '${liveUser.cheatingWarnings}',
                        valueColor: liveUser.cheatingWarnings > 0
                            ? AppColors.warning
                            : AppColors.success,
                      ),
                      _InfoRow(
                        label: AppStrings.trialDaysLeft,
                        value: '${liveUser.trialDaysLeft}',
                        valueColor: AppColors.accent,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: AppStrings.weakTopics,
            child: weakTopics.isEmpty
                ? Text(
                    '—',
                    style: Theme.of(context).textTheme.bodyMedium,
                  )
                : Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: weakTopics
                        .map(
                          (t) => Chip(
                            label: Text(t),
                            backgroundColor: AppColors.errorSoft,
                            labelStyle: const TextStyle(
                              color: AppColors.error,
                              fontWeight: FontWeight.w700,
                            ),
                            side: BorderSide.none,
                          ),
                        )
                        .toList(),
                  ),
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: AppStrings.telegramAlerts,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.telegram,
                      color: tgReady ? AppColors.success : AppColors.info,
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        tgReady
                            ? AppStrings.telegramStatusOn
                            : AppStrings.telegramStatusOff,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: tgReady
                                  ? AppColors.success
                                  : AppColors.textSecondary,
                            ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  links.isCloudReady
                      ? AppStrings.telegramHowTo
                      : AppStrings.telegramCloudOff,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                if (_waiting) ...[
                  const SizedBox(height: 8),
                  Text(
                    AppStrings.telegramWaiting,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.info,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (links.isCloudReady)
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _busy ? null : _connectTelegram,
                          child: const Text(AppStrings.telegramConnect),
                        ),
                      ),
                    if (links.isCloudReady) const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _busy ? null : _sendTest,
                        child: const Text(AppStrings.telegramTest),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  AppStrings.telegramRecent,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                if (alertLogs.isEmpty)
                  Text(
                    AppStrings.telegramEmptyLog,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  )
                else
                  ...alertLogs.map((e) => _AlertTile(entry: e)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Kuchli tomonlar',
            child: strongTopics.isEmpty
                ? const Text('—')
                : Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: strongTopics
                        .map(
                          (t) => Chip(
                            label: Text(t),
                            backgroundColor: AppColors.successSoft,
                            labelStyle: const TextStyle(
                              color: AppColors.success,
                              fontWeight: FontWeight.w700,
                            ),
                            side: BorderSide.none,
                          ),
                        )
                        .toList(),
                  ),
          ),
        ],
      ),
    );
  }
}

class _AlertTile extends StatelessWidget {
  const _AlertTile({required this.entry});

  final ParentAlertLogEntry entry;

  @override
  Widget build(BuildContext context) {
    final time = DateFormat('dd.MM HH:mm').format(entry.createdAt);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(entry.type.iconHint, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.type.labelUz,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                Text(
                  entry.messageUz,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  '$time · ${entry.channel}'
                  '${entry.delivered ? '' : ' · xato'}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StudentCard extends StatelessWidget {
  const _StudentCard({required this.user});

  final UserModel user;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.accent,
            child: Text(
              user.studentName.isNotEmpty
                  ? user.studentName[0].toUpperCase()
                  : '?',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.studentName,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.textOnPrimary,
                      ),
                ),
                Text(
                  '${user.grade.labelUz} · ${user.targetSchool}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textOnPrimary.withValues(alpha: 0.85),
                      ),
                ),
                Text(
                  user.parentPhone,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.accent,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: valueColor ?? AppColors.textPrimary,
                ),
          ),
        ],
      ),
    );
  }
}
