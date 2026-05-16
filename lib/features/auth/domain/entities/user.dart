import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String email;
  final String displayName;
  final String? avatarUrl;
  final String role;
  final String status;

  const User({
    required this.id,
    required this.email,
    required this.displayName,
    this.avatarUrl,
    required this.role,
    required this.status,
  });

  @override
  List<Object?> get props => [id, email, displayName, avatarUrl, role, status];
}
