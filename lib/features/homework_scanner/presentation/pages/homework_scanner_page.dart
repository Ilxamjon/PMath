import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../models/homework_model.dart';
import '../../../homework/data/homework_service.dart';
import '../../../homework/presentation/pages/homework_detail_page.dart';
import '../../../../services/storage_service.dart';
import 'camera_scan_page.dart';

/// Vision AI skaner + kutilayotgan yozma vazifalar ro‘yxati.
class HomeworkScannerPage extends StatefulWidget {
  const HomeworkScannerPage({super.key});

  @override
  State<HomeworkScannerPage> createState() => _HomeworkScannerPageState();
}

class _HomeworkScannerPageState extends State<HomeworkScannerPage> {
  HomeworkModel? _selected;
  List<HomeworkModel> _pending = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reload();
    context.read<HomeworkService>().checkOverdueAndAlert();
    // Avtomatik birinchi vazifani tanlash — «Skanerga o‘tish» darhol ishlasin.
    if (_selected == null && _pending.isNotEmpty) {
      _selected = _pending.first;
    }
  }

  void _reload() {
    final list = context.read<StorageService>().pendingHomework;
    setState(() {
      _pending = list;
      if (_selected != null) {
        final still = list.where((h) => h.id == _selected!.id);
        _selected = still.isEmpty
            ? (list.isEmpty ? null : list.first)
            : still.first;
      } else if (list.isNotEmpty) {
        _selected = list.first;
      }
    });
  }

  Future<void> _capture() async {
    // Hech narsa tanlanmagan bo‘lsa — birinchisini olamiz.
    if (_selected == null && _pending.isNotEmpty) {
      setState(() => _selected = _pending.first);
    }
    if (_selected == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Avval mashqni yakunlang — uyga vazifa paydo bo‘ladi, keyin skanerlang.',
          ),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    final done = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => CameraScanPage(homework: _selected!),
      ),
    );
    if (!mounted) return;
    _reload();
    if (done == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(AppStrings.visionReadyForGrade),
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
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      appBar: AppBar(
        title: const Text(AppStrings.scannerTitle),
        backgroundColor: AppColors.primaryDark,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              AppStrings.homeworkPending,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.accent,
                  ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 110,
              child: _pending.isEmpty
                  ? Center(
                      child: Text(
                        AppStrings.homeworkEmpty,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textMuted,
                            ),
                      ),
                    )
                  : ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _pending.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 10),
                      itemBuilder: (context, i) {
                        final hw = _pending[i];
                        final selected = _selected?.id == hw.id;
                        return GestureDetector(
                          onTap: () => setState(() => _selected = hw),
                          onLongPress: () async {
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    HomeworkDetailPage(homework: hw),
                              ),
                            );
                            if (mounted) _reload();
                          },
                          child: Container(
                            width: 200,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppColors.accentSoft
                                  : AppColors.primary,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: selected
                                    ? AppColors.accent
                                    : AppColors.primaryLight,
                                width: 2,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  hw.titleUz,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: selected
                                        ? AppColors.textPrimary
                                        : AppColors.textOnPrimary,
                                    fontSize: 13,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  hw.isOverdue
                                      ? AppStrings.homeworkOverdue
                                      : '${AppStrings.homeworkDue}: ${_shortDue(hw)}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: hw.isOverdue
                                        ? AppColors.error
                                        : (selected
                                            ? AppColors.accentDark
                                            : AppColors.accent),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppColors.accent.withValues(alpha: 0.5),
                    width: 2,
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.photo_camera_front_outlined,
                          size: 72,
                          color: AppColors.accent.withValues(alpha: 0.85),
                        ),
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            _selected == null
                                ? AppStrings.homeworkSelectToScan
                                : AppStrings.scannerHint,
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(color: AppColors.textOnPrimary),
                          ),
                        ),
                        if (_selected != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            _selected!.titleUz,
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(color: AppColors.accent),
                          ),
                        ],
                      ],
                    ),
                    Positioned(
                      top: 20,
                      left: 20,
                      child: _Corner(top: true, left: true),
                    ),
                    Positioned(
                      top: 20,
                      right: 20,
                      child: _Corner(top: true, left: false),
                    ),
                    Positioned(
                      bottom: 20,
                      left: 20,
                      child: _Corner(top: false, left: true),
                    ),
                    Positioned(
                      bottom: 20,
                      right: 20,
                      child: _Corner(top: false, left: false),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _capture,
                icon: const Icon(Icons.camera_alt_rounded),
                label: const Text(AppStrings.visionOpenCamera),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Kamera · Galereya · Demo skan · Vision AI OCR',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textMuted,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  String _shortDue(HomeworkModel hw) {
    if (hw.dueAt == null) return '—';
    if (hw.daysUntilDue == 0) return AppStrings.homeworkToday;
    if (hw.daysUntilDue == 1) return AppStrings.homeworkTomorrow;
    return DateFormat('dd.MM').format(hw.dueAt!);
  }
}

class _Corner extends StatelessWidget {
  const _Corner({required this.top, required this.left});

  final bool top;
  final bool left;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        border: Border(
          top: top
              ? const BorderSide(color: AppColors.accent, width: 3)
              : BorderSide.none,
          bottom: !top
              ? const BorderSide(color: AppColors.accent, width: 3)
              : BorderSide.none,
          left: left
              ? const BorderSide(color: AppColors.accent, width: 3)
              : BorderSide.none,
          right: !left
              ? const BorderSide(color: AppColors.accent, width: 3)
              : BorderSide.none,
        ),
      ),
    );
  }
}
