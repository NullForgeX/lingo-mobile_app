import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/admin_repository.dart';

class RevokeUserSessions {
  final AdminRepository repository;

  RevokeUserSessions(this.repository);

  Future<Either<Failure, void>> call(String userId) {
    return repository.revokeUserSessions(userId);
  }
}
