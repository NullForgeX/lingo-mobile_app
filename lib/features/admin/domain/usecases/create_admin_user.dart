import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/admin_user.dart';
import '../repositories/admin_repository.dart';

class CreateAdminUser {
  final AdminRepository repository;

  CreateAdminUser(this.repository);

  Future<Either<Failure, AdminUser>> call({
    required String email,
    required String password,
    String? displayName,
    required String role,
    required String status,
  }) {
    return repository.createUser(
      email: email,
      password: password,
      displayName: displayName,
      role: role,
      status: status,
    );
  }
}
