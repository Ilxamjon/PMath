import 'dart:async';

import 'package:speech_to_text/speech_to_text.dart';

/// Speech-to-Text abstraksiyasi (o‘zbekcha / fallback).
abstract class SttService {
  Future<bool> init();
  Future<void> startListening({
    required void Function(String text, bool isFinal) onResult,
    void Function(String error)? onError,
    Duration listenFor = const Duration(seconds: 12),
  });
  Future<void> stopListening();
  Future<void> cancel();
  bool get isAvailable;
  bool get isListening;
  String get activeLocaleId;
}

/// Qurilma STT (speech_to_text). Uzbek bo‘lmasa — ru/en fallback.
class DeviceSttService implements SttService {
  DeviceSttService({SpeechToText? engine}) : _speech = engine ?? SpeechToText();

  final SpeechToText _speech;
  var _available = false;
  var _listening = false;
  var _localeId = 'en_US';

  @override
  bool get isAvailable => _available;

  @override
  bool get isListening => _listening;

  @override
  String get activeLocaleId => _localeId;

  @override
  Future<bool> init() async {
    try {
      _available = await _speech.initialize(
        onError: (_) {
          _listening = false;
        },
        onStatus: (status) {
          if (status == 'done' || status == 'notListening') {
            _listening = false;
          }
        },
      );
      if (_available) {
        _localeId = await _pickLocale();
      }
      return _available;
    } catch (_) {
      _available = false;
      return false;
    }
  }

  Future<String> _pickLocale() async {
    try {
      final locales = await _speech.locales();
      // Faqat o‘zbek birinchi; turkcha yo‘q.
      final preferred = [
        'uz_UZ',
        'uz-UZ',
        'uz',
        'ru_RU',
        'ru-RU',
        'en_US',
        'en-US',
      ];
      for (final id in preferred) {
        final match = locales.where(
          (l) =>
              l.localeId == id ||
              l.localeId.replaceAll('-', '_') == id.replaceAll('-', '_') ||
              l.localeId.toLowerCase().startsWith(
                    id.split(RegExp('[-_]')).first.toLowerCase(),
                  ),
        );
        if (match.isNotEmpty) {
          // Turkcha locale ni o‘tkazib yuboramiz.
          final chosen = match.first.localeId;
          if (chosen.toLowerCase().startsWith('tr')) continue;
          return chosen;
        }
      }
      if (locales.isNotEmpty) {
        final nonTr = locales.where(
          (l) => !l.localeId.toLowerCase().startsWith('tr'),
        );
        if (nonTr.isNotEmpty) return nonTr.first.localeId;
        return locales.first.localeId;
      }
    } catch (_) {}
    return 'uz_UZ';
  }

  @override
  Future<void> startListening({
    required void Function(String text, bool isFinal) onResult,
    void Function(String error)? onError,
    Duration listenFor = const Duration(seconds: 12),
  }) async {
    if (!_available) {
      onError?.call('STT mavjud emas');
      return;
    }
    if (_listening) await stopListening();

    _listening = true;
    try {
      await _speech.listen(
        onResult: (result) {
          onResult(result.recognizedWords, result.finalResult);
        },
        listenOptions: SpeechListenOptions(
          partialResults: true,
          cancelOnError: true,
          listenMode: ListenMode.confirmation,
          listenFor: listenFor,
          pauseFor: const Duration(seconds: 3),
          localeId: _localeId,
        ),
      );
    } catch (e) {
      _listening = false;
      onError?.call(e.toString());
    }
  }

  @override
  Future<void> stopListening() async {
    try {
      await _speech.stop();
    } catch (_) {}
    _listening = false;
  }

  @override
  Future<void> cancel() async {
    try {
      await _speech.cancel();
    } catch (_) {}
    _listening = false;
  }
}

/// Test / headless: so‘roq matnini simulyatsiya qiladi.
class StubSttService implements SttService {
  StubSttService({this.simulatedText = 'Bu masalani qanday yechamiz?'});

  final String simulatedText;
  var _listening = false;
  final _available = true;

  @override
  bool get isAvailable => _available;

  @override
  bool get isListening => _listening;

  @override
  String get activeLocaleId => 'uz_UZ';

  @override
  Future<bool> init() async => true;

  @override
  Future<void> startListening({
    required void Function(String text, bool isFinal) onResult,
    void Function(String error)? onError,
    Duration listenFor = const Duration(seconds: 12),
  }) async {
    _listening = true;
    await Future<void>.delayed(const Duration(milliseconds: 120));
    onResult(simulatedText, false);
    await Future<void>.delayed(const Duration(milliseconds: 80));
    onResult(simulatedText, true);
    _listening = false;
  }

  @override
  Future<void> stopListening() async {
    _listening = false;
  }

  @override
  Future<void> cancel() async {
    _listening = false;
  }
}
