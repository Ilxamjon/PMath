import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../models/lesson_model.dart';
import '../../../../services/parent_alert_service.dart';
import '../../../../services/storage_service.dart';
import '../../../../services/stt_service.dart';
import '../../../../services/tts_service.dart';
import '../../../proctoring/domain/proctoring_guard.dart';
import '../../../voice_ai/domain/voice_ai_coach.dart';
import '../../domain/lesson_script.dart';
import 'lesson_state.dart';

/// Interaktiv AI dars xonasi: TTS + STT + Sokratik oqim + proctoring.
class LessonCubit extends Cubit<LessonState> {
  LessonCubit({
    required LessonModel lesson,
    required TtsService tts,
    required SttService stt,
    required ProctoringGuard proctoring,
    required StorageService storage,
    ParentAlertService? parentAlerts,
    VoiceAiCoach? voiceCoach,
  })  : _tts = tts,
        _stt = stt,
        _proctoring = proctoring,
        _storage = storage,
        _alerts = parentAlerts,
        _voiceCoach = voiceCoach ?? VoiceAiCoach(),
        super(LessonState(
          lesson: lesson,
          script: LessonScript.fromLesson(lesson),
        )) {
    _proctoring.addListener(_onProctoringEvent);
  }

  final TtsService _tts;
  final SttService _stt;
  final ProctoringGuard _proctoring;
  final StorageService _storage;
  final ParentAlertService? _alerts;
  final VoiceAiCoach _voiceCoach;
  StreamSubscription<bool>? _speakSub;
  var _dialogShown = false;
  var _handlingFinal = false;

  Future<void> start() async {
    await _tts.init();
    final sttOk = await _stt.init();
    _speakSub = _tts.speakingStream.listen((speaking) {
      if (!isClosed) emit(state.copyWith(isSpeaking: speaking));
    });

    _proctoring.startSession(lessonId: state.lesson.id);
    emit(state.copyWith(
      phase: LessonPhase.intro,
      proctoringActive: _proctoring.isActive,
      sttAvailable: sttOk,
    ));

    await _storage.updateLesson(
      state.lesson.copyWith(status: LessonStatus.inProgress),
    );

    await speakCurrent();
  }

  void _onProctoringEvent(ProctoringEvent event) {
    if (isClosed) return;
    if (state.phase == LessonPhase.completed) return;

    if (event.isViolation) {
      unawaited(_tts.stop());
      unawaited(_stt.cancel());
      emit(state.copyWith(
        isProctoringPaused: true,
        pauseReason: event,
        proctoringWarnings: _proctoring.sessionWarningCount,
        showProctoringDialog: !_dialogShown,
        isSpeaking: false,
        isListening: false,
      ));
      _dialogShown = true;
      unawaited(_recordWarning(event));
    } else if (event == ProctoringEvent.resumed) {
      _dialogShown = false;
      emit(state.copyWith(
        isProctoringPaused: false,
        clearPauseReason: true,
        showProctoringDialog: false,
      ));
    }
  }

  Future<void> _recordWarning(ProctoringEvent event) async {
    final total = await _storage.recordCheatingWarning();
    final user = _storage.getUser();
    if (user != null && _alerts != null) {
      await _alerts.cheatingWarning(
        user: user,
        reasonUz: event.titleUz,
        totalWarnings: total,
      );
    }
  }

  void resumeAfterProctoring() {
    _proctoring.resumeAfterWarning();
    if (state.isProctoringPaused) {
      _dialogShown = false;
      emit(state.copyWith(
        isProctoringPaused: false,
        clearPauseReason: true,
        showProctoringDialog: false,
      ));
    }
  }

  void clearProctoringDialogFlag() {
    emit(state.copyWith(showProctoringDialog: false));
  }

  void simulateProctoringViolation() {
    _proctoring.simulate(ProctoringEvent.noFace);
  }

  Future<void> speakCurrent() async {
    if (state.isProctoringPaused) return;
    final text = switch (state.phase) {
      LessonPhase.intro => state.script.introText,
      LessonPhase.socratic => () {
          final step = state.currentStep;
          if (step == null) return '';
          if (step.hasVisual) {
            final cap = step.captionUz ?? 'Chizmaga qarang';
            return '$cap. ${step.prompt}';
          }
          return step.prompt;
        }(),
      LessonPhase.summary => state.script.summaryText,
      LessonPhase.completed => state.script.summaryText,
    };
    await _tts.speak(text);
  }

  Future<void> stopSpeaking() => _tts.stop();

  /// Mikrofon: ovozli savol → STT → AI javob → TTS.
  Future<void> toggleVoiceAsk() async {
    if (state.isProctoringPaused) return;
    if (state.phase == LessonPhase.completed) return;

    if (state.isListening) {
      await _stt.stopListening();
      if (!isClosed) emit(state.copyWith(isListening: false));
      return;
    }

    if (!state.sttAvailable) {
      emit(state.copyWith(
        voiceError: 'Mikrofon / nutq tanish mavjud emas',
      ));
      return;
    }

    await _tts.stop();
    _handlingFinal = false;
    emit(state.copyWith(
      isListening: true,
      lastHeardText: '',
      voiceReplyText: '',
      clearVoiceError: true,
      isSpeaking: false,
    ));

    await _stt.startListening(
      onResult: (text, isFinal) {
        if (isClosed) return;
        emit(state.copyWith(
          lastHeardText: text,
          thoughtText: text.isNotEmpty ? text : state.thoughtText,
        ));
        if (isFinal && text.trim().isNotEmpty) {
          unawaited(_onFinalTranscript(text));
        }
      },
      onError: (err) {
        if (isClosed) return;
        emit(state.copyWith(
          isListening: false,
          voiceError: err,
        ));
      },
    );
  }

  Future<void> _onFinalTranscript(String text) async {
    if (_handlingFinal || isClosed) return;
    _handlingFinal = true;

    await _stt.stopListening();
    if (isClosed) return;

    final reply = await _voiceCoach.answer(
      transcript: text,
      lesson: state.lesson,
      currentPrompt: state.phase == LessonPhase.socratic
          ? state.currentPrompt
          : null,
    );

    emit(state.copyWith(
      isListening: false,
      lastHeardText: reply.heardText,
      voiceReplyText: reply.answerUz,
      thoughtText: reply.heardText,
      clearVoiceError: true,
    ));

    await _tts.speak(reply.answerUz);
    _handlingFinal = false;
  }

  /// Matn orqali ham xuddi shu ovozli AI javobini olish (test / fallback).
  Future<void> askVoiceCoach(String question) async {
    if (state.isProctoringPaused) return;
    await _tts.stop();
    final reply = await _voiceCoach.answer(
      transcript: question,
      lesson: state.lesson,
      currentPrompt:
          state.phase == LessonPhase.socratic ? state.currentPrompt : null,
    );
    emit(state.copyWith(
      lastHeardText: reply.heardText,
      voiceReplyText: reply.answerUz,
      thoughtText: reply.heardText.isNotEmpty ? reply.heardText : state.thoughtText,
      clearVoiceError: true,
      isListening: false,
    ));
    await _tts.speak(reply.answerUz);
  }

  void setThought(String value) {
    if (state.isProctoringPaused) return;
    emit(state.copyWith(thoughtText: value));
  }

  Future<void> advance() async {
    if (state.isProctoringPaused) return;
    await _tts.stop();
    await _stt.cancel();

    switch (state.phase) {
      case LessonPhase.intro:
        if (state.socraticTotal == 0) {
          emit(state.copyWith(
            phase: LessonPhase.summary,
            thoughtText: '',
            isListening: false,
            voiceReplyText: '',
          ));
        } else {
          emit(state.copyWith(
            phase: LessonPhase.socratic,
            socraticIndex: 0,
            thoughtText: '',
            isListening: false,
            voiceReplyText: '',
          ));
        }
        await speakCurrent();

      case LessonPhase.socratic:
        if (state.isLastSocratic) {
          emit(state.copyWith(
            phase: LessonPhase.summary,
            thoughtText: '',
            isListening: false,
            voiceReplyText: '',
          ));
        } else {
          emit(state.copyWith(
            socraticIndex: state.socraticIndex + 1,
            thoughtText: '',
            isListening: false,
            voiceReplyText: '',
          ));
        }
        await speakCurrent();

      case LessonPhase.summary:
        await _completeLesson();

      case LessonPhase.completed:
        break;
    }
  }

  Future<void> _completeLesson() async {
    final updated = state.lesson.copyWith(
      status: LessonStatus.completed,
      masteryPercent: state.lesson.masteryPercent > 0
          ? state.lesson.masteryPercent
          : 40.0,
      completedAt: DateTime.now(),
    );

    await _storage.updateLesson(updated);
    _proctoring.endSession();
    await _stt.cancel();

    emit(state.copyWith(
      phase: LessonPhase.completed,
      lesson: updated,
      coinsAwarded: updated.coinsReward,
      proctoringActive: false,
      isProctoringPaused: false,
      isListening: false,
    ));

    await _tts.speak(
      'Tabriklayman! Dars tugadi. Endi qisqa mashqqa o‘tamiz.',
    );
  }

  @override
  Future<void> close() async {
    await _speakSub?.cancel();
    await _stt.cancel();
    _proctoring.removeListener(_onProctoringEvent);
    _proctoring.endSession();
    // Shared TTS/STT DI — faqat to‘xtatamiz, dispose qilmaymiz.
    await _tts.stop();
    return super.close();
  }
}
