import 'package:flutter_test/flutter_test.dart';
import 'package:pmath/features/proctoring/domain/proctoring_guard.dart';

void main() {
  test('ProctoringGuard session start/end', () {
    final guard = StubProctoringGuard();
    final events = <ProctoringEvent>[];
    guard.addListener(events.add);
    guard.startSession(lessonId: 'l1');
    expect(guard.isActive, isTrue);
    guard.endSession();
    expect(guard.isActive, isFalse);
    expect(events, contains(ProctoringEvent.sessionStarted));
    expect(events, contains(ProctoringEvent.sessionEnded));
  });

  test('ProctoringGuard noFace da pauza va ogohlantirish', () {
    final guard = StubProctoringGuard();
    final events = <ProctoringEvent>[];
    guard.addListener(events.add);
    guard.startSession(lessonId: 'exam1');
    guard.simulate(ProctoringEvent.noFace);
    expect(guard.isPaused, isTrue);
    expect(guard.sessionWarningCount, 1);
    expect(events, contains(ProctoringEvent.noFace));
    guard.resumeAfterWarning();
    expect(guard.isPaused, isFalse);
    expect(events, contains(ProctoringEvent.resumed));
  });
}
