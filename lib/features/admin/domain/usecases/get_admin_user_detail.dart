import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/admin_user.dart';
import '../repositories/admin_repository.dart';

class GetAdminUserDetail {
  final AdminRepository repository;

  GetAdminUserDetail(this.repository);

  Future<Either<Failure, AdminUser>> call(String userId) {
    return repository.getUser(userId);
  }
}
