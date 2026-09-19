import 'package:equatable/equatable.dart';

/// Ota-ona ogohlantirish turi.
enum ParentAlertType {
  homeworkAssigned,
  homeworkOverdue,
  homeworkGraded,
  streakAtRisk,
  cheating,
  testMessage;

  String get labelUz => switch (this) {
        ParentAlertType.homeworkAssigned => 'Vazifa berildi',
        ParentAlertType.homeworkOverdue => 'Vazifa o‘tkazib yuborildi',
        ParentAlertType.homeworkGraded => 'Vazifa baholandi',
        ParentAlertType.streakAtRisk => 'Streak xavf ostida',
        ParentAlertType.cheating => 'Nazorat ogohlantirishi',
        ParentAlertType.testMessage => 'Test xabar',
      };

  String get iconHint => switch (this) {
        ParentAlertType.homeworkAssigned => '📚',
        ParentAlertType.homeworkOverdue => '⚠️',
        ParentAlertType.homeworkGraded => '✅',
        ParentAlertType.streakAtRisk => '🔥',
        ParentAlertType.cheating => '👁️',
        ParentAlertType.testMessage => '✉️',
      };
}

/// Yuborilgan / navbatdagi ota-ona xabari.
class ParentAlertLogEntry extends Equatable {
  const ParentAlertLogEntry({
    required this.id,
    required this.type,
    required this.messageUz,
    required this.createdAt,
    required this.channel,
    this.delivered = false,
    this.error,
  });

  final String id;
  final ParentAlertType type;
  final String messageUz;
  final DateTime createdAt;

  /// `telegram` | `local` | `sms`
  final String channel;
  final bool delivered;
  final String? error;

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'messageUz': messageUz,
        'createdAt': createdAt.toIso8601String(),
        'channel': channel,
        'delivered': delivered,
        'error': error,
      };

  factory ParentAlertLogEntry.fromJson(Map<String, dynamic> json) {
    return ParentAlertLogEntry(
      id: json['id'] as String,
      type: ParentAlertType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ParentAlertType.testMessage,
      ),
      messageUz: json['messageUz'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      channel: json['channel'] as String? ?? 'local',
      delivered: json['delivered'] as bool? ?? false,
      error: json['error'] as String?,
    );
  }

  @override
  List<Object?> get props =>
      [id, type, messageUz, createdAt, channel, delivered, error];
}
