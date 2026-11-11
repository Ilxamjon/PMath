import '../../../core/storage/local_snapshot.dart';
import '../../../models/diagnostic_result_model.dart';
import '../../../models/user_model.dart';
import '../domain/user_repository.dart';

class DriftUserRepository implements UserRepository {
  DriftUserRepository(this._store);

  final LocalSnapshot _store;

  @override
  UserModel? getUser() => _store.user;

  @override
  Future<void> saveUser(UserModel user) => _store.saveUser(user);

  @override
  Future<void> clearUser() => _store.clearUser();

  @override
  bool get isOnboardingDone => _store.onboardingDone;

  @override
  Future<void> setOnboardingDone(bool value) => _store.setOnboardingDone(value);

  @override
  Future<void> completeOnboarding(UserModel user) async {
    await saveUser(user);
    await setOnboardingDone(true);
  }

  @override
  bool get isDiagnosticDone => _store.diagnosticDone;

  @override
  Future<void> setDiagnosticDone(bool value) =>
      _store.setDiagnosticDone(value);

  @override
  Future<void> saveDiagnosticResult(DiagnosticResultModel result) =>
      _store.saveDiagnostic(result);

  @override
  DiagnosticResultModel? getDiagnosticResult() => _store.diagnostic;

  @override
  Future<int> recordCheatingWarning() async {
    final user = getUser();
    if (user == null) return 0;
    final next = user.cheatingWarnings + 1;
    await saveUser(user.copyWith(cheatingWarnings: next));
    return next;
  }
}
