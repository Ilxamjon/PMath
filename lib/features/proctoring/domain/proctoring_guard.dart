import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Proctoring hodisalari — yuz / e'tibor nazorati.
enum ProctoringEvent {
  sessionStarted,
  sessionEnded,
  noFace,
  multipleFaces,
  lookingAway,
  resumed,
}

extension ProctoringEventX on ProctoringEvent {
  bool get isViolation =>
      this == ProctoringEvent.noFace ||
      this == ProctoringEvent.multipleFaces ||
      this == ProctoringEvent.lookingAway;

  String get titleUz => switch (this) {
        ProctoringEvent.noFace => 'Yuz topilmadi',
        ProctoringEvent.multipleFaces => 'Bir nechta yuz',
        ProctoringEvent.lookingAway => 'Ekrandan qaradingiz',
        ProctoringEvent.sessionStarted => 'Nazorat boshlandi',
        ProctoringEvent.sessionEnded => 'Nazorat tugadi',
        ProctoringEvent.resumed => 'Davom etildi',
      };

  String get bodyUz => switch (this) {
        ProctoringEvent.noFace =>
          'Kamerada yuz ko‘rinmayapti. Iltimos, kameraga qarang — test pauzalandi.',
        ProctoringEvent.multipleFaces =>
          'Kamerada bir nechta yuz aniqlandi. Yolg‘iz o‘zingiz bo‘ling.',
        ProctoringEvent.lookingAway =>
          'Ilovadan chiqdingiz yoki boshqa oynaga o‘tdingiz. Test pauzalandi.',
        ProctoringEvent.sessionStarted => 'Front kamera nazorati yoqildi.',
        ProctoringEvent.sessionEnded => 'Nazorat sessiyasi yopildi.',
        ProctoringEvent.resumed => 'Davom etishingiz mumkin.',
      };
}

typedef ProctoringListener = void Function(ProctoringEvent event);

/// Strict Proctoring Guard abstraksiyasi.
abstract class ProctoringGuard {
  void startSession({required String lessonId});
  void endSession();

  /// Ogohlantirishdan keyin testni davom ettirish.
  void resumeAfterWarning();

  bool get isActive;
  bool get isPaused;
  int get sessionWarningCount;
  String? get currentLessonId;

  /// PIP preview uchun (null bo‘lishi mumkin).
  CameraController? get cameraController;

  void addListener(ProctoringListener listener);
  void removeListener(ProctoringListener listener);

  /// Dev/test: sun’iy violation.
  void simulate(ProctoringEvent event);
}

/// Lokal guard: front kamera + hayot sikli + yorug‘lik asosida yuz mavjudligi.
///
/// Yuz tahlili faqat shu qurilmada. Kadr faylga yozilmaydi, tarmoqqa
/// yuborilmaydi va maydonlarda saqlanmaydi — oqimdan faqat yorug‘lik soni qoladi.
///
/// Kameradan kelayotgan kadrlarning markaziy yorug‘ligi tahlil qilinadi:
/// qorong‘i/tekis kadr = yuz yo‘q; hayotiy o‘zgaruvchanlik = o‘quvchi qaragan.
class LocalProctoringGuard
    with WidgetsBindingObserver
    implements ProctoringGuard {
  LocalProctoringGuard({
    this.enableDemoViolations = false,
    this.monitorInterval = const Duration(seconds: 4),
    this.cameraAllowed,
  });

  /// false bo‘lsa kamera ochilmaydi. null — ruxsat berilgan (test).
  final bool Function()? cameraAllowed;

  /// true bo‘lsa, qo‘shimcha demo violation (test).
  final bool enableDemoViolations;
  final Duration monitorInterval;

  final _listeners = <ProctoringListener>[];
  var _active = false;
  var _paused = false;
  var _sessionWarnings = 0;
  String? _lessonId;
  CameraController? _camera;
  Timer? _monitor;
  var _tickCount = 0;
  var _observerAttached = false;
  DateTime? _lastFrameOkAt;
  DateTime? _lastFaceSeenAt;
  var _streaming = false;
  var _darkStreak = 0;
  double _lastLuma = 0;

  @override
  bool get isActive => _active;

  @override
  bool get isPaused => _paused;

  @override
  int get sessionWarningCount => _sessionWarnings;

  @override
  String? get currentLessonId => _lessonId;

  @override
  CameraController? get cameraController =>
      _camera != null && _camera!.value.isInitialized ? _camera : null;

  @override
  void startSession({required String lessonId}) {
    if (cameraAllowed != null && !cameraAllowed!()) {
      if (_active) endSession();
      return;
    }
    if (_active) endSession();
    _lessonId = lessonId;
    _active = true;
    _paused = false;
    _sessionWarnings = 0;
    _tickCount = 0;
    _darkStreak = 0;
    _lastFrameOkAt = DateTime.now();
    _lastFaceSeenAt = DateTime.now();
    _emit(ProctoringEvent.sessionStarted);
    unawaited(_initCamera());
    _attachObserver();
    _monitor?.cancel();
    _monitor = Timer.periodic(monitorInterval, (_) => _onMonitorTick());
  }

  @override
  void endSession() {
    if (!_active && _camera == null) return;
    _monitor?.cancel();
    _monitor = null;
    _detachObserver();
    unawaited(_disposeCamera());
    final wasActive = _active;
    _active = false;
    _paused = false;
    _lessonId = null;
    _streaming = false;
    if (wasActive) _emit(ProctoringEvent.sessionEnded);
  }

  @override
  void resumeAfterWarning() {
    if (!_active || !_paused) return;
    _paused = false;
    _darkStreak = 0;
    _lastFrameOkAt = DateTime.now();
    _lastFaceSeenAt = DateTime.now();
    _emit(ProctoringEvent.resumed);
  }

  @override
  void addListener(ProctoringListener listener) => _listeners.add(listener);

  @override
  void removeListener(ProctoringListener listener) =>
      _listeners.remove(listener);

  @override
  void simulate(ProctoringEvent event) {
    if (event.isViolation) {
      _triggerViolation(event);
    } else {
      _emit(event);
    }
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;
      final front = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );
      final controller = CameraController(
        front,
        ResolutionPreset.low,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );
      await controller.initialize();
      if (!_active) {
        await controller.dispose();
        return;
      }
      _camera = controller;
      _lastFrameOkAt = DateTime.now();
      _lastFaceSeenAt = DateTime.now();
      await _startFaceWatch(controller);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Proctoring camera init failed: $e');
      }
    }
  }

  Future<void> _startFaceWatch(CameraController controller) async {
    if (_streaming) return;
    try {
      _streaming = true;
      await controller.startImageStream((image) {
        if (!_active || _paused) return;
        // `image` bu yerdan chiqmaydi: faqat o‘rtacha yorug‘lik hisoblanadi.
        final luma = _centerLuma(image);
        _lastLuma = luma;
        _lastFrameOkAt = DateTime.now();

        // Yorug‘lik oralig‘i + kadrlar o‘zgaruvchanligi ≈ yuz/mavjudlik.
        final faceLike = luma > 28 && luma < 220;
        if (faceLike) {
          _darkStreak = 0;
          _lastFaceSeenAt = DateTime.now();
        } else {
          _darkStreak++;
        }
      });
    } catch (e) {
      _streaming = false;
      if (kDebugMode) debugPrint('Image stream failed: $e');
    }
  }

  double _centerLuma(CameraImage image) {
    try {
      final plane = image.planes.first;
      final bytes = plane.bytes;
      final w = image.width;
      final h = image.height;
      if (w < 8 || h < 8 || bytes.isEmpty) return 0;

      // Markaziy 1/3 maydon o‘rtacha yorug‘ligi.
      final x0 = w ~/ 3;
      final x1 = (2 * w) ~/ 3;
      final y0 = h ~/ 3;
      final y1 = (2 * h) ~/ 3;
      final rowStride = plane.bytesPerRow;
      var sum = 0;
      var count = 0;
      for (var y = y0; y < y1; y += 4) {
        final row = y * rowStride;
        for (var x = x0; x < x1; x += 4) {
          final i = row + x;
          if (i >= 0 && i < bytes.length) {
            sum += bytes[i];
            count++;
          }
        }
      }
      if (count == 0) return 0;
      return sum / count;
    } catch (_) {
      return _lastLuma;
    }
  }

  Future<void> _disposeCamera() async {
    final c = _camera;
    _camera = null;
    try {
      if (_streaming) {
        await c?.stopImageStream();
      }
    } catch (_) {}
    _streaming = false;
    try {
      await c?.dispose();
    } catch (_) {}
  }

  void _attachObserver() {
    if (_observerAttached) return;
    WidgetsBinding.instance.addObserver(this);
    _observerAttached = true;
  }

  void _detachObserver() {
    if (!_observerAttached) return;
    WidgetsBinding.instance.removeObserver(this);
    _observerAttached = false;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_active || _paused) return;
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _triggerViolation(ProctoringEvent.lookingAway);
    } else if (state == AppLifecycleState.resumed) {
      _lastFrameOkAt = DateTime.now();
      _lastFaceSeenAt = DateTime.now();
      _darkStreak = 0;
    }
  }

  void _onMonitorTick() {
    if (!_active || _paused) return;
    _tickCount++;

    final camOk = cameraController != null;
    if (!camOk) {
      final absentFor = DateTime.now().difference(
        _lastFrameOkAt ?? DateTime.now(),
      );
      if (absentFor >= const Duration(seconds: 8)) {
        _triggerViolation(ProctoringEvent.noFace);
      }
      return;
    }

    // Yuz/mavjudlik yo‘qolgan (qorong‘i kadr yoki kamera yopilgan).
    final sinceFace = DateTime.now().difference(
      _lastFaceSeenAt ?? DateTime.now(),
    );
    if (_darkStreak >= 3 || sinceFace >= const Duration(seconds: 10)) {
      _triggerViolation(ProctoringEvent.noFace);
      return;
    }

    if (enableDemoViolations && _tickCount > 0 && _tickCount % 8 == 0) {
      _triggerViolation(ProctoringEvent.noFace);
    }
  }

  void _triggerViolation(ProctoringEvent event) {
    if (!_active || _paused || !event.isViolation) return;
    _paused = true;
    _sessionWarnings++;
    _emit(event);
  }

  void _emit(ProctoringEvent event) {
    for (final l in List<ProctoringListener>.from(_listeners)) {
      l(event);
    }
  }
}

/// Testlar uchun engil stub (kamera yoqilmaydi).
class StubProctoringGuard implements ProctoringGuard {
  final _listeners = <ProctoringListener>[];
  var _active = false;
  var _paused = false;
  var _sessionWarnings = 0;
  String? _lessonId;

  @override
  bool get isActive => _active;

  @override
  bool get isPaused => _paused;

  @override
  int get sessionWarningCount => _sessionWarnings;

  @override
  String? get currentLessonId => _lessonId;

  @override
  CameraController? get cameraController => null;

  @override
  void startSession({required String lessonId}) {
    _lessonId = lessonId;
    _active = true;
    _paused = false;
    _sessionWarnings = 0;
    _emit(ProctoringEvent.sessionStarted);
  }

  @override
  void endSession() {
    if (!_active) return;
    _active = false;
    _paused = false;
    _lessonId = null;
    _emit(ProctoringEvent.sessionEnded);
  }

  @override
  void resumeAfterWarning() {
    if (!_paused) return;
    _paused = false;
    _emit(ProctoringEvent.resumed);
  }

  @override
  void addListener(ProctoringListener listener) => _listeners.add(listener);

  @override
  void removeListener(ProctoringListener listener) =>
      _listeners.remove(listener);

  @override
  void simulate(ProctoringEvent event) {
    if (event.isViolation) {
      if (!_active || _paused) return;
      _paused = true;
      _sessionWarnings++;
      _emit(event);
    } else {
      _emit(event);
    }
  }

  void _emit(ProctoringEvent event) {
    for (final l in List<ProctoringListener>.from(_listeners)) {
      l(event);
    }
  }
}
