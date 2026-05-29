import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String email;
  final String displayName;
  final String? avatarUrl;
  final String role;
  final String status;
  final String? preferredLanguageId;
  final int? dailyLearningGoalMinutes;
  final String? bio;
  final String? timezone;

  const User({
    required this.id,
    required this.email,
    required this.displayName,
    this.avatarUrl,
    required this.role,
    required this.status,
    this.preferredLanguageId,
    this.dailyLearningGoalMinutes,
    this.bio,
    this.timezone,
  });

  @override
  List<Object?> get props => [
        id,
        email,
        displayName,
        avatarUrl,
        role,
        status,
        preferredLanguageId,
        dailyLearningGoalMinutes,
        bio,
        timezone,
      ];
}
