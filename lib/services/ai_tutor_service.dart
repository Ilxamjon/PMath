import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/lesson_model.dart';

/// Cloud AI (Gemini) + lokal fallback uchun yagona tutor.
///
/// Kalit: `--dart-define=GEMINI_API_KEY=...`
/// Kalit bo‘lmasa — lokal Sokratik qoidalar ishlaydi (offline).
class AiTutorService {
  AiTutorService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const apiKey = String.fromEnvironment('GEMINI_API_KEY');

  bool get isCloudEnabled => apiKey.isNotEmpty;

  String get providerLabel =>
      isCloudEnabled ? 'Gemini (cloud)' : 'PMath lokal AI (offline)';

  /// Ovozli / matnli savolga o‘zbekcha Sokratik javob.
  Future<String> coachReply({
    required String studentText,
    required LessonModel lesson,
    String? currentPrompt,
  }) async {
    final heard = studentText.trim();
    if (heard.isEmpty) {
      return 'Eshitmadim. Mikrofonni bosib, savolingizni aniqroq ayting.';
    }

    if (isCloudEnabled) {
      final cloud = await _geminiCoach(
        heard: heard,
        lesson: lesson,
        currentPrompt: currentPrompt,
      );
      if (cloud != null && cloud.trim().isNotEmpty) return cloud.trim();
    }

    return _localCoach(
      heard: heard,
      lesson: lesson,
      currentPrompt: currentPrompt,
    );
  }

  Future<String?> _geminiCoach({
    required String heard,
    required LessonModel lesson,
    String? currentPrompt,
  }) async {
    try {
      final uri = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/'
        'gemini-2.0-flash:generateContent?key=$apiKey',
      );
      final prompt = '''
Sen PMath — Prezident maktabi uchun matematika ustozisan.
Til: faqat o‘zbek (lotin).
Qoida: to‘g‘ridan-to‘g‘ri yakuniy javobni BERMA. Sokratik yo‘naltir.
Qisqa (2–4 gap), bolalarga mos, rag‘batlantiruvchi.
Dars: ${lesson.titleUz} (${lesson.topic}).
Hozirgi Sokratik savol: ${currentPrompt ?? 'yo‘q'}.
O‘quvchi dedi: "$heard"
''';

      final res = await _client
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'contents': [
                {
                  'parts': [
                    {'text': prompt},
                  ],
                },
              ],
              'generationConfig': {
                'temperature': 0.7,
                'maxOutputTokens': 220,
              },
            }),
          )
          .timeout(const Duration(seconds: 12));

      if (res.statusCode < 200 || res.statusCode >= 300) return null;
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final candidates = data['candidates'] as List<dynamic>?;
      if (candidates == null || candidates.isEmpty) return null;
      final content = candidates.first['content'] as Map<String, dynamic>?;
      final parts = content?['parts'] as List<dynamic>?;
      if (parts == null || parts.isEmpty) return null;
      return parts.first['text'] as String?;
    } catch (_) {
      return null;
    }
  }

  String _localCoach({
    required String heard,
    required LessonModel lesson,
    String? currentPrompt,
  }) {
    final t = heard.toLowerCase().replaceAll('ʻ', "'").replaceAll('’', "'");
    final title = lesson.titleUz;
    final topic = lesson.topic;
    final isCompare = title.toLowerCase().contains('taqqos') ||
        topic.toLowerCase().contains('taqqos');

    if (_has(t, ['yordam', 'tushunmadim', 'bilmayman', 'qiyin'])) {
      if (isCompare) {
        return 'Yordam: avval nimalar taqqoslanayotganini ayting, '
            'keyin belgini tanlang (uzunlik, og‘irlik, son). '
            'Oxirida >, < yoki = deb xulosa yozing. '
            '${currentPrompt ?? ''}';
      }
      return 'Yaxshi! "$title" da avval nima berilganini, keyin nima '
          'so‘ralganini ajrating. Birinchi kichik qadam nima?';
    }

    if (_has(t, ['qanday', 'formula', 'qoida'])) {
      return 'Formulani men aytmayman. O‘zingiz: berilganlar → so‘ralgan → '
          'birinchi amal. $topic bo‘yicha birinchi qadamingiz?';
    }

    if (_has(t, ['javob', 'to‘g‘ri', 'togri', 'tekshir'])) {
      return 'Yakuniy javobni aytmayman. Teskari amal yoki boshqa usul bilan '
          'tekshiring. Qaysi qadamda shubhangiz bor?';
    }

    if (_has(t, ['taqqos', 'kattaroq', 'kichik', 'ko‘proq', 'kamroq'])) {
      return 'Taqqoslashda 3 qadam: 1) nimalar? 2) qaysi belgi? '
          '3) birliklar bir xilmi? Keyin xulosa.';
    }

    if (_has(t, ['misol', 'namuna', 'ko‘rsat', 'korsat'])) {
      return 'Kichikroq sonlar bilan o‘xshash misol tuzing. '
          'Shu usul "$title" ga ham ishlaydi. Sizning misolingiz?';
    }

    if (_has(t, ['takrorla', 'qayta', 'yana ayt', 'eshitmadim'])) {
      return currentPrompt != null && currentPrompt.isNotEmpty
          ? 'Albatta. Hozirgi savol: $currentPrompt'
          : 'Darsdagi savolni qayta tinglash uchun ovoz tugmasini bosing.';
    }

    return 'Siz dedingiz: «$heard». Yaxshi fikr! Endi buni "$title" '
        'masalasiga bog‘lang. Keyingi kichik qadam nima?';
  }

  bool _has(String text, List<String> keys) {
    for (final k in keys) {
      if (text.contains(k)) return true;
    }
    return false;
  }
}
