import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/socratic_bank.dart';

/// Sokratik savol chizmasi — CustomPaint + emoji zaxira (har doim ko‘rinadi).
class LessonVisualCard extends StatelessWidget {
  const LessonVisualCard({super.key, required this.step});

  final SocraticStep step;

  static String emojiFor(LessonVisualKind kind) => switch (kind) {
        LessonVisualKind.none => '📐',
        LessonVisualKind.angleAcute => '📐',
        LessonVisualKind.angleRight => '📐',
        LessonVisualKind.angleObtuse => '📐',
        LessonVisualKind.triangle => '🔺',
        LessonVisualKind.square => '⬜',
        LessonVisualKind.rectangle => '▭',
        LessonVisualKind.circle => '⭕',
        LessonVisualKind.shapesCompare => '🔺⬜⭕',
        LessonVisualKind.rectLabeled => '▭',
        LessonVisualKind.squareLabeled => '⬜',
        LessonVisualKind.gridArea => '▦',
      };

  @override
  Widget build(BuildContext context) {
    if (!step.hasVisual) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7E6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.accent, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'CHIZMA',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 11,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  step.captionUz ?? 'Chizmaga qarang',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                ),
              ),
              Text(emojiFor(step.visual), style: const TextStyle(fontSize: 22)),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.surfaceAlt),
            ),
            clipBehavior: Clip.antiAlias,
            child: CustomPaint(
              painter: _LessonVisualPainter(step),
              child: const SizedBox.expand(),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Yuqoridagi chizmaga qarab savolga javob bering',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

class _LessonVisualPainter extends CustomPainter {
  _LessonVisualPainter(this.step);

  final SocraticStep step;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final stroke = Paint()
      ..color = const Color(0xFF1E293B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;

    final fill = Paint()
      ..color = const Color(0xFFF59E0B).withValues(alpha: 0.25)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final cx = size.width / 2;
    final cy = size.height / 2;

    switch (step.visual) {
      case LessonVisualKind.none:
        break;
      case LessonVisualKind.angleAcute:
        _drawAngle(canvas, size, degrees: 45, stroke: stroke);
        break;
      case LessonVisualKind.angleRight:
        _drawAngle(canvas, size, degrees: 90, stroke: stroke, markRight: true);
        break;
      case LessonVisualKind.angleObtuse:
        _drawAngle(canvas, size, degrees: 125, stroke: stroke);
        break;
      case LessonVisualKind.triangle:
        final path = Path()
          ..moveTo(cx, cy - 70)
          ..lineTo(cx - 80, cy + 55)
          ..lineTo(cx + 80, cy + 55)
          ..close();
        canvas.drawPath(path, fill);
        canvas.drawPath(path, stroke);
        break;
      case LessonVisualKind.square:
        final r =
            Rect.fromCenter(center: Offset(cx, cy), width: 120, height: 120);
        canvas.drawRRect(RRect.fromRectXY(r, 4, 4), fill);
        canvas.drawRRect(RRect.fromRectXY(r, 4, 4), stroke);
        break;
      case LessonVisualKind.rectangle:
        final r =
            Rect.fromCenter(center: Offset(cx, cy), width: 160, height: 95);
        canvas.drawRRect(RRect.fromRectXY(r, 4, 4), fill);
        canvas.drawRRect(RRect.fromRectXY(r, 4, 4), stroke);
        break;
      case LessonVisualKind.circle:
        canvas.drawCircle(Offset(cx, cy), 60, fill);
        canvas.drawCircle(Offset(cx, cy), 60, stroke);
        break;
      case LessonVisualKind.shapesCompare:
        _drawMini(canvas, Offset(cx - 95, cy), 'tri', stroke, fill);
        _drawMini(canvas, Offset(cx, cy), 'sq', stroke, fill);
        _drawMini(canvas, Offset(cx + 95, cy), 'circ', stroke, fill);
        break;
      case LessonVisualKind.rectLabeled:
        final r =
            Rect.fromCenter(center: Offset(cx, cy - 6), width: 160, height: 95);
        canvas.drawRRect(RRect.fromRectXY(r, 4, 4), fill);
        canvas.drawRRect(RRect.fromRectXY(r, 4, 4), stroke);
        _label(canvas, Offset(cx, r.bottom + 20), step.labelA ?? 'a');
        _label(canvas, Offset(r.right + 18, cy - 6), step.labelB ?? 'b');
        break;
      case LessonVisualKind.squareLabeled:
        final r =
            Rect.fromCenter(center: Offset(cx, cy - 6), width: 120, height: 120);
        canvas.drawRRect(RRect.fromRectXY(r, 4, 4), fill);
        canvas.drawRRect(RRect.fromRectXY(r, 4, 4), stroke);
        _label(canvas, Offset(cx, r.bottom + 20), step.labelA ?? 'a');
        break;
      case LessonVisualKind.gridArea:
        _drawGrid(canvas, size, stroke, fill);
        break;
    }
  }

  void _drawAngle(
    Canvas canvas,
    Size size, {
    required double degrees,
    required Paint stroke,
    bool markRight = false,
  }) {
    final origin = Offset(size.width * 0.26, size.height * 0.75);
    final len = size.width * 0.58;
    final rad = degrees * math.pi / 180;
    final p1 = origin + Offset(len, 0);
    final p2 = origin + Offset(len * math.cos(rad), -len * math.sin(rad));

    canvas.drawLine(origin, p1, stroke);
    canvas.drawLine(origin, p2, stroke);

    final arc = Paint()
      ..color = const Color(0xFFF59E0B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..isAntiAlias = true;
    canvas.drawArc(
      Rect.fromCircle(center: origin, radius: 32),
      0,
      -rad,
      false,
      arc,
    );

    if (markRight) {
      final box = Path()
        ..moveTo(origin.dx + 22, origin.dy)
        ..lineTo(origin.dx + 22, origin.dy - 22)
        ..lineTo(origin.dx, origin.dy - 22);
      canvas.drawPath(box, stroke);
    }
    _label(canvas, Offset(origin.dx + 48, origin.dy - 42), '?');
  }

  void _drawMini(
    Canvas canvas,
    Offset c,
    String kind,
    Paint stroke,
    Paint fill,
  ) {
    switch (kind) {
      case 'tri':
        final p = Path()
          ..moveTo(c.dx, c.dy - 40)
          ..lineTo(c.dx - 38, c.dy + 30)
          ..lineTo(c.dx + 38, c.dy + 30)
          ..close();
        canvas.drawPath(p, fill);
        canvas.drawPath(p, stroke);
        break;
      case 'sq':
        final r = Rect.fromCenter(center: c, width: 70, height: 70);
        canvas.drawRect(r, fill);
        canvas.drawRect(r, stroke);
        break;
      default:
        canvas.drawCircle(c, 34, fill);
        canvas.drawCircle(c, 34, stroke);
        break;
    }
  }

  void _drawGrid(Canvas canvas, Size size, Paint stroke, Paint fill) {
    final left = size.width * 0.18;
    final top = size.height * 0.16;
    const cols = 4;
    const rows = 3;
    const cell = 32.0;
    final rect = Rect.fromLTWH(left, top, cols * cell, rows * cell);
    canvas.drawRect(rect, fill);
    final grid = Paint()
      ..color = stroke.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    for (var i = 0; i <= cols; i++) {
      final x = left + i * cell;
      canvas.drawLine(Offset(x, top), Offset(x, top + rows * cell), grid);
    }
    for (var j = 0; j <= rows; j++) {
      final y = top + j * cell;
      canvas.drawLine(Offset(left, y), Offset(left + cols * cell, y), grid);
    }
    _label(
      canvas,
      Offset(left + cols * cell / 2, top + rows * cell + 24),
      '12 katak',
    );
  }

  void _label(Canvas canvas, Offset at, String text) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Color(0xFF1E293B),
          fontSize: 18,
          fontWeight: FontWeight.w900,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, at - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant _LessonVisualPainter oldDelegate) =>
      oldDelegate.step != step;
}
