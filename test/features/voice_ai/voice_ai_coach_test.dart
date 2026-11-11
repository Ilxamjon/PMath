import 'package:flutter_test/flutter_test.dart';
import 'package:pmath/features/voice_ai/domain/voice_ai_coach.dart';
import 'package:pmath/models/lesson_model.dart';
import 'package:pmath/services/ai_tutor_service.dart';

void main() {
  test('VoiceAiCoach: ovozli savol → o‘zbekcha javob', () async {
    final coach = VoiceAiCoach(tutor: AiTutorService());
    final lesson = LessonModel(
      id: 'l1',
      titleUz: 'Taqqoslash',
      topic: 'Mantiq',
      weekNumber: 1,
      orderIndex: 0,
      durationMinutes: 15,
      coinsReward: 20,
    );

    final help = await coach.answer(
      transcript: 'Men tushunmadim, yordam bering',
      lesson: lesson,
      currentPrompt: 'Nimalar taqqoslanmoqda?',
    );
    expect(help.answerUz.isNotEmpty, isTrue);
    expect(help.heardText.contains('tushunmadim'), isTrue);

    final how = await coach.answer(
      transcript: 'Qanday yechamiz?',
      lesson: lesson,
    );
    expect(how.answerUz.toLowerCase(), contains('formula'));

    final empty = await coach.answer(transcript: '   ', lesson: lesson);
    expect(empty.answerUz.contains('Eshitmadim'), isTrue);
  });
}
