import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/admin_user.dart';
import '../repositories/admin_repository.dart';

class SuspendUser {
  final AdminRepository repository;

  SuspendUser(this.repository);

  Future<Either<Failure, AdminUser>> call(String userId, String? reason) {
    return repository.suspendUser(userId, reason);
  }
}
