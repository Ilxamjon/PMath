import 'dart:convert';
import 'dart:io';

import '../models/homework_model.dart';
import '../models/vision_analysis_result.dart';
import 'supabase_gateway.dart';

/// Vision AI / OCR abstraksiyasi.
///
/// Production: OpenAI Vision / Google Document AI / custom edge function.
abstract class VisionAiService {
  Future<VisionAnalysisResult> analyzeNotebookPage({
    required String imagePath,
    required HomeworkModel homework,
  });
}

/// Lokal stub — rasmni "o‘qib" qadamlarni JSON qilib qaytaradi.
///
/// Haqiqiy OCR o‘rniga masala matnidan namuna qadamlar generatsiya qiladi.
class StubVisionAiService implements VisionAiService {
  @override
  Future<VisionAnalysisResult> analyzeNotebookPage({
    required String imagePath,
    required HomeworkModel homework,
  }) async {
    // "Model" ishlayotgandek kechikish.
    await Future<void>.delayed(const Duration(milliseconds: 1200));

    final steps = _extractSteps(homework);
    final raw = steps.asMap().entries.map((e) {
      return 'Qadam ${e.key + 1}: ${e.value}';
    }).join('\n');

    return VisionAnalysisResult(
      imagePath: imagePath,
      rawText: raw,
      steps: steps,
      confidence: 0.86,
      modelName: 'pmath-vision-stub',
    );
  }

  List<String> _extractSteps(HomeworkModel homework) {
    final latex = homework.latexFormula ?? '';
    final statement = homework.problemStatement ?? homework.titleUz;
    final text = '$statement $latex';
    final nums = RegExp(r'\d+')
        .allMatches(text)
        .map((m) => int.tryParse(m.group(0)!) ?? 0)
        .where((n) => n > 0)
        .toList();

    if (latex.contains(r'\times') || statement.contains('×')) {
      final a = nums.isNotEmpty ? nums[0] : 24;
      final b = nums.length > 1 ? nums[1] : 15;
      // Oxirgi qadamda ataylab xato — baholash demosi uchun.
      return [
        'Berilgan: $a × $b',
        '${a}ni $b marta qo‘shish',
        'Oraliq: ${a * (b - 1)}',
        'Javob: ${a * b + 3}',
      ];
    }
    if (latex.contains('P =') || statement.toLowerCase().contains('perimetr')) {
      return const [
        'P = 2(a + b)',
        'P = 2(12 + 8)',
        'P = 2 · 20',
        'P = 40',
      ];
    }
    if (statement.contains('ketma-ketlik') || latex.contains(',')) {
      return const [
        'Har bir had ×2',
        '8 × 2 = 16',
        '16 × 2 = 32',
        'Keyingi: 32',
      ];
    }
    return [
      'Masalani o‘qidim: ${statement.length > 40 ? '${statement.substring(0, 40)}…' : statement}',
      'Berilganlarni ajratdim',
      'Yechim qadamlarini yozdim',
      'Javobni tekshirdim',
    ];
  }
}

/// `vision-analyze` Edge Function. Xato yoki offline bo‘lsa stub ishlaydi.
class EdgeVisionAiService implements VisionAiService {
  EdgeVisionAiService({
    required EdgeInvoker gateway,
    VisionAiService? fallback,
  })  : _gateway = gateway,
        _fallback = fallback ?? StubVisionAiService();

  final EdgeInvoker _gateway;
  final VisionAiService _fallback;

  static const _maxBytes = 1000000;

  @override
  Future<VisionAnalysisResult> analyzeNotebookPage({
    required String imagePath,
    required HomeworkModel homework,
  }) async {
    if (!_gateway.isReady) {
      return _fallback.analyzeNotebookPage(
        imagePath: imagePath,
        homework: homework,
      );
    }

    try {
      final mime = _mime(imagePath);
      final file = File(imagePath);
      if (mime == null || !await file.exists()) {
        return await _fallback.analyzeNotebookPage(
          imagePath: imagePath,
          homework: homework,
        );
      }
      final bytes = await file.readAsBytes();
      if (bytes.isEmpty || bytes.length > _maxBytes) {
        return await _fallback.analyzeNotebookPage(
          imagePath: imagePath,
          homework: homework,
        );
      }

      final result = await _gateway.invoke(
        'vision-analyze',
        {
          'imageBase64': base64Encode(bytes),
          'mimeType': mime,
          'titleUz': homework.titleUz,
        },
        timeout: const Duration(seconds: 25),
      );
      final json = result?.json;
      if (result == null || result.statusCode != 200 || json == null) {
        return await _fallback.analyzeNotebookPage(
          imagePath: imagePath,
          homework: homework,
        );
      }

      final steps = (json['steps'] as List<dynamic>?)
              ?.whereType<String>()
              .where((step) => step.trim().isNotEmpty)
              .toList() ??
          const <String>[];
      if (steps.isEmpty) {
        return await _fallback.analyzeNotebookPage(
          imagePath: imagePath,
          homework: homework,
        );
      }

      return VisionAnalysisResult(
        imagePath: imagePath,
        rawText: json['rawText'] as String? ?? steps.join('\n'),
        steps: steps,
        confidence: (json['confidence'] as num?)?.toDouble() ?? 0.5,
        modelName: json['modelName'] as String? ?? 'gemini-2.0-flash',
      );
    } catch (_) {
      return await _fallback.analyzeNotebookPage(
        imagePath: imagePath,
        homework: homework,
      );
    }
  }

  String? _mime(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return 'image/jpeg';
    return null;
  }
}
