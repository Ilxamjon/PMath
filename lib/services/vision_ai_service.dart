import 'dart:convert';
import 'dart:io';

import 'package:image/image.dart' as img;

import '../models/homework_model.dart';
import '../models/vision_analysis_result.dart';
import 'supabase_gateway.dart';

/// 0.75 dan past ishonch avtomatik baholanmaydi.
const visionConfirmThreshold = 0.75;

bool mustConfirmSteps(VisionAnalysisResult result) =>
    result.confidence < visionConfirmThreshold;

/// Vision tahlili muvaffaqiyatsiz. Stub javob qaytarilmaydi.
class VisionAnalysisException implements Exception {
  const VisionAnalysisException(this.messageUz);

  final String messageUz;
}

/// Vision AI / OCR abstraksiyasi.
abstract class VisionAiService {
  Future<VisionAnalysisResult> analyzeNotebookPage({
    required String imagePath,
    required HomeworkModel homework,
  });
}

/// Debug dagi demo. Rasmni o‘qimaydi.
class StubVisionAiService implements VisionAiService {
  @override
  Future<VisionAnalysisResult> analyzeNotebookPage({
    required String imagePath,
    required HomeworkModel homework,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));

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

/// `[{index, text, latex?}]` sxemasi. Yaroqsiz bo‘lsa `null`.
List<String>? parseVisionSteps(Object? raw) {
  if (raw is! List || raw.isEmpty || raw.length > 12) return null;
  final steps = <String>[];
  final seen = <int>{};
  for (var i = 0; i < raw.length; i++) {
    final item = raw[i];
    if (item is! Map) return null;
    final index = item['index'];
    final text = item['text'];
    if (index is! int || index != i + 1 || !seen.add(index)) return null;
    if (text is! String || text.trim().isEmpty || text.trim().length > 300) {
      return null;
    }
    final latex = item['latex'];
    if (latex != null && (latex is! String || latex.length > 300)) return null;
    final latexText = latex is String ? latex.trim() : '';
    steps.add(
      latexText.isEmpty ? text.trim() : '${text.trim()}\n$latexText',
    );
  }
  return steps;
}

/// Edge Function javobini tekshiradi.
VisionAnalysisResult? parseVisionResponse({
  required Map<String, dynamic>? json,
  required String imagePath,
}) {
  if (json == null) return null;
  final confidence = json['confidence'];
  if (confidence is! num) return null;
  final value = confidence.toDouble();
  if (value < 0 || value > 1) return null;
  final steps = parseVisionSteps(json['steps']);
  if (steps == null) return null;
  final rawText = json['rawText'];
  if (rawText != null && (rawText is! String || rawText.length > 2000)) {
    return null;
  }
  final modelName = json['modelName'];
  if (modelName != null && modelName is! String) return null;
  return VisionAnalysisResult(
    imagePath: imagePath,
    rawText: rawText is String && rawText.trim().isNotEmpty
        ? rawText.trim()
        : steps.join('\n'),
    steps: steps,
    confidence: value,
    modelName: modelName is String && modelName.isNotEmpty
        ? modelName
        : 'gemini-2.0-flash',
  );
}

typedef ImageEncoder = Future<List<int>> Function(String path);
typedef FileDeleter = Future<void> Function(String path);

/// Rasmni siqib `vision-analyze` ga yuboradi. Yaroqsiz JSON da 1 marta qayta urinadi.
class RemoteVisionAiService implements VisionAiService {
  RemoteVisionAiService({
    required EdgeInvoker gateway,
    ImageEncoder? encode,
    FileDeleter? deleteFile,
  })  : _gateway = gateway,
        _encode = encode ?? encodeNotebookJpeg,
        _deleteFile = deleteFile ?? _deleteIfExists;

  final EdgeInvoker _gateway;
  final ImageEncoder _encode;
  final FileDeleter _deleteFile;

  static const _invalid =
      'Daftar o‘qilmadi. Rasmni yaqinroq va yorug‘roq qilib qayta oling.';
  static const _network =
      'Tahlil yuborilmadi. Internetni tekshirib, qayta urinib ko‘ring.';

  @override
  Future<VisionAnalysisResult> analyzeNotebookPage({
    required String imagePath,
    required HomeworkModel homework,
  }) async {
    try {
      final jpeg = await _encode(imagePath);
      final body = {
        'imageBase64': base64Encode(jpeg),
        'mimeType': 'image/jpeg',
        'titleUz': homework.titleUz.trim().isEmpty
            ? 'Vazifa'
            : homework.titleUz.trim(),
      };
      final first = await _request(body, imagePath);
      if (first != null) return first;
      final second = await _request(body, imagePath);
      if (second != null) return second;
      throw const VisionAnalysisException(_invalid);
    } on VisionAnalysisException {
      rethrow;
    } catch (_) {
      throw const VisionAnalysisException(_network);
    } finally {
      try {
        await _deleteFile(imagePath);
      } catch (_) {}
    }
  }

  Future<VisionAnalysisResult?> _request(
    Map<String, dynamic> body,
    String imagePath,
  ) async {
    final result = await _gateway.invoke(
      'vision-analyze',
      body,
      timeout: const Duration(seconds: 25),
    );
    if (result == null) {
      throw const VisionAnalysisException(_network);
    }
    if (result.statusCode == 422) return null;
    if (result.statusCode != 200) {
      throw const VisionAnalysisException(_network);
    }
    return parseVisionResponse(json: result.json, imagePath: '');
  }
}

/// Eng uzun tomoni 1600px, JPEG sifati 80.
Future<List<int>> encodeNotebookJpeg(String path) async {
  final file = File(path);
  if (!await file.exists()) {
    throw const VisionAnalysisException(
      'Rasm topilmadi. Qayta olib ko‘ring.',
    );
  }
  final decoded = img.decodeImage(await file.readAsBytes());
  if (decoded == null) {
    throw const VisionAnalysisException(
      'Rasm o‘qilmadi. JPG yoki PNG yuboring.',
    );
  }
  var picture = decoded;
  if (picture.width > 1600 || picture.height > 1600) {
    picture = picture.width >= picture.height
        ? img.copyResize(picture, width: 1600)
        : img.copyResize(picture, height: 1600);
  }
  return img.encodeJpg(picture, quality: 80);
}

Future<void> _deleteIfExists(String path) async {
  final file = File(path);
  if (await file.exists()) await file.delete();
}

/// Release da stub yo‘q. Debug da bulut tayyor bo‘lmasa stub qoladi.
VisionAiService createVisionService({
  required bool allowStub,
  required bool cloudReady,
  required EdgeInvoker gateway,
}) {
  if (allowStub && !cloudReady) return StubVisionAiService();
  return RemoteVisionAiService(gateway: gateway);
}
