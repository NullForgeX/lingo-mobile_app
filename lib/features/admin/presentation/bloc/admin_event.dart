import 'package:equatable/equatable.dart';

abstract class AdminEvent extends Equatable {
  const AdminEvent();

  @override
  List<Object?> get props => [];
}

class LoadUsersEvent extends AdminEvent {
  final int page;
  final int pageSize;
  final String? search;
  final String? role;
  final String? status;
  final String? sort;
  final String? order;

  const LoadUsersEvent({
    required this.page,
    this.pageSize = 10,
    this.search,
    this.role,
    this.status,
    this.sort,
    this.order,
  });

  @override
  List<Object?> get props => [page, pageSize, search, role, status, sort, order];
}

class LoadUserDetailEvent extends AdminEvent {
  final String userId;

  const LoadUserDetailEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}

class CreateUserEvent extends AdminEvent {
  final String email;
  final String password;
  final String? displayName;
  final String role;
  final String status;

  const CreateUserEvent({
    required this.email,
    required this.password,
    this.displayName,
    required this.role,
    required this.status,
  });

  @override
  List<Object?> get props => [email, password, displayName, role, status];
}

class UpdateUserEvent extends AdminEvent {
  final String userId;
  final String? displayName;
  final String? avatarUrl;
  final String? avatarAltText;
  final String? bio;
  final String? preferredLanguageId;
  final int? dailyLearningGoalMinutes;
  final String? timezone;
  final String? role;
  final String? status;

  const UpdateUserEvent({
    required this.userId,
    this.displayName,
    this.avatarUrl,
    this.avatarAltText,
    this.bio,
    this.preferredLanguageId,
    this.dailyLearningGoalMinutes,
    this.timezone,
    this.role,
    this.status,
  });

  @override
  List<Object?> get props => [
        userId,
        displayName,
        avatarUrl,
        avatarAltText,
        bio,
        preferredLanguageId,
        dailyLearningGoalMinutes,
        timezone,
        role,
        status,
      ];
}

class SuspendUserEvent extends AdminEvent {
  final String userId;
  final String? reason;

  const SuspendUserEvent({required this.userId, this.reason});

  @override
  List<Object?> get props => [userId, reason];
}

class ReactivateUserEvent extends AdminEvent {
  final String userId;

  const ReactivateUserEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}

class RevokeSessionsEvent extends AdminEvent {
  final String userId;

  const RevokeSessionsEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}
