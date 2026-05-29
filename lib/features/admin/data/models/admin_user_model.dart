import '../../domain/entities/admin_user.dart';

class AdminUserModel extends AdminUser {
  const AdminUserModel({
    required super.id,
    required super.email,
    super.displayName,
    super.avatarUrl,
    required super.role,
    required super.status,
    super.bio,
    super.avatarAltText,
    super.preferredLanguageId,
    super.dailyLearningGoalMinutes,
    super.timezone,
    super.suspendedAt,
    super.suspendedByUserId,
    super.suspensionReason,
    super.lastLoginAt,
    super.passwordChangedAt,
    required super.createdAt,
    required super.updatedAt,
  });

  factory AdminUserModel.fromJson(Map<String, dynamic> json) {
    final avatar = json['avatar'] as Map<String, dynamic>?;
    final preferences = json['preferences'] as Map<String, dynamic>?;

    return AdminUserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      role: json['role'] as String,
      status: json['status'] as String,
      bio: json['bio'] as String?,
      avatarAltText: avatar?['altText'] as String?,
      preferredLanguageId: preferences?['preferredLanguageId'] as String?,
      dailyLearningGoalMinutes: preferences?['dailyLearningGoalMinutes'] as int?,
      timezone: preferences?['timezone'] as String?,
      suspendedAt: json['suspendedAt'] != null
          ? DateTime.parse(json['suspendedAt'] as String)
          : null,
      suspendedByUserId: json['suspendedByUserId'] as String?,
      suspensionReason: json['suspensionReason'] as String?,
      lastLoginAt: json['lastLoginAt'] != null
          ? DateTime.parse(json['lastLoginAt'] as String)
          : null,
      passwordChangedAt: json['passwordChangedAt'] != null
          ? DateTime.parse(json['passwordChangedAt'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'avatarUrl': avatarUrl,
      'role': role,
      'status': status,
      'bio': bio,
      'avatar': {
        'url': avatarUrl,
        'altText': avatarAltText,
      },
      'preferences': {
        'preferredLanguageId': preferredLanguageId,
        'dailyLearningGoalMinutes': dailyLearningGoalMinutes,
        'timezone': timezone,
      },
      'suspendedAt': suspendedAt?.toIso8601String(),
      'suspendedByUserId': suspendedByUserId,
      'suspensionReason': suspensionReason,
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'passwordChangedAt': passwordChangedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
