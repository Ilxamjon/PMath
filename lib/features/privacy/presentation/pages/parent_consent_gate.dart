import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../models/user_model.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/storage_service.dart';
import '../widgets/consent_summary.dart';

/// Eski profilga bir marta rozilik so‘rash.
class ParentConsentGate extends StatefulWidget {
  const ParentConsentGate({super.key, required this.user, required this.onDone});

  final UserModel user;
  final VoidCallback onDone;

  @override
  State<ParentConsentGate> createState() => _ParentConsentGateState();
}

class _ParentConsentGateState extends State<ParentConsentGate> {
  var _busy = false;

  Future<void> _choose(bool granted) async {
    if (_busy) return;
    setState(() => _busy = true);
    final at = DateTime.now();
    final next = widget.user.copyWith(
      parentConsentGranted: granted,
      parentConsentAt: at,
    );
    final storage = context.read<StorageService>();
    final auth = context.read<AuthService>();
    await storage.saveUser(next);
    try {
      await auth.saveParentConsent(granted: granted, at: at);
    } catch (_) {}
    if (!mounted) return;
    widget.onDone();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text(AppStrings.privacyTitle)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Column(
            children: [
              const Expanded(
                child: SingleChildScrollView(child: ConsentSummary()),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _busy ? null : () => _choose(true),
                  child: const Text(AppStrings.privacyAgree),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: _busy ? null : () => _choose(false),
                  child: const Text(AppStrings.privacyDecline),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
