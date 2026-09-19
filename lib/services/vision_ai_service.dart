import '../models/homework_model.dart';
import '../models/vision_analysis_result.dart';

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
        '${a}ni ${b} marta qo‘shish',
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
