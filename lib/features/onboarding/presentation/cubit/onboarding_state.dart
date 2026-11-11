import 'package:equatable/equatable.dart';

import '../../../../models/user_model.dart';

/// Onboarding qadamlari.
enum OnboardingStep {
  welcome,
  consent,
  name,
  grade,
  school,
  phone,
  otp,
  done,
}

class OnboardingState extends Equatable {
  const OnboardingState({
    this.step = OnboardingStep.welcome,
    this.studentName = '',
    this.grade = StudentGrade.grade4,
    this.targetSchool = '',
    this.parentPhoneLocal = '',
    this.otpCode = '',
    this.isLoading = false,
    this.errorMessage,
    this.completedUser,
    this.otpSent = false,
    this.resendSecondsLeft = 0,
    this.parentConsentGranted = false,
    this.parentConsentAt,
  });

  final OnboardingStep step;
  final String studentName;
  final StudentGrade grade;
  final String targetSchool;

  /// Faqat 9 raqam: 901234567 (prefix +998 alohida).
  final String parentPhoneLocal;
  final String otpCode;
  final bool isLoading;
  final String? errorMessage;
  final UserModel? completedUser;
  final bool otpSent;
  final int resendSecondsLeft;
  final bool parentConsentGranted;
  final DateTime? parentConsentAt;

  String get fullPhone {
    final digits = parentPhoneLocal.replaceAll(RegExp(r'\D'), '');
    return '+998$digits';
  }

  bool get canContinueName => studentName.trim().length >= 2;
  bool get canContinueSchool => targetSchool.trim().length >= 3;
  bool get canContinuePhone {
    final digits = parentPhoneLocal.replaceAll(RegExp(r'\D'), '');
    return digits.length == 9 && digits.startsWith(RegExp(r'[3-9]'));
  }

  bool get canContinueOtp => otpCode.trim().length >= 4;

  int get stepIndex => OnboardingStep.values.indexOf(step);

  /// Welcome va done hisobga olinmagan progress.
  int get visibleProgress {
    return switch (step) {
      OnboardingStep.welcome => 0,
      OnboardingStep.consent => 1,
      OnboardingStep.name => 2,
      OnboardingStep.grade => 3,
      OnboardingStep.school => 4,
      OnboardingStep.phone => 5,
      OnboardingStep.otp => 6,
      OnboardingStep.done => 6,
    };
  }

  static const int totalVisibleSteps = 6;

  OnboardingState copyWith({
    OnboardingStep? step,
    String? studentName,
    StudentGrade? grade,
    String? targetSchool,
    String? parentPhoneLocal,
    String? otpCode,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    UserModel? completedUser,
    bool? otpSent,
    int? resendSecondsLeft,
    bool? parentConsentGranted,
    DateTime? parentConsentAt,
  }) {
    return OnboardingState(
      step: step ?? this.step,
      studentName: studentName ?? this.studentName,
      grade: grade ?? this.grade,
      targetSchool: targetSchool ?? this.targetSchool,
      parentPhoneLocal: parentPhoneLocal ?? this.parentPhoneLocal,
      otpCode: otpCode ?? this.otpCode,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      completedUser: completedUser ?? this.completedUser,
      otpSent: otpSent ?? this.otpSent,
      resendSecondsLeft: resendSecondsLeft ?? this.resendSecondsLeft,
      parentConsentGranted: parentConsentGranted ?? this.parentConsentGranted,
      parentConsentAt: parentConsentAt ?? this.parentConsentAt,
    );
  }

  @override
  List<Object?> get props => [
        step,
        studentName,
        grade,
        targetSchool,
        parentPhoneLocal,
        otpCode,
        isLoading,
        errorMessage,
        completedUser,
        otpSent,
        resendSecondsLeft,
        parentConsentGranted,
        parentConsentAt,
      ];
}
