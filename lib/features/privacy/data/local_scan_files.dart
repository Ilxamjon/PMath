import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Skaner vaqtinchalik papkasidagi daftar rasmlari.
Future<void> deleteNotebookScans() async {
  final dir = await getTemporaryDirectory();
  final scans = Directory(p.join(dir.path, 'scans'));
  if (await scans.exists()) {
    await scans.delete(recursive: true);
  }
}
