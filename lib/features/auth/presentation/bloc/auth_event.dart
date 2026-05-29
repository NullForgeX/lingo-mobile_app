import 'package:equatable/equatable.dart';
import '../../domain/entities/user.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  const LoginRequested(this.email, this.password);

  @override
  List<Object?> get props => [email, password];
}

class RegisterRequested extends AuthEvent {
  final String email;
  final String password;
  final String displayName;

  const RegisterRequested(this.email, this.password, this.displayName);

  @override
  List<Object?> get props => [email, password, displayName];
}

class LogoutRequested extends AuthEvent {}

class CheckAuthStatus extends AuthEvent {}

class LoadProfileRequested extends AuthEvent {}

class UpdatePreferencesRequested extends AuthEvent {
  final String? displayName;
  final String? avatarUrl;
  final String? avatarAltText;
  final String? bio;
  final String? preferredLanguageId;
  final int? dailyLearningGoalMinutes;
  final String? timezone;

  const UpdatePreferencesRequested({
    this.displayName,
    this.avatarUrl,
    this.avatarAltText,
    this.bio,
    this.preferredLanguageId,
    this.dailyLearningGoalMinutes,
    this.timezone,
  });

  @override
  List<Object?> get props => [
        displayName,
        avatarUrl,
        avatarAltText,
        bio,
        preferredLanguageId,
        dailyLearningGoalMinutes,
        timezone,
      ];
}

class UserProfileUpdated extends AuthEvent {
  final User user;

  const UserProfileUpdated(this.user);

  @override
  List<Object?> get props => [user];
}
