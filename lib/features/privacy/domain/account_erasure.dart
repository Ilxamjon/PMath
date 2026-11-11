import '../../../services/auth_service.dart';
import '../../../services/storage_service.dart';
import '../../../services/supabase_gateway.dart';
import '../data/local_scan_files.dart';

enum ErasureOutcome { deleted, localOnly, serverFailed }

/// Lokal bazani, daftar rasmlarini va server hisobini o‘chiradi.
class AccountErasure {
  AccountErasure({
    required StorageService storage,
    required AuthService auth,
    required EdgeInvoker gateway,
    Future<void> Function()? deleteFiles,
  })  : _storage = storage,
        _auth = auth,
        _gateway = gateway,
        _deleteFiles = deleteFiles ?? deleteNotebookScans;

  final StorageService _storage;
  final AuthService _auth;
  final EdgeInvoker _gateway;
  final Future<void> Function() _deleteFiles;

  Future<ErasureOutcome> erase() async {
    if (_gateway.isReady) {
      final result = await _gateway.invoke(
        'delete-account',
        <String, dynamic>{},
      );
      final ok = result != null &&
          result.statusCode == 200 &&
          result.json?['ok'] == true;
      if (!ok) return ErasureOutcome.serverFailed;
    }

    try {
      await _auth.signOut();
    } catch (_) {}

    try {
      await _deleteFiles();
    } catch (_) {}

    await _storage.resetAll();
    return _gateway.isReady ? ErasureOutcome.deleted : ErasureOutcome.localOnly;
  }
}
