import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../models/user_model.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/storage_service.dart';
import 'onboarding_state.dart';

/// Onboarding oqimi: profil yig‘ish → SMS OTP → trial boshlash → saqlash.
class OnboardingCubit extends Cubit<OnboardingState> {
  OnboardingCubit({
    required AuthService authService,
    required StorageService storageService,
    Uuid? uuid,
  })  : _auth = authService,
        _storage = storageService,
        _uuid = uuid ?? const Uuid(),
        super(const OnboardingState());

  final AuthService _auth;
  final StorageService _storage;
  final Uuid _uuid;

  void start() => emit(state.copyWith(
        step: OnboardingStep.name,
        clearError: true,
      ));

  void goBack() {
    final prev = switch (state.step) {
      OnboardingStep.name => OnboardingStep.welcome,
      OnboardingStep.grade => OnboardingStep.name,
      OnboardingStep.school => OnboardingStep.grade,
      OnboardingStep.phone => OnboardingStep.school,
      OnboardingStep.otp => OnboardingStep.phone,
      _ => state.step,
    };
    emit(state.copyWith(step: prev, clearError: true));
  }

  void setName(String value) =>
      emit(state.copyWith(studentName: value, clearError: true));

  void setGrade(StudentGrade grade) =>
      emit(state.copyWith(grade: grade, clearError: true));

  void setSchool(String value) =>
      emit(state.copyWith(targetSchool: value, clearError: true));

  void setPhoneLocal(String value) {
    // Faqat raqam, max 9.
    final digits = value.replaceAll(RegExp(r'\D'), '');
    final clipped = digits.length > 9 ? digits.substring(0, 9) : digits;
    emit(state.copyWith(parentPhoneLocal: clipped, clearError: true));
  }

  void setOtp(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    final clipped = digits.length > 6 ? digits.substring(0, 6) : digits;
    emit(state.copyWith(otpCode: clipped, clearError: true));
  }

  void submitName() {
    if (!state.canContinueName) {
      emit(state.copyWith(errorMessage: AppStrings.nameError));
      return;
    }
    emit(state.copyWith(step: OnboardingStep.grade, clearError: true));
  }

  void submitGrade() =>
      emit(state.copyWith(step: OnboardingStep.school, clearError: true));

  void submitSchool() {
    if (!state.canContinueSchool) {
      emit(state.copyWith(errorMessage: AppStrings.schoolError));
      return;
    }
    emit(state.copyWith(step: OnboardingStep.phone, clearError: true));
  }

  Future<void> sendOtp() async {
    if (!state.canContinuePhone) {
      emit(state.copyWith(errorMessage: AppStrings.phoneError));
      return;
    }

    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      await _auth.sendOtp(state.fullPhone);
      emit(state.copyWith(
        isLoading: false,
        otpSent: true,
        step: OnboardingStep.otp,
        otpCode: '',
      ));
    } catch (_) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: AppStrings.somethingWrong,
      ));
    }
  }

  Future<void> resendOtp() async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      await _auth.sendOtp(state.fullPhone);
      emit(state.copyWith(isLoading: false, otpSent: true));
    } catch (_) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: AppStrings.somethingWrong,
      ));
    }
  }

  Future<void> verifyOtpAndFinish() async {
    if (!state.canContinueOtp) {
      emit(state.copyWith(errorMessage: AppStrings.otpError));
      return;
    }

    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final ok = await _auth.verifyOtp(state.fullPhone, state.otpCode);
      if (!ok) {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: AppStrings.otpError,
        ));
        return;
      }

      final now = DateTime.now();
      final user = UserModel(
        id: _auth.currentUserId ?? _uuid.v4(),
        studentName: state.studentName.trim(),
        grade: state.grade,
        targetSchool: state.targetSchool.trim(),
        parentPhone: state.fullPhone,
        createdAt: now,
        lastActiveDate: now,
        subscriptionStatus: SubscriptionStatus.trial,
        // 7 kunlik bepul sinov.
        subscriptionExpiresAt:
            now.add(const Duration(days: AppConstants.freeTrialDays)),
        coins: 10, // Welcome bonus
        level: 1,
        streakDays: 1,
      );

      await _storage.completeOnboarding(user);

      emit(state.copyWith(
        isLoading: false,
        step: OnboardingStep.done,
        completedUser: user,
      ));
    } catch (_) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: AppStrings.somethingWrong,
      ));
    }
  }
}
