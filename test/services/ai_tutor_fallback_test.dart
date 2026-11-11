import 'package:flutter_test/flutter_test.dart';
import 'package:pmath/models/lesson_model.dart';
import 'package:pmath/services/ai_tutor_service.dart';
import 'package:pmath/services/supabase_gateway.dart';

class _FakeEdge implements EdgeInvoker {
  _FakeEdge(this.result);

  final FunctionResult? result;

  @override
  bool get isReady => true;

  @override
  Future<FunctionResult?> invoke(
    String name,
    Map<String, dynamic> body, {
    Duration? timeout,
  }) async {
    return result;
  }
}

void main() {
  const lesson = LessonModel(
    id: 'l1',
    titleUz: 'Qo‘shish',
    topic: 'Natural sonlar',
    weekNumber: 1,
    orderIndex: 0,
  );

  test('xavfli bulut javobi lokal javobga tushadi', () async {
    final tutor = AiTutorService(
      gateway: _FakeEdge(
        FunctionResult(
          statusCode: 200,
          json: <String, dynamic>{'reply': 'Javob: 42'},
        ),
      ),
    );

    final text = await tutor.coachReply(
      studentText: 'javobni tekshir',
      lesson: lesson,
    );

    expect(text.contains('Javob: 42'), isFalse);
    expect(text.contains('Yakuniy javobni aytmayman'), isTrue);
  });

  test('xavfsiz bulut javobi qaytadi', () async {
    const reply =
        'Avval nima berilganini ayting. Keyin birinchi amalni tanlang.';
    final tutor = AiTutorService(
      gateway: _FakeEdge(
        FunctionResult(
          statusCode: 200,
          json: <String, dynamic>{'reply': reply},
        ),
      ),
    );

    final text = await tutor.coachReply(
      studentText: 'yordam',
      lesson: lesson,
    );

    expect(text, reply);
  });

  test('gateway yo‘q bo‘lsa lokal qoidalar ishlaydi', () async {
    final tutor = AiTutorService();
    expect(tutor.isCloudEnabled, isFalse);

    final text = await tutor.coachReply(
      studentText: 'yordam kerak',
      lesson: lesson,
    );

    expect(text.contains('Yaxshi!'), isTrue);
  });
}
