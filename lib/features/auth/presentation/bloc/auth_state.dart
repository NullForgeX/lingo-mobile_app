import 'package:equatable/equatable.dart';
import '../../domain/entities/user.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final User user;
  final bool isSyncing;
  final bool syncFailed;

  const AuthAuthenticated(
    this.user, {
    this.isSyncing = false,
    this.syncFailed = false,
  });

  AuthAuthenticated copyWith({
    User? user,
    bool? isSyncing,
    bool? syncFailed,
  }) {
    return AuthAuthenticated(
      user ?? this.user,
      isSyncing: isSyncing ?? this.isSyncing,
      syncFailed: syncFailed ?? this.syncFailed,
    );
  }

  @override
  List<Object?> get props => [user, isSyncing, syncFailed];
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

class AuthGuest extends AuthState {}

