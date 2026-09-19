import '../../../models/lesson_model.dart';
import '../../../services/ai_tutor_service.dart';

/// Ovozli savolga AI javobi.
class VoiceAiReply {
  const VoiceAiReply({
    required this.answerUz,
    required this.heardText,
    this.provider = 'local',
  });

  final String answerUz;
  final String heardText;
  final String provider;
}

/// Ovozli AI yordamchi — Gemini (agar kalit bor) yoki lokal Sokratik AI.
class VoiceAiCoach {
  VoiceAiCoach({AiTutorService? tutor}) : _tutor = tutor ?? AiTutorService();

  final AiTutorService _tutor;

  String get providerLabel => _tutor.providerLabel;

  Future<VoiceAiReply> answer({
    required String transcript,
    required LessonModel lesson,
    String? currentPrompt,
  }) async {
    final heard = transcript.trim();
    final text = await _tutor.coachReply(
      studentText: heard,
      lesson: lesson,
      currentPrompt: currentPrompt,
    );
    return VoiceAiReply(
      answerUz: text,
      heardText: heard,
      provider: _tutor.providerLabel,
    );
  }
}
