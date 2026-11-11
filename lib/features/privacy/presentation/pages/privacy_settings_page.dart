import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/navigation/app_shell_nav.dart';
import '../../../../models/user_model.dart';
import '../../../../services/storage_service.dart';
import '../../../proctoring/domain/proctoring_guard.dart';
import '../../domain/account_erasure.dart';
import '../../domain/third_party_sdks.dart';
import '../widgets/consent_summary.dart';

class PrivacySettingsPage extends StatelessWidget {
  const PrivacySettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.read<StorageService>().getUser();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text(AppStrings.privacySettingsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            _status(user),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          if (user?.parentConsentAt != null) ...[
            const SizedBox(height: 4),
            Text(
              '${AppStrings.privacyWhen}: ${DateFormat('dd.MM.yyyy HH:mm').format(user!.parentConsentAt!.toLocal())}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
          const SizedBox(height: 8),
          Text(
            AppStrings.privacyRedoHint,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          const ConsentSummary(),
          const SizedBox(height: 20),
          Text(
            AppStrings.privacySdkTitle,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 6),
          Text(
            AppStrings.privacySdkIntro,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          ...thirdPartySdks.map((sdk) => _SdkTile(sdk: sdk)),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () => _confirmDelete(context),
            child: const Text(AppStrings.privacyDelete),
          ),
        ],
      ),
    );
  }

  String _status(UserModel? user) {
    if (user?.parentConsentAt == null) return AppStrings.privacyStatusMissing;
    if (user!.parentConsentGranted) return AppStrings.privacyStatusOn;
    return AppStrings.privacyStatusOff;
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.privacyDeleteTitle),
        content: const Text(AppStrings.privacyDeleteBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(AppStrings.privacyDeleteConfirm),
          ),
        ],
      ),
    );
    if (yes != true || !context.mounted) return;

    context.read<ProctoringGuard>().endSession();
    final outcome = await context.read<AccountErasure>().erase();
    if (!context.mounted) return;

    if (outcome == ErasureOutcome.serverFailed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.privacyDeleteFailed)),
      );
      return;
    }

    if (outcome == ErasureOutcome.localOnly) {
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          content: const Text(AppStrings.privacyDeleteLocalOnly),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(AppStrings.ok),
            ),
          ],
        ),
      );
    }
    if (!context.mounted) return;
    AppShellNav.requestRestart();
  }
}

class _SdkTile extends StatelessWidget {
  const _SdkTile({required this.sdk});

  final ThirdPartySdk sdk;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (sdk.risk) {
      KidsStoreRisk.conflict => (
          AppStrings.privacySdkConflict,
          AppColors.error,
        ),
      KidsStoreRisk.review => (AppStrings.privacySdkReview, AppColors.warning),
      KidsStoreRisk.none => (AppStrings.privacySdkOk, AppColors.success),
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(sdk.package, style: Theme.of(context).textTheme.titleMedium),
          Text(sdk.roleUz, style: Theme.of(context).textTheme.bodyMedium),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }
}
