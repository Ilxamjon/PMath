import 'package:flutter_test/flutter_test.dart';
import 'package:pmath/models/homework_model.dart';
import 'package:pmath/services/supabase_gateway.dart';
import 'package:pmath/services/vision_ai_service.dart';

class _FakeEdge implements EdgeInvoker {
  _FakeEdge(this.responses);

  final List<FunctionResult?> responses;
  var calls = 0;
  final bodies = <Map<String, dynamic>>[];

  @override
  bool get isReady => true;

  @override
  Future<FunctionResult?> invoke(
    String name,
    Map<String, dynamic> body, {
    Duration? timeout,
  }) async {
    bodies.add(body);
    final index = calls;
    calls += 1;
    return responses[index];
  }
}

Map<String, dynamic> _ok(List<Map<String, dynamic>> steps, double confidence) {
  return <String, dynamic>{
    'rawText': '12 + 7',
    'confidence': confidence,
    'modelName': 'gemini-2.0-flash',
    'steps': steps,
  };
}

void main() {
  const steps = [
    {'index': 1, 'text': '12 + 7'},
    {'index': 2, 'text': '19', 'latex': '19'},
  ];

  test('to‘g‘ri JSON qadamlarga aylanadi', () async {
    final edge = _FakeEdge([
      FunctionResult(
        statusCode: 200,
        json: _ok(steps, 0.91),
      ),
    ]);
    final deleted = <String>[];
    final service = RemoteVisionAiService(
      gateway: edge,
      encode: (_) async => [1, 2, 3],
      deleteFile: (path) async => deleted.add(path),
    );

    final result = await service.analyzeNotebookPage(
      imagePath: '/tmp/page.jpg',
      homework: HomeworkModel.demo(),
    );

    expect(edge.calls, 1);
    expect(edge.bodies.single['mimeType'], 'image/jpeg');
    expect(result.steps, ['12 + 7', '19\n19']);
    expect(result.confidence, 0.91);
    expect(mustConfirmSteps(result), isFalse);
    expect(deleted, ['/tmp/page.jpg']);
  });

  test('buzuq JSON bir marta qayta urinadi, keyin xato', () async {
    final edge = _FakeEdge([
      FunctionResult(statusCode: 422, json: <String, dynamic>{'error': 'invalid_schema'}),
      FunctionResult(
        statusCode: 200,
        json: {'confidence': 0.9, 'steps': 'yo‘q'},
      ),
    ]);
    final service = RemoteVisionAiService(
      gateway: edge,
      encode: (_) async => [9],
      deleteFile: (_) async {},
    );

    await expectLater(
      service.analyzeNotebookPage(
        imagePath: '/tmp/bad.jpg',
        homework: HomeworkModel.demo(),
      ),
      throwsA(isA<VisionAnalysisException>()),
    );
    expect(edge.calls, 2);
  });

  test('past ishonch tasdiq talab qiladi va baholanmaydi', () async {
    final edge = _FakeEdge([
      FunctionResult(
        statusCode: 200,
        json: _ok(steps, 0.4),
      ),
    ]);
    var graded = 0;
    final service = RemoteVisionAiService(
      gateway: edge,
      encode: (_) async => [4],
      deleteFile: (_) async {},
    );

    final result = await service.analyzeNotebookPage(
      imagePath: '/tmp/low.jpg',
      homework: HomeworkModel.demo(),
    );

    if (!mustConfirmSteps(result)) graded += 1;
    expect(mustConfirmSteps(result), isTrue);
    expect(graded, 0);
    expect(result.confidence, lessThan(visionConfirmThreshold));
  });

  test('release stub ishlatmaydi', () {
    final service = createVisionService(
      allowStub: false,
      cloudReady: false,
      gateway: _FakeEdge(const []),
    );
    expect(service, isA<RemoteVisionAiService>());
  });
}
