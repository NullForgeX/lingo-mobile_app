import 'package:equatable/equatable.dart';
import '../../domain/entities/admin_user.dart';

abstract class AdminState extends Equatable {
  const AdminState();

  @override
  List<Object?> get props => [];
}

class AdminInitial extends AdminState {}

class AdminLoading extends AdminState {}

class UsersLoadedState extends AdminState {
  final List<AdminUser> users;
  final Map<String, dynamic> pagination;

  const UsersLoadedState({required this.users, required this.pagination});

  @override
  List<Object?> get props => [users, pagination];
}

class UserDetailLoadedState extends AdminState {
  final AdminUser user;

  const UserDetailLoadedState(this.user);

  @override
  List<Object?> get props => [user];
}

class AdminActionSuccess extends AdminState {
  final String message;

  const AdminActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class AdminErrorState extends AdminState {
  final String message;

  const AdminErrorState(this.message);

  @override
  List<Object?> get props => [message];
}
