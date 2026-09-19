import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../domain/proctoring_guard.dart';

/// Kichik front-kamera PIP (nazorat faol bo‘lganda).
class ProctoringCameraPip extends StatelessWidget {
  const ProctoringCameraPip({
    super.key,
    required this.guard,
    this.onLongPressSimulate,
  });

  final ProctoringGuard guard;
  final VoidCallback? onLongPressSimulate;

  @override
  Widget build(BuildContext context) {
    final cam = guard.cameraController;
    final paused = guard.isPaused;

    return GestureDetector(
      onLongPress: onLongPressSimulate,
      child: Container(
        width: 88,
        height: 118,
        decoration: BoxDecoration(
          color: AppColors.primaryDark,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: paused ? AppColors.error : AppColors.success,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (cam != null)
              FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: cam.value.previewSize?.height ?? 100,
                  height: cam.value.previewSize?.width ?? 100,
                  child: CameraPreview(cam),
                ),
              )
            else
              const ColoredBox(
                color: AppColors.primary,
                child: Center(
                  child: Icon(
                    Icons.videocam_off,
                    color: AppColors.accent,
                    size: 28,
                  ),
                ),
              ),
            Positioned(
              left: 4,
              right: 4,
              bottom: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  paused
                      ? AppStrings.proctoringPaused
                      : AppStrings.proctoringLive,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
