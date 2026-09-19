import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/navigation/app_shell_nav.dart';
import '../../../../models/user_model.dart';
import '../../../../services/parent_alert_service.dart';
import '../../../../services/storage_service.dart';
import '../../../../services/streak_monitor.dart';
import '../../../homework/data/homework_service.dart';
import '../../../homework_scanner/presentation/pages/homework_scanner_page.dart';
import '../../../learning_map/presentation/pages/learning_map_page.dart';
import '../../../parent_dashboard/presentation/pages/parent_dashboard_page.dart';

/// Asosiy qobiq: pastki navigatsiya (Xarita / Skaner / Ota-ona).
class MainShell extends StatefulWidget {
  const MainShell({super.key, required this.user});

  final UserModel user;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> with WidgetsBindingObserver {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    AppShellNav.pendingTab.addListener(_onPendingTab);
    WidgetsBinding.instance.addPostFrameCallback((_) => _onShellReady());
  }

  @override
  void dispose() {
    AppShellNav.pendingTab.removeListener(_onPendingTab);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _onPendingTab() {
    final tab = AppShellNav.pendingTab.value;
    if (tab == null || !mounted) return;
    AppShellNav.pendingTab.value = null;
    if (tab != _index) setState(() => _index = tab);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _consumePendingTab();
    }
  }

  void _consumePendingTab() {
    if (!mounted) return;
    final tab = context.read<StorageService>().takePendingShellTab();
    if (tab != null && tab >= 0 && tab <= 2 && tab != _index) {
      setState(() => _index = tab);
    }
  }

  Future<void> _onShellReady() async {
    if (!mounted) return;
    _consumePendingTab();
    _onPendingTab();
    final storage = context.read<StorageService>();

    final reward = await storage.recordDailyOpen();
    if (!mounted) return;
    if (reward != null && (reward.coinsGained > 0 || reward.streakIncreased)) {
      final parts = <String>[];
      if (reward.coinsGained > 0 || reward.xpGained > 0) {
        parts.add(
          AppStrings.gamificationDailyBonus
              .replaceAll('{coins}', '${reward.coinsGained}')
              .replaceAll('{xp}', '${reward.xpGained}'),
        );
      }
      if (reward.streakIncreased) {
        parts.add(
          AppStrings.gamificationStreakUp
              .replaceAll('{n}', '${reward.user.streakDays}'),
        );
      }
      for (final a in reward.newlyUnlockedAvatars) {
        parts.add(
          AppStrings.gamificationAvatarUnlocked.replaceAll('{name}', a.nameUz),
        );
      }
      if (parts.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(parts.join(' · ')),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }

    await _runParentChecks();
  }

  Future<void> _runParentChecks() async {
    if (!mounted) return;
    final homework = context.read<HomeworkService>();
    final storage = context.read<StorageService>();
    final alerts = context.read<ParentAlertService>();

    final overdue = await homework.checkOverdueAndAlert();
    final streakHit = await StreakMonitor(
      storage: storage,
      alerts: alerts,
    ).checkAndAlert();

    if (!mounted) return;
    if (overdue > 0 || streakHit) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            overdue > 0
                ? AppStrings.parentOverdueAlerted.replaceAll('{n}', '$overdue')
                : AppStrings.parentStreakAlerted,
          ),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      LearningMapPage(user: widget.user),
      const HomeworkScannerPage(),
      ParentDashboardPage(user: widget.user),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.12),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: BottomNavigationBar(
            currentIndex: _index,
            onTap: (i) => setState(() => _index = i),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.map_rounded),
                activeIcon: Icon(Icons.map_rounded),
                label: AppStrings.tabMap,
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.document_scanner_outlined),
                activeIcon: Icon(Icons.document_scanner),
                label: AppStrings.tabScanner,
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.family_restroom_outlined),
                activeIcon: Icon(Icons.family_restroom),
                label: AppStrings.tabParent,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
