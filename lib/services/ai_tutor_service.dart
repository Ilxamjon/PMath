import '../core/utils/uz_text.dart';
import '../models/lesson_model.dart';
import 'supabase_gateway.dart';

/// Bulutdagi Sokratik ustoz (`ai-coach`) va lokal fallback.
///
/// Gemini kaliti ilovada saqlanmaydi. Supabase sessiyasi yo‘q yoki
/// funksiya xato bersa, lokal qoidalar ishlaydi.
class AiTutorService {
  AiTutorService({EdgeInvoker? gateway}) : _gateway = gateway;

  final EdgeInvoker? _gateway;

  /// Bulutdan kelgan javob shundan uzun bo‘lsa — rad etiladi.
  static const _maxReplyLength = 600;

  /// "Javob: 42" kabi yakuniy javobni oshkor qiladigan shablon.
  static final RegExp _finalAnswerLeak = RegExp(
    r'(javob|natija|yechim)\s*[:=\-]\s*[-+]?\d',
    caseSensitive: false,
  );

  bool get isCloudEnabled => _gateway?.isReady ?? false;

  String get providerLabel =>
      isCloudEnabled ? 'PMath bulut AI' : 'PMath lokal AI (offline)';

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
      final cloud = await _cloudCoach(
        heard: heard,
        lesson: lesson,
        currentPrompt: currentPrompt,
      );
      if (cloud != null && _isSafeReply(cloud)) return cloud.trim();
    }

    return _localCoach(
      heard: heard,
      lesson: lesson,
      currentPrompt: currentPrompt,
    );
  }

  /// Bulut javobini tekshirish: bo‘sh emas, juda uzun emas, yakuniy javobni
  /// oshkor qilmaydi. Aks holda lokal Sokratik javobga o‘tiladi.
  bool _isSafeReply(String reply) {
    final text = reply.trim();
    if (text.isEmpty || text.length > _maxReplyLength) return false;
    if (_finalAnswerLeak.hasMatch(text)) return false;
    return true;
  }

  Future<String?> _cloudCoach({
    required String heard,
    required LessonModel lesson,
    String? currentPrompt,
  }) async {
    final gateway = _gateway;
    if (gateway == null) return null;

    final result = await gateway.invoke(
      'ai-coach',
      {
        'studentText': sanitizeForPrompt(heard),
        'lessonTitle': sanitizeForPrompt(lesson.titleUz, maxLength: 120),
        'topic': sanitizeForPrompt(lesson.topic, maxLength: 120),
        if (currentPrompt != null && currentPrompt.trim().isNotEmpty)
          'currentPrompt': sanitizeForPrompt(currentPrompt),
      },
      timeout: const Duration(seconds: 12),
    );
    if (result == null || result.statusCode != 200) return null;
    final reply = result.json?['reply'];
    if (reply is! String) return null;
    return reply;
  }

  String _localCoach({
    required String heard,
    required LessonModel lesson,
    String? currentPrompt,
  }) {
    final t = normalizeUz(heard);
    final title = lesson.titleUz;
    final topic = lesson.topic;
    final isCompare = normalizeUz(title).contains('taqqos') ||
        normalizeUz(topic).contains('taqqos');

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

  /// Kalit so‘zlar ham normallashtiriladi, shuning uchun apostrof turi
  /// (`‘`, `ʻ`, `’`, `'`) taqqoslashga ta’sir qilmaydi.
  bool _has(String text, List<String> keys) {
    for (final k in keys) {
      if (text.contains(normalizeUz(k))) return true;
    }
    return false;
  }
}
