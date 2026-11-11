import 'package:flutter_test/flutter_test.dart';
import 'package:pmath/features/lesson/presentation/cubit/lesson_cubit.dart';
import 'package:pmath/features/proctoring/domain/proctoring_guard.dart';
import 'package:pmath/models/lesson_model.dart';
import 'package:pmath/services/storage_service.dart';
import 'package:pmath/services/stt_service.dart';
import 'package:pmath/services/tts_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Stub STT + askVoiceCoach: savol → TTS javob', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = await StorageService.init();
    final tts = StubTtsService();
    final stt = StubSttService(simulatedText: 'Bu masalani qanday yechamiz?');
    final cubit = LessonCubit(
      lesson: LessonModel(
        id: 'l1',
        titleUz: 'Kasrlar',
        topic: 'Kasrlar',
        weekNumber: 1,
        orderIndex: 0,
        durationMinutes: 10,
        coinsReward: 10,
      ),
      tts: tts,
      stt: stt,
      proctoring: StubProctoringGuard(),
      storage: storage,
    );

    await cubit.start();
    await cubit.askVoiceCoach('Qanday yechamiz?');

    expect(cubit.state.lastHeardText, 'Qanday yechamiz?');
    expect(cubit.state.voiceReplyText.isNotEmpty, isTrue);
    expect(cubit.state.hasVoiceReply, isTrue);

    await cubit.toggleVoiceAsk();
    await Future<void>.delayed(const Duration(milliseconds: 250));
    expect(cubit.state.lastHeardText, contains('qanday'));
    expect(cubit.state.voiceReplyText.isNotEmpty, isTrue);

    await cubit.close();
  });
}
