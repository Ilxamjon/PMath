import 'package:equatable/equatable.dart';

import '../../../../models/user_model.dart';

/// Onboarding qadamlari.
enum OnboardingStep {
  welcome,
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

  /// Welcome va done hisobga olinmagan progress (1..4).
  int get visibleProgress {
    return switch (step) {
      OnboardingStep.welcome => 0,
      OnboardingStep.name => 1,
      OnboardingStep.grade => 2,
      OnboardingStep.school => 3,
      OnboardingStep.phone => 4,
      OnboardingStep.otp => 5,
      OnboardingStep.done => 5,
    };
  }

  static const int totalVisibleSteps = 5;

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
      ];
}
