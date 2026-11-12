import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Text-to-Speech abstraksiyasi (faqat o‘zbekcha).
abstract class TtsService {
  Future<void> init();
  Future<void> speak(String text);
  Future<void> stop();
  Future<void> dispose();
  bool get isSpeaking;
  Stream<bool> get speakingStream;
  String get activeLocale;
}

/// O‘zbek lotin ovozi. Rus va turkcha o‘qish aktsent beradi, shuning uchun tanlanmaydi.
String pickSpeechLocale(Iterable<String> available) {
  final list = available.toList();
  const preferred = ['uz-UZ', 'uz_UZ', 'uz', 'uz-Latn-UZ', 'uz-Latn'];
  for (final want in preferred) {
    for (final item in list) {
      final norm = item.replaceAll('_', '-').toLowerCase();
      final target = want.replaceAll('_', '-').toLowerCase();
      if (norm == target) return item;
    }
  }
  for (final item in list) {
    final norm = item.replaceAll('_', '-').toLowerCase();
    if (norm.startsWith('uz') && !norm.contains('cyrl')) return item;
  }
  return 'uz-UZ';
}

bool _voiceBlobIsFemale(String blob) {
  return blob.contains('female') ||
      blob.contains('ayol') ||
      blob.contains('sfg');
}

bool _voiceBlobIsMale(String blob) {
  if (_voiceBlobIsFemale(blob)) return false;
  return blob.contains('male') || blob.contains('erkak') || blob.contains('uzm');
}

/// Yuqori ball — o‘zbek erkak ovoz. Boshqa tillar −1.
int scoreTtsVoice(Map<String, String> voice) {
  final locale = (voice['locale'] ?? voice['localeId'] ?? '')
      .toLowerCase()
      .replaceAll('_', '-');
  final name = (voice['name'] ?? '').toLowerCase();
  final features = (voice['features'] ?? '').toLowerCase();
  final blob = '$name $features';
  final uzbek = locale.startsWith('uz') || name.contains('uzbek');
  if (!uzbek || locale.contains('cyrl')) return -1;

  var score = locale == 'uz-uz' ? 30 : 10;
  if (_voiceBlobIsMale(blob)) score += 40;
  if (voice['network_required'] == '1') score += 3;
  return score;
}

/// Erkak o‘zbek ovoz. Yo‘q bo‘lsa, bor o‘zbek ovozning o‘zi.
Map<String, String>? pickMaleUzbekVoice(List<Map<String, String>> voices) {
  Map<String, String>? best;
  var bestScore = -1;
  for (final voice in voices) {
    final score = scoreTtsVoice(voice);
    if (score > bestScore) {
      bestScore = score;
      best = voice;
    }
  }
  return best;
}

/// Erkak ovoz o‘z balandligida qoladi. Ayol ovoz pastroqqa tushiriladi.
double pitchForVoice(Map<String, String>? voice) {
  if (voice == null) return 0.82;
  final blob =
      '${voice['name'] ?? ''} ${voice['features'] ?? ''}'.toLowerCase();
  if (_voiceBlobIsMale(blob)) return 1;
  return 0.82;
}

/// flutter_tts — o‘zbekcha erkak ovoz.
class FlutterTtsService implements TtsService {
  FlutterTtsService({FlutterTts? engine}) : _tts = engine ?? FlutterTts();

  final FlutterTts _tts;
  var _speaking = false;
  var _locale = 'uz-UZ';
  var _pitch = 0.82;
  Map<String, String>? _voice;
  final _speakingController = StreamController<bool>.broadcast();

  @override
  bool get isSpeaking => _speaking;

  @override
  Stream<bool> get speakingStream => _speakingController.stream;

  @override
  String get activeLocale => _locale;

  @override
  Future<void> init() async {
    try {
      await _tts.setSpeechRate(0.40);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);
      if (!kIsWeb && Platform.isAndroid) {
        await _tts.setQueueMode(1);
      }

      _locale = await _pickUzbekLocale();
      await _tts.setLanguage(_locale);
      await _trySetUzbekVoice();
      _pitch = pitchForVoice(_voice);
      await _tts.setPitch(_pitch);

      _tts.setStartHandler(() {
        _speaking = true;
        _speakingController.add(true);
      });
      _tts.setCompletionHandler(() {
        _speaking = false;
        _speakingController.add(false);
      });
      _tts.setCancelHandler(() {
        _speaking = false;
        _speakingController.add(false);
      });
      _tts.setErrorHandler((msg) {
        _speaking = false;
        _speakingController.add(false);
      });
    } catch (_) {}
  }

  Future<String> _pickUzbekLocale() async {
    try {
      final langs = await _tts.getLanguages;
      final available = <String>[];
      if (langs is List) {
        for (final item in langs) {
          available.add(item.toString());
        }
      }
      return pickSpeechLocale(available);
    } catch (_) {}
    return 'uz-UZ';
  }

  Future<void> _trySetUzbekVoice() async {
    try {
      final voices = await _tts.getVoices;
      if (voices is! List) return;
      final parsed = <Map<String, String>>[];
      for (final raw in voices) {
        if (raw is! Map) continue;
        parsed.add(
          Map<String, String>.from(
            raw.map((key, value) => MapEntry('$key', '$value')),
          ),
        );
      }
      final chosen = pickMaleUzbekVoice(parsed);
      if (chosen == null) return;
      final name = chosen['name'];
      if (name == null || name.isEmpty) return;
      _voice = {
        'name': name,
        'locale': chosen['locale'] ?? chosen['localeId'] ?? _locale,
      };
      await _tts.setVoice(_voice!);
    } catch (_) {}
  }

  String _prepareForSpeech(String raw) {
    var t = raw.trim();
    t = t
        .replaceAll('ʻ', "'")
        .replaceAll('ʼ', "'")
        .replaceAll('’', "'")
        .replaceAll('‘', "'")
        .replaceAll('—', ', ')
        .replaceAll('–', ', ')
        .replaceAll('…', '.')
        .replaceAll('«', '')
        .replaceAll('»', '')
        .replaceAll(RegExp(r'\s+'), ' ');
    t = t.replaceAll(RegExp(r'[\\{}$_]'), ' ');
    if (t.length > 220) {
      t = t.replaceAll('. ', '.|').replaceAll('? ', '?|').replaceAll('! ', '!|');
    }
    return t;
  }

  @override
  Future<void> speak(String text) async {
    final cleaned = _prepareForSpeech(text);
    if (cleaned.isEmpty) return;
    try {
      await stop();
      await _tts.setLanguage(_locale);
      await _tts.setPitch(_pitch);
      final voice = _voice;
      if (voice != null) await _tts.setVoice(voice);
      final spoken = cleaned.replaceAll('|', ', ');
      await _tts.speak(spoken);
    } catch (_) {}
  }

  @override
  Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (_) {}
    _speaking = false;
    if (!_speakingController.isClosed) {
      _speakingController.add(false);
    }
  }

  @override
  Future<void> dispose() async {
    await stop();
    await _speakingController.close();
  }
}

class StubTtsService implements TtsService {
  var _speaking = false;
  final _speakingController = StreamController<bool>.broadcast();

  @override
  bool get isSpeaking => _speaking;

  @override
  Stream<bool> get speakingStream => _speakingController.stream;

  @override
  String get activeLocale => 'uz-UZ';

  @override
  Future<void> init() async {}

  @override
  Future<void> speak(String text) async {
    _speaking = true;
    _speakingController.add(true);
    await Future<void>.delayed(const Duration(milliseconds: 200));
    _speaking = false;
    _speakingController.add(false);
  }

  @override
  Future<void> stop() async {
    _speaking = false;
    _speakingController.add(false);
  }

  @override
  Future<void> dispose() async {
    await _speakingController.close();
  }
}
