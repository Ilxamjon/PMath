import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../models/user_model.dart';
import '../cubit/onboarding_cubit.dart';
import '../cubit/onboarding_state.dart';
import '../widgets/grade_selector.dart';
import '../widgets/school_picker.dart';

/// Multi-step onboarding: ism → sinf → maktab → telefon → OTP → trial.
class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key, required this.onCompleted});

  final ValueChanged<UserModel> onCompleted;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OnboardingCubit, OnboardingState>(
      listenWhen: (prev, curr) =>
          curr.errorMessage != null &&
          curr.errorMessage != prev.errorMessage,
      listener: (context, state) {
        if (state.errorMessage == null) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.errorMessage!),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Column(
              children: [
                _TopBar(state: state),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 280),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    child: KeyedSubtree(
                      key: ValueKey(state.step),
                      child: _StepBody(state: state, onCompleted: onCompleted),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.state});

  final OnboardingState state;

  @override
  Widget build(BuildContext context) {
    final showProgress = state.step != OnboardingStep.welcome &&
        state.step != OnboardingStep.done;
    final canBack = state.step != OnboardingStep.welcome &&
        state.step != OnboardingStep.done;

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 20, 0),
      child: Column(
        children: [
          Row(
            children: [
              if (canBack)
                IconButton(
                  onPressed: state.isLoading
                      ? null
                      : () => context.read<OnboardingCubit>().goBack(),
                  icon: const Icon(Icons.arrow_back_rounded),
                  color: AppColors.primary,
                  tooltip: AppStrings.back,
                )
              else
                const SizedBox(width: 48),
              Expanded(
                child: Text(
                  AppStrings.appName,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.primary,
                      ),
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
          if (showProgress) ...[
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Text(
                    '${state.visibleProgress}/${OnboardingState.totalVisibleSteps} ${AppStrings.stepOf}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: state.visibleProgress /
                      OnboardingState.totalVisibleSteps,
                  minHeight: 8,
                  backgroundColor: AppColors.surfaceAlt,
                  color: AppColors.accent,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StepBody extends StatelessWidget {
  const _StepBody({required this.state, required this.onCompleted});

  final OnboardingState state;
  final ValueChanged<UserModel> onCompleted;

  @override
  Widget build(BuildContext context) {
    return switch (state.step) {
      OnboardingStep.welcome => const _WelcomeStep(),
      OnboardingStep.name => _NameStep(state: state),
      OnboardingStep.grade => _GradeStep(state: state),
      OnboardingStep.school => _SchoolStep(state: state),
      OnboardingStep.phone => _PhoneStep(state: state),
      OnboardingStep.otp => _OtpStep(state: state),
      OnboardingStep.done => _DoneStep(
          user: state.completedUser!,
          onCompleted: onCompleted,
        ),
    };
  }
}

// —— Shared layout ——

class _StepScaffold extends StatelessWidget {
  const _StepScaffold({
    required this.title,
    required this.child,
    this.subtitle,
    this.primaryLabel = AppStrings.continueBtn,
    this.onPrimary,
    this.isLoading = false,
    this.primaryEnabled = true,
  });

  final String title;
  final String? subtitle;
  final Widget child;
  final String primaryLabel;
  final VoidCallback? onPrimary;
  final bool isLoading;
  final bool primaryEnabled;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: Theme.of(context).textTheme.headlineMedium),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(subtitle!, style: Theme.of(context).textTheme.bodyMedium),
          ],
          const SizedBox(height: 28),
          Expanded(child: SingleChildScrollView(child: child)),
          const SizedBox(height: 12),
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: (!primaryEnabled || isLoading) ? null : onPrimary,
              child: isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    )
                  : Text(primaryLabel),
            ),
          ),
        ],
      ),
    );
  }
}

InputDecoration _fieldDecoration(String hint) {
  return InputDecoration(
    hintText: hint,
    filled: true,
    fillColor: AppColors.surface,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: AppColors.surfaceAlt),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: AppColors.surfaceAlt),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: AppColors.accent, width: 2),
    ),
  );
}

// —— Steps ——

class _WelcomeStep extends StatelessWidget {
  const _WelcomeStep();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Column(
        children: [
          const Spacer(),
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              gradient: AppColors.goldGradient,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withValues(alpha: 0.4),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Center(
              child: Text(
                'P',
                style: TextStyle(
                  fontSize: 56,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primaryDark,
                ),
              ),
            ),
          ),
          const SizedBox(height: 28),
          Text(
            AppStrings.appName,
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontSize: 40,
                  color: AppColors.primary,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            AppStrings.welcomeTitle,
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            AppStrings.welcomeSubtitle,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.accentSoft,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              AppStrings.welcomeTrial,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.accentDark,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () => context.read<OnboardingCubit>().start(),
              child: const Text(AppStrings.startBtn),
            ),
          ),
        ],
      ),
    );
  }
}

class _NameStep extends StatefulWidget {
  const _NameStep({required this.state});

  final OnboardingState state;

  @override
  State<_NameStep> createState() => _NameStepState();
}

class _NameStepState extends State<_NameStep> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.state.studentName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<OnboardingCubit>();
    return _StepScaffold(
      title: AppStrings.nameTitle,
      primaryEnabled: widget.state.canContinueName,
      onPrimary: cubit.submitName,
      child: TextField(
        controller: _controller,
        autofocus: true,
        textCapitalization: TextCapitalization.words,
        onChanged: cubit.setName,
        onSubmitted: (_) => cubit.submitName(),
        decoration: _fieldDecoration(AppStrings.nameHint),
        style: Theme.of(context).textTheme.titleLarge,
      ),
    );
  }
}

class _GradeStep extends StatelessWidget {
  const _GradeStep({required this.state});

  final OnboardingState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<OnboardingCubit>();
    return _StepScaffold(
      title: AppStrings.gradeTitle,
      subtitle: AppStrings.gradeSubtitle,
      onPrimary: cubit.submitGrade,
      child: GradeSelector(
        selected: state.grade,
        onChanged: cubit.setGrade,
      ),
    );
  }
}

class _SchoolStep extends StatelessWidget {
  const _SchoolStep({required this.state});

  final OnboardingState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<OnboardingCubit>();
    return _StepScaffold(
      title: AppStrings.schoolTitle,
      primaryEnabled: state.canContinueSchool,
      onPrimary: cubit.submitSchool,
      child: SchoolPicker(
        value: state.targetSchool,
        onChanged: cubit.setSchool,
      ),
    );
  }
}

class _PhoneStep extends StatefulWidget {
  const _PhoneStep({required this.state});

  final OnboardingState state;

  @override
  State<_PhoneStep> createState() => _PhoneStepState();
}

class _PhoneStepState extends State<_PhoneStep> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.state.parentPhoneLocal);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<OnboardingCubit>();
    return _StepScaffold(
      title: AppStrings.phoneTitle,
      subtitle: AppStrings.phoneSubtitle,
      primaryLabel: AppStrings.sendOtp,
      primaryEnabled: widget.state.canContinuePhone,
      isLoading: widget.state.isLoading,
      onPrimary: cubit.sendOtp,
      child: TextField(
        controller: _controller,
        autofocus: true,
        keyboardType: TextInputType.phone,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(9),
        ],
        onChanged: cubit.setPhoneLocal,
        decoration: _fieldDecoration(AppStrings.phoneHint).copyWith(
          prefixIcon: const Padding(
            padding: EdgeInsets.only(left: 16, right: 8),
            child: Center(
              widthFactor: 1,
              child: Text(
                AppStrings.phonePrefix,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ),
        style: Theme.of(context).textTheme.titleLarge,
      ),
    );
  }
}

class _OtpStep extends StatefulWidget {
  const _OtpStep({required this.state});

  final OnboardingState state;

  @override
  State<_OtpStep> createState() => _OtpStepState();
}

class _OtpStepState extends State<_OtpStep> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.state.otpCode);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<OnboardingCubit>();
    return _StepScaffold(
      title: AppStrings.otpTitle,
      subtitle: '${AppStrings.otpSubtitle}\n${widget.state.fullPhone}',
      primaryLabel: AppStrings.verifyOtp,
      primaryEnabled: widget.state.canContinueOtp,
      isLoading: widget.state.isLoading,
      onPrimary: cubit.verifyOtpAndFinish,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _controller,
            autofocus: true,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  letterSpacing: 12,
                ),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(6),
            ],
            onChanged: cubit.setOtp,
            onSubmitted: (_) => cubit.verifyOtpAndFinish(),
            decoration: _fieldDecoration(AppStrings.otpHint),
          ),
          const SizedBox(height: 12),
          if (kDebugMode && cubit.devOtpHint) ...[
            Text(
              AppStrings.otpDevHint,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textMuted,
                  ),
            ),
            const SizedBox(height: 8),
          ],
          TextButton(
            onPressed: widget.state.isLoading || widget.state.resendSecondsLeft > 0
                ? null
                : cubit.resendOtp,
            child: Text(
              widget.state.resendSecondsLeft > 0
                  ? AppStrings.otpResendWait.replaceAll(
                      '{n}',
                      '${widget.state.resendSecondsLeft}',
                    )
                  : AppStrings.otpResend,
            ),
          ),
        ],
      ),
    );
  }
}

class _DoneStep extends StatelessWidget {
  const _DoneStep({required this.user, required this.onCompleted});

  final UserModel user;
  final ValueChanged<UserModel> onCompleted;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      child: Column(
        children: [
          const Spacer(),
          Container(
            width: 96,
            height: 96,
            decoration: const BoxDecoration(
              color: AppColors.successSoft,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_rounded,
              size: 56,
              color: AppColors.success,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            AppStrings.finishTitle,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            '${user.studentName}, ${AppStrings.finishSubtitle}',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              children: [
                Text(
                  '${AppConstants.freeTrialDays} kun bepul',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.accent,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  '+10 🪙 welcome bonus · 🔥 streak 1',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textOnPrimary.withValues(alpha: 0.9),
                      ),
                ),
              ],
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () => onCompleted(user),
              child: const Text(AppStrings.goToApp),
            ),
          ),
        ],
      ),
    );
  }
}
