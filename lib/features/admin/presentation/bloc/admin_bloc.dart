import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/create_admin_user.dart';
import '../../domain/usecases/get_admin_user_detail.dart';
import '../../domain/usecases/get_admin_users.dart';
import '../../domain/usecases/reactivate_user.dart';
import '../../domain/usecases/revoke_user_sessions.dart';
import '../../domain/usecases/suspend_user.dart';
import '../../domain/usecases/update_admin_user.dart';
import 'admin_event.dart';
import 'admin_state.dart';

class AdminBloc extends Bloc<AdminEvent, AdminState> {
  final GetAdminUsers getAdminUsers;
  final GetAdminUserDetail getAdminUserDetail;
  final CreateAdminUser createAdminUser;
  final UpdateAdminUser updateAdminUser;
  final SuspendUser suspendUser;
  final ReactivateUser reactivateUser;
  final RevokeUserSessions revokeUserSessions;

  AdminBloc({
    required this.getAdminUsers,
    required this.getAdminUserDetail,
    required this.createAdminUser,
    required this.updateAdminUser,
    required this.suspendUser,
    required this.reactivateUser,
    required this.revokeUserSessions,
  }) : super(AdminInitial()) {
    on<LoadUsersEvent>(_onLoadUsers);
    on<LoadUserDetailEvent>(_onLoadUserDetail);
    on<CreateUserEvent>(_onCreateUser);
    on<UpdateUserEvent>(_onUpdateUser);
    on<SuspendUserEvent>(_onSuspendUser);
    on<ReactivateUserEvent>(_onReactivateUser);
    on<RevokeSessionsEvent>(_onRevokeSessions);
  }

  Future<void> _onLoadUsers(LoadUsersEvent event, Emitter<AdminState> emit) async {
    emit(AdminLoading());
    final result = await getAdminUsers(
      page: event.page,
      pageSize: event.pageSize,
      search: event.search,
      role: event.role,
      status: event.status,
      sort: event.sort,
      order: event.order,
    );
    result.fold(
      (failure) => emit(AdminErrorState(failure.message)),
      (data) => emit(UsersLoadedState(
        users: data['items'],
        pagination: data['pagination'],
      )),
    );
  }

  Future<void> _onLoadUserDetail(LoadUserDetailEvent event, Emitter<AdminState> emit) async {
    emit(AdminLoading());
    final result = await getAdminUserDetail(event.userId);
    result.fold(
      (failure) => emit(AdminErrorState(failure.message)),
      (user) => emit(UserDetailLoadedState(user)),
    );
  }

  Future<void> _onCreateUser(CreateUserEvent event, Emitter<AdminState> emit) async {
    emit(AdminLoading());
    final result = await createAdminUser(
      email: event.email,
      password: event.password,
      displayName: event.displayName,
      role: event.role,
      status: event.status,
    );
    result.fold(
      (failure) => emit(AdminErrorState(failure.message)),
      (user) => emit(const AdminActionSuccess('User created successfully')),
    );
  }

  Future<void> _onUpdateUser(UpdateUserEvent event, Emitter<AdminState> emit) async {
    emit(AdminLoading());
    final result = await updateAdminUser(
      event.userId,
      displayName: event.displayName,
      avatarUrl: event.avatarUrl,
      avatarAltText: event.avatarAltText,
      bio: event.bio,
      preferredLanguageId: event.preferredLanguageId,
      dailyLearningGoalMinutes: event.dailyLearningGoalMinutes,
      timezone: event.timezone,
      role: event.role,
      status: event.status,
    );
    result.fold(
      (failure) => emit(AdminErrorState(failure.message)),
      (user) => emit(const AdminActionSuccess('User details updated successfully')),
    );
  }

  Future<void> _onSuspendUser(SuspendUserEvent event, Emitter<AdminState> emit) async {
    emit(AdminLoading());
    final result = await suspendUser(event.userId, event.reason);
    result.fold(
      (failure) => emit(AdminErrorState(failure.message)),
      (user) => emit(const AdminActionSuccess('User suspended successfully')),
    );
  }

  Future<void> _onReactivateUser(ReactivateUserEvent event, Emitter<AdminState> emit) async {
    emit(AdminLoading());
    final result = await reactivateUser(event.userId);
    result.fold(
      (failure) => emit(AdminErrorState(failure.message)),
      (user) => emit(const AdminActionSuccess('User reactivated successfully')),
    );
  }

  Future<void> _onRevokeSessions(RevokeSessionsEvent event, Emitter<AdminState> emit) async {
    emit(AdminLoading());
    final result = await revokeUserSessions(event.userId);
    result.fold(
      (failure) => emit(AdminErrorState(failure.message)),
      (_) => emit(const AdminActionSuccess('User sessions revoked successfully')),
    );
  }
}
