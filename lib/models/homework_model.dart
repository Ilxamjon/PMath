import 'package:equatable/equatable.dart';

import 'question_model.dart';

/// Uyga vazifa turi.
enum HomeworkType {
  /// Yozma uyga vazifa — daftarga yozish.
  notebook,

  /// Kameradan skanerlangan.
  scanned,

  /// Interaktiv mashq.
  interactive;

  String get labelUz => switch (this) {
        HomeworkType.notebook => 'Yozma uyga vazifa',
        HomeworkType.scanned => 'Skanerlangan',
        HomeworkType.interactive => 'Interaktiv',
      };
}

/// Uyga vazifa holati.
enum HomeworkStatus {
  assigned,
  submitted,
  grading,
  graded,
  needsRevision;

  String get labelUz => switch (this) {
        HomeworkStatus.assigned => 'Berilgan',
        HomeworkStatus.submitted => 'Topshirilgan',
        HomeworkStatus.grading => 'Tekshirilmoqda',
        HomeworkStatus.graded => 'Baholangan',
        HomeworkStatus.needsRevision => 'Qayta ishlash kerak',
      };
}

/// AI tomonidan topilgan xato qadami.
class HomeworkErrorStep extends Equatable {
  const HomeworkErrorStep({
    required this.stepIndex,
    required this.studentStep,
    required this.explanationUz,
    this.correctHintUz,
  });

  final int stepIndex;
  final String studentStep;
  final String explanationUz;
  final String? correctHintUz;

  Map<String, dynamic> toJson() => {
        'stepIndex': stepIndex,
        'studentStep': studentStep,
        'explanationUz': explanationUz,
        'correctHintUz': correctHintUz,
      };

  factory HomeworkErrorStep.fromJson(Map<String, dynamic> json) {
    return HomeworkErrorStep(
      stepIndex: json['stepIndex'] as int,
      studentStep: json['studentStep'] as String,
      explanationUz: json['explanationUz'] as String,
      correctHintUz: json['correctHintUz'] as String?,
    );
  }

  @override
  List<Object?> get props =>
      [stepIndex, studentStep, explanationUz, correctHintUz];
}

/// Yozma uyga vazifa + Vision AI natijasi.
class HomeworkModel extends Equatable {
  const HomeworkModel({
    required this.id,
    required this.lessonId,
    required this.titleUz,
    required this.assignedAt,
    this.type = HomeworkType.notebook,
    this.status = HomeworkStatus.assigned,
    this.problemStatement,
    this.latexFormula,
    this.imagePath,
    this.masteryPercent = 0.0,
    this.errorSteps = const [],
    this.extractedSteps = const [],
    this.ocrRawText,
    this.visionConfidence = 0.0,
    this.aiFeedbackUz,
    this.dueAt,
    this.submittedAt,
    this.gradedAt,
    this.difficulty,
  });

  final String id;
  final String lessonId;
  final String titleUz;
  final DateTime assignedAt;
  final HomeworkType type;
  final HomeworkStatus status;

  final String? problemStatement;
  final String? latexFormula;

  /// Kameradan olingan daftardagi sahifa yo‘li.
  final String? imagePath;

  final double masteryPercent;
  final List<HomeworkErrorStep> errorSteps;

  /// Vision AI ekstraksiya qilgan qadamlar.
  final List<String> extractedSteps;
  final String? ocrRawText;
  final double visionConfidence;

  final String? aiFeedbackUz;

  final DateTime? dueAt;
  final DateTime? submittedAt;
  final DateTime? gradedAt;

  /// Oson / o‘rtacha / qiyin (15 talik to‘plam uchun).
  final QuestionDifficulty? difficulty;

  bool get isPassed => masteryPercent >= 80.0;

  bool get hasVisionExtract => extractedSteps.isNotEmpty;

  bool get isOverdue {
    if (dueAt == null) return false;
    if (status != HomeworkStatus.assigned) return false;
    return DateTime.now().isAfter(dueAt!);
  }

  bool get isPendingScan =>
      status == HomeworkStatus.assigned ||
      status == HomeworkStatus.needsRevision;

  /// Muddatgacha qolgan kunlar (manfiy = kechikkan).
  int get daysUntilDue {
    if (dueAt == null) return 0;
    final now = DateTime.now();
    final due = DateTime(dueAt!.year, dueAt!.month, dueAt!.day);
    final today = DateTime(now.year, now.month, now.day);
    return due.difference(today).inDays;
  }

  HomeworkModel copyWith({
    String? id,
    String? lessonId,
    String? titleUz,
    DateTime? assignedAt,
    HomeworkType? type,
    HomeworkStatus? status,
    String? problemStatement,
    String? latexFormula,
    String? imagePath,
    double? masteryPercent,
    List<HomeworkErrorStep>? errorSteps,
    List<String>? extractedSteps,
    String? ocrRawText,
    double? visionConfidence,
    String? aiFeedbackUz,
    DateTime? dueAt,
    DateTime? submittedAt,
    DateTime? gradedAt,
    QuestionDifficulty? difficulty,
  }) {
    return HomeworkModel(
      id: id ?? this.id,
      lessonId: lessonId ?? this.lessonId,
      titleUz: titleUz ?? this.titleUz,
      assignedAt: assignedAt ?? this.assignedAt,
      type: type ?? this.type,
      status: status ?? this.status,
      problemStatement: problemStatement ?? this.problemStatement,
      latexFormula: latexFormula ?? this.latexFormula,
      imagePath: imagePath ?? this.imagePath,
      masteryPercent: masteryPercent ?? this.masteryPercent,
      errorSteps: errorSteps ?? this.errorSteps,
      extractedSteps: extractedSteps ?? this.extractedSteps,
      ocrRawText: ocrRawText ?? this.ocrRawText,
      visionConfidence: visionConfidence ?? this.visionConfidence,
      aiFeedbackUz: aiFeedbackUz ?? this.aiFeedbackUz,
      dueAt: dueAt ?? this.dueAt,
      submittedAt: submittedAt ?? this.submittedAt,
      gradedAt: gradedAt ?? this.gradedAt,
      difficulty: difficulty ?? this.difficulty,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'lessonId': lessonId,
        'titleUz': titleUz,
        'assignedAt': assignedAt.toIso8601String(),
        'type': type.name,
        'status': status.name,
        'problemStatement': problemStatement,
        'latexFormula': latexFormula,
        'imagePath': imagePath,
        'masteryPercent': masteryPercent,
        'difficulty': difficulty?.name,
        'errorSteps': errorSteps.map((e) => e.toJson()).toList(),
        'extractedSteps': extractedSteps,
        'ocrRawText': ocrRawText,
        'visionConfidence': visionConfidence,
        'aiFeedbackUz': aiFeedbackUz,
        'dueAt': dueAt?.toIso8601String(),
        'submittedAt': submittedAt?.toIso8601String(),
        'gradedAt': gradedAt?.toIso8601String(),
      };

  factory HomeworkModel.fromJson(Map<String, dynamic> json) {
    return HomeworkModel(
      id: json['id'] as String,
      lessonId: json['lessonId'] as String,
      titleUz: json['titleUz'] as String,
      assignedAt: DateTime.parse(json['assignedAt'] as String),
      type: HomeworkType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => HomeworkType.notebook,
      ),
      status: HomeworkStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => HomeworkStatus.assigned,
      ),
      problemStatement: json['problemStatement'] as String?,
      latexFormula: json['latexFormula'] as String?,
      imagePath: json['imagePath'] as String?,
      masteryPercent: (json['masteryPercent'] as num?)?.toDouble() ?? 0.0,
      errorSteps: (json['errorSteps'] as List<dynamic>?)
              ?.map((e) => HomeworkErrorStep.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      extractedSteps: (json['extractedSteps'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      ocrRawText: json['ocrRawText'] as String?,
      visionConfidence: (json['visionConfidence'] as num?)?.toDouble() ?? 0.0,
      aiFeedbackUz: json['aiFeedbackUz'] as String?,
      dueAt: json['dueAt'] != null
          ? DateTime.parse(json['dueAt'] as String)
          : null,
      submittedAt: json['submittedAt'] != null
          ? DateTime.parse(json['submittedAt'] as String)
          : null,
      gradedAt: json['gradedAt'] != null
          ? DateTime.parse(json['gradedAt'] as String)
          : null,
      difficulty: json['difficulty'] != null
          ? QuestionDifficulty.values.firstWhere(
              (e) => e.name == json['difficulty'],
              orElse: () => QuestionDifficulty.medium,
            )
          : null,
    );
  }

  factory HomeworkModel.demo() {
    return HomeworkModel(
      id: 'hw-demo-001',
      lessonId: 'lesson_3',
      titleUz: 'Ko‘paytirish — yozma mashq',
      assignedAt: DateTime.now().subtract(const Duration(hours: 6)),
      dueAt: DateTime.now().add(const Duration(days: 1)),
      problemStatement: '24 × 15 ni bosqichma-bosqich yeching.',
      latexFormula: r'24 \times 15',
      status: HomeworkStatus.assigned,
      type: HomeworkType.notebook,
    );
  }

  @override
  List<Object?> get props => [
        id,
        lessonId,
        titleUz,
        assignedAt,
        type,
        status,
        problemStatement,
        latexFormula,
        imagePath,
        masteryPercent,
        errorSteps,
        extractedSteps,
        ocrRawText,
        visionConfidence,
        aiFeedbackUz,
        dueAt,
        submittedAt,
        gradedAt,
        difficulty,
      ];
}
