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

/// flutter_tts — o‘zbekcha ovoz (turkcha ishlatilmaydi).
class FlutterTtsService implements TtsService {
  FlutterTtsService({FlutterTts? engine}) : _tts = engine ?? FlutterTts();

  final FlutterTts _tts;
  var _speaking = false;
  var _locale = 'uz-UZ';
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

  /// Turkcha/inglizcha emas — faqat o‘zbek (yo‘q bo‘lsa ru, oxirida en).
  Future<String> _pickUzbekLocale() async {
    try {
      final langs = await _tts.getLanguages;
      final available = <String>[];
      if (langs is List) {
        for (final l in langs) {
          available.add(l.toString());
        }
      }

      const preferred = [
        'uz-UZ',
        'uz_UZ',
        'uz',
        'uz-Latn-UZ',
        'uz-Cyrl-UZ',
      ];
      for (final p in preferred) {
        for (final a in available) {
          final norm = a.replaceAll('_', '-').toLowerCase();
          final want = p.replaceAll('_', '-').toLowerCase();
          if (norm == want || norm.startsWith('uz')) {
            return a;
          }
        }
      }

      // O‘zbek yo‘q — rus (markaziy Osiyo aksenti), lekin TURKCHA emas.
      for (final a in available) {
        final n = a.toLowerCase();
        if (n.startsWith('ru')) return a;
      }
    } catch (_) {}

    // Majburan uz — tizim o‘zi fallback qiladi.
    return 'uz-UZ';
  }

  Future<void> _trySetUzbekVoice() async {
    try {
      final voices = await _tts.getVoices;
      if (voices is! List) return;
      for (final raw in voices) {
        if (raw is! Map) continue;
        final map = Map<String, String>.from(
          raw.map((k, v) => MapEntry('$k', '$v')),
        );
        final locale = (map['locale'] ?? map['localeId'] ?? '').toLowerCase();
        final name = (map['name'] ?? '').toLowerCase();
        if (locale.startsWith('uz') || name.contains('uzbek')) {
          await _tts.setVoice(map);
          return;
        }
      }
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
      // Har safar o‘zbek tilini qayta qo‘yamiz (boshqa locale o‘tib ketmasin).
      await _tts.setLanguage(_locale);
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
