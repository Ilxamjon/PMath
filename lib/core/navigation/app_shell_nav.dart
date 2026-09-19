import 'package:flutter/foundation.dart';

/// MainShell tabini boshqa sahifalardan ochish (masalan, Skaner).
abstract final class AppShellNav {
  static final ValueNotifier<int?> pendingTab = ValueNotifier<int?>(null);

  static void openScanner() => pendingTab.value = 1;

  static void openMap() => pendingTab.value = 0;
}
