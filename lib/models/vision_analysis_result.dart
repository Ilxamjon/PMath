import 'package:equatable/equatable.dart';

/// Vision AI / OCR natijasi — qadamlar JSON.
class VisionAnalysisResult extends Equatable {
  const VisionAnalysisResult({
    required this.imagePath,
    required this.rawText,
    required this.steps,
    required this.confidence,
    this.modelName = 'local-stub-v1',
  });

  final String imagePath;
  final String rawText;

  /// Daftardagi yechim qadamlari (ekstraksiya).
  final List<String> steps;

  /// 0.0 – 1.0
  final double confidence;
  final String modelName;

  Map<String, dynamic> toJson() => {
        'imagePath': imagePath,
        'rawText': rawText,
        'steps': steps,
        'confidence': confidence,
        'modelName': modelName,
      };

  factory VisionAnalysisResult.fromJson(Map<String, dynamic> json) {
    return VisionAnalysisResult(
      imagePath: json['imagePath'] as String? ?? '',
      rawText: json['rawText'] as String? ?? '',
      steps: (json['steps'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0,
      modelName: json['modelName'] as String? ?? 'local-stub-v1',
    );
  }

  @override
  List<Object?> get props =>
      [imagePath, rawText, steps, confidence, modelName];
}
