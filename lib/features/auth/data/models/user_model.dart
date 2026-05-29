import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    required super.displayName,
    super.avatarUrl,
    required super.role,
    required super.status,
    super.preferredLanguageId,
    super.dailyLearningGoalMinutes,
    super.bio,
    super.timezone,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final preferences = json['preferences'] as Map<String, dynamic>?;
    final avatar = json['avatar'] as Map<String, dynamic>?;
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String? ?? avatar?['url'] as String?,
      role: json['role'] as String,
      status: json['status'] as String,
      preferredLanguageId: preferences?['preferredLanguageId'] as String?,
      dailyLearningGoalMinutes: preferences?['dailyLearningGoalMinutes'] as int?,
      bio: json['bio'] as String?,
      timezone: preferences?['timezone'] as String?,
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
        'altText': null,
      },
      'preferences': {
        'preferredLanguageId': preferredLanguageId,
        'dailyLearningGoalMinutes': dailyLearningGoalMinutes,
        'timezone': timezone,
      },
    };
  }
}
