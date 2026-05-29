import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login_user.dart';
import '../../domain/usecases/register_user.dart';
import '../../domain/usecases/update_user_profile.dart';
import '../../domain/usecases/get_user_profile.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUser loginUser;
  final RegisterUser registerUser;
  final UpdateUserProfile updateUserProfile;
  final GetUserProfile getUserProfile;
  final AuthRepository authRepository;

  AuthBloc({
    required this.loginUser,
    required this.registerUser,
    required this.updateUserProfile,
    required this.getUserProfile,
    required this.authRepository,
  }) : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<LoadProfileRequested>(_onLoadProfileRequested);
    on<UpdatePreferencesRequested>(_onUpdatePreferencesRequested);
    on<UserProfileUpdated>(_onUserProfileUpdated);
  }

  void _onLoginRequested(LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await loginUser(event.email, event.password);
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  void _onRegisterRequested(RegisterRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await registerUser(event.email, event.password, event.displayName);
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  void _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    await authRepository.logout();
    emit(AuthUnauthenticated());
  }

  void _onCheckAuthStatus(CheckAuthStatus event, Emitter<AuthState> emit) async {
    final result = await authRepository.getCurrentUser();
    result.fold(
      (failure) => emit(AuthUnauthenticated()),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  void _onLoadProfileRequested(LoadProfileRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await getUserProfile();
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  void _onUpdatePreferencesRequested(
      UpdatePreferencesRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await updateUserProfile(
      displayName: event.displayName,
      avatarUrl: event.avatarUrl,
      avatarAltText: event.avatarAltText,
      bio: event.bio,
      preferredLanguageId: event.preferredLanguageId,
      dailyLearningGoalMinutes: event.dailyLearningGoalMinutes,
      timezone: event.timezone,
    );
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  void _onUserProfileUpdated(UserProfileUpdated event, Emitter<AuthState> emit) {
    emit(AuthAuthenticated(event.user));
  }
}
