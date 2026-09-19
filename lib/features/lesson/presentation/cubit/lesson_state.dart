import 'package:equatable/equatable.dart';

import '../../../../models/lesson_model.dart';
import '../../../proctoring/domain/proctoring_guard.dart';
import '../../domain/lesson_script.dart';
import '../../domain/socratic_bank.dart';

enum LessonPhase { intro, socratic, summary, completed }

class LessonState extends Equatable {
  const LessonState({
    required this.lesson,
    required this.script,
    this.phase = LessonPhase.intro,
    this.socraticIndex = 0,
    this.thoughtText = '',
    this.isSpeaking = false,
    this.isListening = false,
    this.sttAvailable = false,
    this.lastHeardText = '',
    this.voiceReplyText = '',
    this.voiceError,
    this.proctoringActive = false,
    this.isProctoringPaused = false,
    this.pauseReason,
    this.proctoringWarnings = 0,
    this.showProctoringDialog = false,
    this.coinsAwarded = 0,
  });

  final LessonModel lesson;
  final LessonScript script;
  final LessonPhase phase;
  final int socraticIndex;
  final String thoughtText;
  final bool isSpeaking;
  final bool isListening;
  final bool sttAvailable;
  final String lastHeardText;
  final String voiceReplyText;
  final String? voiceError;
  final bool proctoringActive;
  final bool isProctoringPaused;
  final ProctoringEvent? pauseReason;
  final int proctoringWarnings;
  final bool showProctoringDialog;
  final int coinsAwarded;

  int get socraticTotal => script.socraticSteps.length;

  SocraticStep? get currentStep =>
      script.socraticSteps.isEmpty
          ? null
          : script.socraticSteps[
              socraticIndex.clamp(0, script.socraticSteps.length - 1)];

  String get currentPrompt => currentStep?.prompt ?? '';

  bool get isLastSocratic =>
      socraticTotal == 0 || socraticIndex >= socraticTotal - 1;

  bool get hasVoiceReply => voiceReplyText.trim().isNotEmpty;

  double get progress {
    final total = 2 + socraticTotal;
    final current = switch (phase) {
      LessonPhase.intro => 1,
      LessonPhase.socratic => 1 + socraticIndex + 1,
      LessonPhase.summary => total,
      LessonPhase.completed => total,
    };
    return (current / total).clamp(0.0, 1.0);
  }

  String get phaseLabel => switch (phase) {
        LessonPhase.intro => 'Kirish',
        LessonPhase.socratic => 'Sokratik',
        LessonPhase.summary => 'Xulosa',
        LessonPhase.completed => 'Tugadi',
      };

  LessonState copyWith({
    LessonModel? lesson,
    LessonScript? script,
    LessonPhase? phase,
    int? socraticIndex,
    String? thoughtText,
    bool? isSpeaking,
    bool? isListening,
    bool? sttAvailable,
    String? lastHeardText,
    String? voiceReplyText,
    String? voiceError,
    bool clearVoiceError = false,
    bool? proctoringActive,
    bool? isProctoringPaused,
    ProctoringEvent? pauseReason,
    bool clearPauseReason = false,
    int? proctoringWarnings,
    bool? showProctoringDialog,
    int? coinsAwarded,
  }) {
    return LessonState(
      lesson: lesson ?? this.lesson,
      script: script ?? this.script,
      phase: phase ?? this.phase,
      socraticIndex: socraticIndex ?? this.socraticIndex,
      thoughtText: thoughtText ?? this.thoughtText,
      isSpeaking: isSpeaking ?? this.isSpeaking,
      isListening: isListening ?? this.isListening,
      sttAvailable: sttAvailable ?? this.sttAvailable,
      lastHeardText: lastHeardText ?? this.lastHeardText,
      voiceReplyText: voiceReplyText ?? this.voiceReplyText,
      voiceError: clearVoiceError ? null : (voiceError ?? this.voiceError),
      proctoringActive: proctoringActive ?? this.proctoringActive,
      isProctoringPaused: isProctoringPaused ?? this.isProctoringPaused,
      pauseReason:
          clearPauseReason ? null : (pauseReason ?? this.pauseReason),
      proctoringWarnings: proctoringWarnings ?? this.proctoringWarnings,
      showProctoringDialog: showProctoringDialog ?? this.showProctoringDialog,
      coinsAwarded: coinsAwarded ?? this.coinsAwarded,
    );
  }

  @override
  List<Object?> get props => [
        lesson,
        script,
        phase,
        socraticIndex,
        thoughtText,
        isSpeaking,
        isListening,
        sttAvailable,
        lastHeardText,
        voiceReplyText,
        voiceError,
        proctoringActive,
        isProctoringPaused,
        pauseReason,
        proctoringWarnings,
        showProctoringDialog,
        coinsAwarded,
      ];
}
