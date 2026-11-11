import 'package:flutter_test/flutter_test.dart';
import 'package:pmath/models/homework_model.dart';
import 'package:pmath/services/vision_ai_service.dart';

void main() {
  test('Vision AI qadamlarni JSON qilib qaytaradi', () async {
    final hw = HomeworkModel.demo();
    final result = await StubVisionAiService().analyzeNotebookPage(
      imagePath: '/tmp/demo.jpg',
      homework: hw,
    );
    expect(result.steps, isNotEmpty);
    expect(result.toJson()['steps'], isA<List>());
    expect(result.confidence, greaterThan(0.5));
  });
}
