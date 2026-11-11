import '../../../models/diagnostic_result_model.dart';
import '../../../models/user_model.dart';

/// O‘quvchi profili va diagnostika bayroqlari.
abstract class UserRepository {
  UserModel? getUser();

  Future<void> saveUser(UserModel user);

  Future<void> clearUser();

  bool get isOnboardingDone;

  Future<void> setOnboardingDone(bool value);

  Future<void> completeOnboarding(UserModel user);

  bool get isDiagnosticDone;

  Future<void> setDiagnosticDone(bool value);

  Future<void> saveDiagnosticResult(DiagnosticResultModel result);

  DiagnosticResultModel? getDiagnosticResult();

  /// Nazorat ogohlantirishi: +1 va yangilangan son.
  Future<int> recordCheatingWarning();
}
