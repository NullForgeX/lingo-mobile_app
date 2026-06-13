import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login_user.dart';
import '../../domain/usecases/register_user.dart';
import '../../domain/usecases/update_user_profile.dart';
import '../../domain/usecases/get_user_profile.dart';
import '../../domain/entities/user.dart';
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
    on<EnterGuestMode>(_onEnterGuestMode);
  }

  void _onLoginRequested(LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await loginUser(event.email, event.password);
    await result.fold(
      (failure) async => emit(AuthError(failure.message)),
      (user) async {
        await _syncAllOfflineAttempts(emit, user);
      },
    );
  }

  void _onRegisterRequested(RegisterRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await registerUser(event.email, event.password, event.displayName);
    await result.fold(
      (failure) async => emit(AuthError(failure.message)),
      (user) async {
        await _syncAllOfflineAttempts(emit, user);
      },
    );
  }

  void _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    await authRepository.logout();
    
    // Clear guest persistence flag on logout
    final prefBox = Hive.box('auth_preferences_box');
    await prefBox.put('isGuest', false);
    
    // Clear guest data
    final attemptsBox = Hive.box('guest_attempts_box');
    await attemptsBox.clear();
    final dashboardBox = Hive.box('guest_dashboard_box');
    await dashboardBox.clear();

    emit(AuthUnauthenticated());
  }

  void _onCheckAuthStatus(CheckAuthStatus event, Emitter<AuthState> emit) async {
    final result = await authRepository.getCurrentUser();
    await result.fold(
      (failure) async {
        // If server auth check fails, automatically transition to Guest Mode
        final box = Hive.box('auth_preferences_box');
        await box.put('isGuest', true);
        emit(AuthGuest());
      },
      (user) async {
        // Successful auto-login, sync if anything pending
        final prefBox = Hive.box('auth_preferences_box');
        await prefBox.put('isGuest', false);
        await _syncAllOfflineAttempts(emit, user);
      },
    );
  }

  void _onLoadProfileRequested(LoadProfileRequested event, Emitter<AuthState> emit) async {
    if (state is AuthGuest) {
      // Return guest profile dummy or bypass
      emit(AuthGuest());
      return;
    }
    emit(AuthLoading());
    final result = await getUserProfile();
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  void _onUpdatePreferencesRequested(
      UpdatePreferencesRequested event, Emitter<AuthState> emit) async {
    if (state is AuthGuest) {
      emit(AuthLoading());
      final box = Hive.box('guest_dashboard_box');
      final dashboard = Map<String, dynamic>.from(box.get('dashboard', defaultValue: <String, dynamic>{}) as Map);
      
      // Update preferred language locally
      if (event.preferredLanguageId != null) {
        final prefLang = Map<String, dynamic>.from((dashboard['preferredLanguage'] ?? <String, dynamic>{}) as Map);
        prefLang['id'] = event.preferredLanguageId;
        if (event.preferredLanguageId == 'amharic' || event.preferredLanguageId == '1' || event.preferredLanguageId == '6a12c216c24497386f0a9bc0') {
          prefLang['name'] = 'Amharic';
          prefLang['nativeName'] = 'አማርኛ';
          prefLang['script'] = 'Ge\'ez';
          prefLang['summary'] = 'Official language of Ethiopia';
        } else if (event.preferredLanguageId == 'oromo' || event.preferredLanguageId == '2' || event.preferredLanguageId == '6a12cc0ea612e8468f3a13f0') {
          prefLang['name'] = 'Oromo';
          prefLang['nativeName'] = 'Afaan Oromoo';
          prefLang['script'] = 'Latin';
          prefLang['summary'] = 'Most widely spoken in Ethiopia';
        } else {
          prefLang['name'] = 'Tigrinya';
          prefLang['nativeName'] = 'ትግርኛ';
          prefLang['script'] = 'Ge\'ez';
          prefLang['summary'] = 'Spoken in northern Ethiopia';
        }
        dashboard['preferredLanguage'] = prefLang;
      }
      
      if (event.dailyLearningGoalMinutes != null) {
        dashboard['dailyLearningGoalMinutes'] = event.dailyLearningGoalMinutes;
      }
      
      await box.put('dashboard', dashboard);
      emit(AuthGuest());
      return;
    }

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
    if (state is AuthGuest || event.user.id == 'guest') {
      emit(AuthGuest());
    } else {
      emit(AuthAuthenticated(event.user));
    }
  }

  void _onEnterGuestMode(EnterGuestMode event, Emitter<AuthState> emit) async {
    final box = Hive.box('auth_preferences_box');
    await box.put('isGuest', true);
    emit(AuthGuest());
  }

  Future<void> _syncAllOfflineAttempts(Emitter<AuthState> emit, User user) async {
    final guestBox = Hive.box('guest_attempts_box');
    final authBox = Hive.box('auth_attempts_box');
    final prefBox = Hive.box('auth_preferences_box');
    
    await prefBox.put('isGuest', false);

    User currentUser = user;

    // 1. Sync guest attempts if any
    if (guestBox.isNotEmpty) {
      try {
        final attempts = guestBox.values
            .map((val) => Map<String, dynamic>.from(val as Map))
            .toList();
        final result = await authRepository.syncOfflineAttempts(attempts);
        await result.fold(
          (failure) async {},
          (syncedUser) async {
            await guestBox.clear();
            currentUser = syncedUser;
          },
        );
      } catch (_) {}
    }

    // 2. Sync authenticated attempts if any
    if (authBox.isNotEmpty) {
      try {
        final attempts = authBox.values
            .map((val) => Map<String, dynamic>.from(val as Map))
            .toList();
        final result = await authRepository.syncOfflineAttempts(attempts);
        await result.fold(
          (failure) async {},
          (syncedUser) async {
            await authBox.clear();
            currentUser = syncedUser;
          },
        );
      } catch (_) {}
    }

    emit(AuthAuthenticated(currentUser));
  }
}

