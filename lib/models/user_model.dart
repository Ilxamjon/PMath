import 'package:equatable/equatable.dart';

/// O‘quvchi sinfi: 3-yoki 4-sinf.
enum StudentGrade {
  grade3,
  grade4;

  String get labelUz => switch (this) {
        StudentGrade.grade3 => '3-sinf',
        StudentGrade.grade4 => '4-sinf',
      };

  int get number => switch (this) {
        StudentGrade.grade3 => 3,
        StudentGrade.grade4 => 4,
      };

  static StudentGrade fromInt(int value) =>
      value == 4 ? StudentGrade.grade4 : StudentGrade.grade3;
}

/// Obuna holati.
enum SubscriptionStatus {
  trial,
  active,
  expired,
  none;

  String get labelUz => switch (this) {
        SubscriptionStatus.trial => 'Sinov muddati',
        SubscriptionStatus.active => 'Faol obuna',
        SubscriptionStatus.expired => 'Muddati tugagan',
        SubscriptionStatus.none => 'Obuna yo‘q',
      };
}

/// Foydalanuvchi (o‘quvchi + ota-ona aloqasi) modeli.
class UserModel extends Equatable {
  const UserModel({
    required this.id,
    required this.studentName,
    required this.grade,
    required this.targetSchool,
    required this.parentPhone,
    required this.createdAt,
    this.avatarId = 'default',
    this.coins = 0,
    this.xp = 0,
    this.level = 1,
    this.streakDays = 0,
    this.lastActiveDate,
    this.subscriptionStatus = SubscriptionStatus.trial,
    this.subscriptionExpiresAt,
    this.trialStartedAt,
    this.serverNowAtFetch,
    this.deviceObservedAt,
    this.totalStudyMinutes = 0,
    this.cheatingWarnings = 0,
    this.telegramChatId,
  });

  final String id;
  final String studentName;
  final StudentGrade grade;
  final String targetSchool;
  final String parentPhone;
  final DateTime createdAt;
  final String avatarId;
  final int coins;
  final int xp;
  final int level;
  final int streakDays;
  final DateTime? lastActiveDate;
  final SubscriptionStatus subscriptionStatus;
  final DateTime? subscriptionExpiresAt;

  /// Serverdagi sinov boshi. Kesh.
  final DateTime? trialStartedAt;

  /// So‘rov paytidagi server vaqti.
  final DateTime? serverNowAtFetch;

  /// Shu javob kelgan paytdagi qurilma vaqti. Faqat kesh yoshi uchun.
  final DateTime? deviceObservedAt;
  final int totalStudyMinutes;
  final int cheatingWarnings;

  /// Ota-ona Telegram chat_id (Bot orqali xabar uchun).
  final String? telegramChatId;

  /// Sinov tugashiga qolgan kun. Server vaqti + faqat oldinga siljish.
  int trialDaysLeftAt(DateTime deviceNow) {
    final expires = subscriptionExpiresAt;
    final serverNow = serverNowAtFetch;
    final observed = deviceObservedAt;
    if (expires == null || serverNow == null || observed == null) return 0;
    final elapsed = deviceNow.difference(observed);
    final forward = elapsed.isNegative ? Duration.zero : elapsed;
    final effective = serverNow.add(forward);
    if (!effective.isBefore(expires)) return 0;
    final seconds = expires.difference(effective).inSeconds;
    if (seconds <= 0) return 0;
    return (seconds / Duration.secondsPerDay).ceil();
  }

  int get trialDaysLeft => trialDaysLeftAt(DateTime.now());

  /// Soatni orqaga surish muddatni uzaytirmaydi.
  bool hasAccessAt(DateTime deviceNow) {
    final expires = subscriptionExpiresAt;
    final serverNow = serverNowAtFetch;
    final observed = deviceObservedAt;
    if (expires == null || serverNow == null || observed == null) {
      return false;
    }
    final elapsed = deviceNow.difference(observed);
    final forward = elapsed.isNegative ? Duration.zero : elapsed;
    return serverNow.add(forward).isBefore(expires);
  }

  bool get hasAccessBeyondTrial => hasAccessAt(DateTime.now());

  UserModel copyWith({
    String? id,
    String? studentName,
    StudentGrade? grade,
    String? targetSchool,
    String? parentPhone,
    DateTime? createdAt,
    String? avatarId,
    int? coins,
    int? xp,
    int? level,
    int? streakDays,
    DateTime? lastActiveDate,
    SubscriptionStatus? subscriptionStatus,
    DateTime? subscriptionExpiresAt,
    DateTime? trialStartedAt,
    DateTime? serverNowAtFetch,
    DateTime? deviceObservedAt,
    int? totalStudyMinutes,
    int? cheatingWarnings,
    String? telegramChatId,
    bool clearTelegramChatId = false,
  }) {
    return UserModel(
      id: id ?? this.id,
      studentName: studentName ?? this.studentName,
      grade: grade ?? this.grade,
      targetSchool: targetSchool ?? this.targetSchool,
      parentPhone: parentPhone ?? this.parentPhone,
      createdAt: createdAt ?? this.createdAt,
      avatarId: avatarId ?? this.avatarId,
      coins: coins ?? this.coins,
      xp: xp ?? this.xp,
      level: level ?? this.level,
      streakDays: streakDays ?? this.streakDays,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
      subscriptionStatus: subscriptionStatus ?? this.subscriptionStatus,
      subscriptionExpiresAt: subscriptionExpiresAt ?? this.subscriptionExpiresAt,
      trialStartedAt: trialStartedAt ?? this.trialStartedAt,
      serverNowAtFetch: serverNowAtFetch ?? this.serverNowAtFetch,
      deviceObservedAt: deviceObservedAt ?? this.deviceObservedAt,
      totalStudyMinutes: totalStudyMinutes ?? this.totalStudyMinutes,
      cheatingWarnings: cheatingWarnings ?? this.cheatingWarnings,
      telegramChatId: clearTelegramChatId
          ? null
          : (telegramChatId ?? this.telegramChatId),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'studentName': studentName,
        'grade': grade.number,
        'targetSchool': targetSchool,
        'parentPhone': parentPhone,
        'createdAt': createdAt.toIso8601String(),
        'avatarId': avatarId,
        'coins': coins,
        'xp': xp,
        'level': level,
        'streakDays': streakDays,
        'lastActiveDate': lastActiveDate?.toIso8601String(),
        'subscriptionStatus': subscriptionStatus.name,
        'subscriptionExpiresAt': subscriptionExpiresAt?.toIso8601String(),
        'trialStartedAt': trialStartedAt?.toIso8601String(),
        'serverNowAtFetch': serverNowAtFetch?.toIso8601String(),
        'deviceObservedAt': deviceObservedAt?.toIso8601String(),
        'totalStudyMinutes': totalStudyMinutes,
        'cheatingWarnings': cheatingWarnings,
        'telegramChatId': telegramChatId,
      };

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      studentName: json['studentName'] as String,
      grade: StudentGrade.fromInt(json['grade'] as int),
      targetSchool: json['targetSchool'] as String,
      parentPhone: json['parentPhone'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      avatarId: json['avatarId'] as String? ?? 'default',
      coins: json['coins'] as int? ?? 0,
      xp: json['xp'] as int? ?? ((json['level'] as int? ?? 1) - 1) * 100,
      level: json['level'] as int? ?? 1,
      streakDays: json['streakDays'] as int? ?? 0,
      lastActiveDate: json['lastActiveDate'] != null
          ? DateTime.parse(json['lastActiveDate'] as String)
          : null,
      subscriptionStatus: SubscriptionStatus.values.firstWhere(
        (e) => e.name == json['subscriptionStatus'],
        orElse: () => SubscriptionStatus.trial,
      ),
      subscriptionExpiresAt: json['subscriptionExpiresAt'] != null
          ? DateTime.parse(json['subscriptionExpiresAt'] as String)
          : null,
      trialStartedAt: json['trialStartedAt'] != null
          ? DateTime.parse(json['trialStartedAt'] as String)
          : null,
      serverNowAtFetch: json['serverNowAtFetch'] != null
          ? DateTime.parse(json['serverNowAtFetch'] as String)
          : null,
      deviceObservedAt: json['deviceObservedAt'] != null
          ? DateTime.parse(json['deviceObservedAt'] as String)
          : null,
      totalStudyMinutes: json['totalStudyMinutes'] as int? ?? 0,
      cheatingWarnings: json['cheatingWarnings'] as int? ?? 0,
      telegramChatId: json['telegramChatId'] as String?,
    );
  }

  /// Demo foydalanuvchi (UI preview uchun).
  factory UserModel.demo() {
    return UserModel(
      id: 'demo-user-001',
      studentName: 'Ali',
      grade: StudentGrade.grade4,
      targetSchool: 'Prezident maktabi',
      parentPhone: '+998901234567',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      coins: 120,
      xp: 220,
      level: 3,
      streakDays: 5,
      lastActiveDate: DateTime.now(),
      totalStudyMinutes: 185,
      cheatingWarnings: 1,
    );
  }

  @override
  List<Object?> get props => [
        id,
        studentName,
        grade,
        targetSchool,
        parentPhone,
        createdAt,
        avatarId,
        coins,
        xp,
        level,
        streakDays,
        lastActiveDate,
        subscriptionStatus,
        subscriptionExpiresAt,
        trialStartedAt,
        serverNowAtFetch,
        deviceObservedAt,
        totalStudyMinutes,
        cheatingWarnings,
        telegramChatId,
      ];
}
