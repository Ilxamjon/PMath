import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../models/user_model.dart';
import '../../../../services/storage_service.dart';

/// Stub paywall — Click/Payme/RevenueCat keyinroq ulanadi.
class PaywallPage extends StatelessWidget {
  const PaywallPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text(AppStrings.paywallTitle)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.paywallHero,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppColors.textOnPrimary,
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppStrings.paywallHeroBody,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.textOnPrimary.withValues(alpha: 0.9),
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _PlanTile(
            title: AppStrings.paywallMonthly,
            price: _price(AppConstants.monthlyPriceUzs),
            subtitle: AppStrings.paywallMonthlyHint,
            onTap: () => _activate(context, months: 1),
          ),
          const SizedBox(height: 12),
          _PlanTile(
            title: AppStrings.paywallSixMonth,
            price: _price(AppConstants.sixMonthPriceUzs),
            subtitle: AppStrings.paywallSixMonthHint,
            highlighted: true,
            onTap: () => _activate(context, months: 6),
          ),
          const SizedBox(height: 20),
          Text(
            AppStrings.paywallStubNote,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  static String _price(int uzs) {
    final s = uzs.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      buf.write(s[i]);
      final fromEnd = s.length - i;
      if (fromEnd > 1 && fromEnd % 3 == 1) buf.write(' ');
    }
    return '$buf so‘m';
  }

  Future<void> _activate(BuildContext context, {required int months}) async {
    final storage = context.read<StorageService>();
    final user = storage.getUser();
    if (user == null) return;

    final expires = DateTime.now().add(Duration(days: 30 * months));
    await storage.saveUser(
      user.copyWith(
        subscriptionStatus: SubscriptionStatus.active,
        subscriptionExpiresAt: expires,
      ),
    );

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppStrings.paywallActivated),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
    Navigator.of(context).pop(true);
  }
}

class _PlanTile extends StatelessWidget {
  const _PlanTile({
    required this.title,
    required this.price,
    required this.subtitle,
    required this.onTap,
    this.highlighted = false,
  });

  final String title;
  final String price;
  final String subtitle;
  final VoidCallback onTap;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: highlighted ? AppColors.accentSoft : AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: highlighted ? AppColors.accent : AppColors.surfaceAlt,
              width: highlighted ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              Text(
                price,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
