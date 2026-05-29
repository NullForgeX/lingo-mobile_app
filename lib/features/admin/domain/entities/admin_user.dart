import 'package:equatable/equatable.dart';

class AdminUser extends Equatable {
  final String id;
  final String email;
  final String? displayName;
  final String? avatarUrl;
  final String role;
  final String status;
  final String? bio;
  final String? avatarAltText;
  final String? preferredLanguageId;
  final int? dailyLearningGoalMinutes;
  final String? timezone;
  final DateTime? suspendedAt;
  final String? suspendedByUserId;
  final String? suspensionReason;
  final DateTime? lastLoginAt;
  final DateTime? passwordChangedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AdminUser({
    required this.id,
    required this.email,
    this.displayName,
    this.avatarUrl,
    required this.role,
    required this.status,
    this.bio,
    this.avatarAltText,
    this.preferredLanguageId,
    this.dailyLearningGoalMinutes,
    this.timezone,
    this.suspendedAt,
    this.suspendedByUserId,
    this.suspensionReason,
    this.lastLoginAt,
    this.passwordChangedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        email,
        displayName,
        avatarUrl,
        role,
        status,
        bio,
        avatarAltText,
        preferredLanguageId,
        dailyLearningGoalMinutes,
        timezone,
        suspendedAt,
        suspendedByUserId,
        suspensionReason,
        lastLoginAt,
        passwordChangedAt,
        createdAt,
        updatedAt,
      ];
}
