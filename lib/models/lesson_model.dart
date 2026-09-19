import 'package:equatable/equatable.dart';

import '../core/constants/app_constants.dart';

/// Dars holati.
enum LessonStatus {
  locked,
  available,
  inProgress,
  completed;

  String get labelUz => switch (this) {
        LessonStatus.locked => 'Qulflangan',
        LessonStatus.available => 'Ochilgan',
        LessonStatus.inProgress => 'Jarayonda',
        LessonStatus.completed => 'Yakunlangan',
      };
}

/// Interaktiv AI dars xonasi modeli.
class LessonModel extends Equatable {
  const LessonModel({
    required this.id,
    required this.titleUz,
    required this.orderIndex,
    required this.topic,
    required this.weekNumber,
    this.status = LessonStatus.locked,
    this.masteryPercent = 0.0,
    this.socraticPrompts = const [],
    this.practiceQuestionIds = const [],
    this.durationMinutes = 15,
    this.coinsReward = 20,
    this.audioScriptUz,
    this.completedAt,
  });

  final String id;
  final String titleUz;
  final int orderIndex;
  final String topic;
  final int weekNumber;
  final LessonStatus status;

  /// 0–100; 80+ bo‘lmasa keyingi dars ochilmaydi.
  final double masteryPercent;

  /// Sokratik usul: yo‘naltiruvchi savollar (to‘g‘ridan-to‘g‘ri javob emas).
  final List<String> socraticPrompts;

  final List<String> practiceQuestionIds;
  final int durationMinutes;
  final int coinsReward;

  /// TTS uchun o‘zbekcha skript.
  final String? audioScriptUz;
  final DateTime? completedAt;

  bool get isUnlockedForNext =>
      masteryPercent >= AppConstants.masteryLockThreshold;

  bool get isExam => topic == 'Imtihon';

  LessonModel copyWith({
    String? id,
    String? titleUz,
    int? orderIndex,
    String? topic,
    int? weekNumber,
    LessonStatus? status,
    double? masteryPercent,
    List<String>? socraticPrompts,
    List<String>? practiceQuestionIds,
    int? durationMinutes,
    int? coinsReward,
    String? audioScriptUz,
    DateTime? completedAt,
  }) {
    return LessonModel(
      id: id ?? this.id,
      titleUz: titleUz ?? this.titleUz,
      orderIndex: orderIndex ?? this.orderIndex,
      topic: topic ?? this.topic,
      weekNumber: weekNumber ?? this.weekNumber,
      status: status ?? this.status,
      masteryPercent: masteryPercent ?? this.masteryPercent,
      socraticPrompts: socraticPrompts ?? this.socraticPrompts,
      practiceQuestionIds: practiceQuestionIds ?? this.practiceQuestionIds,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      coinsReward: coinsReward ?? this.coinsReward,
      audioScriptUz: audioScriptUz ?? this.audioScriptUz,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'titleUz': titleUz,
        'orderIndex': orderIndex,
        'topic': topic,
        'weekNumber': weekNumber,
        'status': status.name,
        'masteryPercent': masteryPercent,
        'socraticPrompts': socraticPrompts,
        'practiceQuestionIds': practiceQuestionIds,
        'durationMinutes': durationMinutes,
        'coinsReward': coinsReward,
        'audioScriptUz': audioScriptUz,
        'completedAt': completedAt?.toIso8601String(),
      };

  factory LessonModel.fromJson(Map<String, dynamic> json) {
    return LessonModel(
      id: json['id'] as String,
      titleUz: json['titleUz'] as String,
      orderIndex: json['orderIndex'] as int,
      topic: json['topic'] as String,
      weekNumber: json['weekNumber'] as int,
      status: LessonStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => LessonStatus.locked,
      ),
      masteryPercent: (json['masteryPercent'] as num?)?.toDouble() ?? 0.0,
      socraticPrompts: (json['socraticPrompts'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      practiceQuestionIds: (json['practiceQuestionIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      durationMinutes: json['durationMinutes'] as int? ?? 15,
      coinsReward: json['coinsReward'] as int? ?? 20,
      audioScriptUz: json['audioScriptUz'] as String?,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
    );
  }

  /// Demo roadmap dars ketma-ketligi.
  static List<LessonModel> demoRoadmap() {
    const titles = [
      ('Natural sonlar', 'Arifmetika'),
      ('Qo‘shish va ayirish', 'Arifmetika'),
      ('Ko‘paytirish jadvali', 'Arifmetika'),
      ('Shakllar va burchaklar', 'Geometriya'),
      ('Perimetr', 'Geometriya'),
      ('Mantiqiy topishmoqlar', 'Mantiq'),
      ('Son ketma-ketliklari', 'Mantiqiy ketma-ketlik'),
      ('Aralash masalalar', 'Aralash'),
      ('Haftalik mini-imtihon', 'Imtihon'),
      ('Chuqur mantiq', 'Mantiq'),
    ];

    return List.generate(titles.length, (i) {
      final (title, topic) = titles[i];
      LessonStatus status;
      double mastery;

      if (i < 2) {
        status = LessonStatus.completed;
        mastery = i == 0 ? 92.0 : 85.0;
      } else if (i == 2) {
        status = LessonStatus.inProgress;
        mastery = 45.0;
      } else if (i == 3) {
        status = LessonStatus.available;
        mastery = 0.0;
      } else {
        status = LessonStatus.locked;
        mastery = 0.0;
      }

      return LessonModel(
        id: 'lesson_${i + 1}',
        titleUz: title,
        orderIndex: i + 1,
        topic: topic,
        weekNumber: (i ~/ 3) + 1,
        status: status,
        masteryPercent: mastery,
        socraticPrompts: const [],
        audioScriptUz: '',
        coinsReward: 15 + (i * 5),
      );
    });
  }

  @override
  List<Object?> get props => [
        id,
        titleUz,
        orderIndex,
        topic,
        weekNumber,
        status,
        masteryPercent,
        socraticPrompts,
        practiceQuestionIds,
        durationMinutes,
        coinsReward,
        audioScriptUz,
        completedAt,
      ];
}
