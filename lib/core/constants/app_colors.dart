/// PMath brend ranglar palitrasi.
///
/// Asosiy: Deep Royal Blue (#1E293B)
/// Accent: Gold (#F59E0B) — mukofot va streak
/// Success: Emerald Green (#10B981)
library;

import 'package:flutter/material.dart';

abstract final class AppColors {
  // —— Asosiy brend ——
  static const Color primary = Color(0xFF1E293B);
  static const Color primaryLight = Color(0xFF334155);
  static const Color primaryDark = Color(0xFF0F172A);

  // —— Accent / Glow ——
  static const Color accent = Color(0xFFF59E0B);
  static const Color accentSoft = Color(0xFFFEF3C7);
  static const Color accentDark = Color(0xFFD97706);

  // —— Holat ranglari ——
  static const Color success = Color(0xFF10B981);
  static const Color successSoft = Color(0xFFD1FAE5);
  static const Color error = Color(0xFFEF4444);
  static const Color errorSoft = Color(0xFFFEE2E2);
  static const Color warning = Color(0xFFF97316);
  static const Color info = Color(0xFF3B82F6);

  // —— Fon va sirt ——
  static const Color background = Color(0xFFF1F5F9);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceAlt = Color(0xFFE2E8F0);

  // —— Matn ——
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textMuted = Color(0xFF94A3B8);

  // —— Roadmap node holatlari ——
  static const Color nodeCompleted = success;
  static const Color nodeActive = accent;
  static const Color nodeLocked = Color(0xFFCBD5E1);

  // —— Gradientlar ——
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryDark, primary, primaryLight],
  );

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFBBF24), accent, accentDark],
  );

  static const LinearGradient mapBackgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFE0F2FE), Color(0xFFF1F5F9), Color(0xFFECFDF5)],
  );
}
