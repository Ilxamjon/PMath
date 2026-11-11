import 'package:flutter_test/flutter_test.dart';
import 'package:pmath/models/lesson_model.dart';
import 'package:pmath/services/ai_tutor_service.dart';

void main() {
  const lesson = LessonModel(
    id: 'l1',
    titleUz: 'Qo‘shish',
    topic: 'Natural sonlar',
    weekNumber: 1,
    orderIndex: 0,
  );

  final leak = RegExp(
    r'(javob|natija|yechim)\s*[:=\-]\s*[-+]?\d',
    caseSensitive: false,
  );

  test('to‘g‘ri (o‘zbek apostrofi) yakuniy javob ochmaydi', () async {
    final tutor = AiTutorService();
    final reply = await tutor.coachReply(
      studentText: 'bu to\u2018g\u2018rimi',
      lesson: lesson,
    );
    expect(reply, contains('Yakuniy javobni aytmayman'));
    expect(leak.hasMatch(reply), isFalse);
    expect(RegExp(r'\d').hasMatch(reply), isFalse);
  });

  test('toʻgʻri (oʻ apostrofi) yakuniy javob ochmaydi', () async {
    final tutor = AiTutorService();
    final reply = await tutor.coachReply(
      studentText: 'bu to\u02BBg\u02BBri',
      lesson: lesson,
    );
    expect(reply, contains('Yakuniy javobni aytmayman'));
    expect(leak.hasMatch(reply), isFalse);
    expect(RegExp(r'\d').hasMatch(reply), isFalse);
  });

  test("to'g'ri (ASCII apostrof) yakuniy javob ochmaydi", () async {
    final tutor = AiTutorService();
    final reply = await tutor.coachReply(
      studentText: "bu to'g'rimi",
      lesson: lesson,
    );
    expect(reply, contains('Yakuniy javobni aytmayman'));
    expect(leak.hasMatch(reply), isFalse);
    expect(RegExp(r'\d').hasMatch(reply), isFalse);
  });

  test('javob ayt so‘rovi raqamli yechim qaytarmaydi', () async {
    final tutor = AiTutorService();
    final reply = await tutor.coachReply(
      studentText: 'javob ayt',
      lesson: lesson,
    );
    expect(tutor.isCloudEnabled, isFalse);
    expect(reply, contains('Yakuniy javobni aytmayman'));
    expect(leak.hasMatch(reply), isFalse);
    expect(RegExp(r'\d').hasMatch(reply), isFalse);
  });
}
