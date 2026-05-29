import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/admin_user.dart';

abstract class AdminRepository {
  Future<Either<Failure, Map<String, dynamic>>> getUsers({
    required int page,
    required int pageSize,
    String? search,
    String? role,
    String? status,
    String? sort,
    String? order,
  });

  Future<Either<Failure, AdminUser>> getUser(String userId);

  Future<Either<Failure, AdminUser>> createUser({
    required String email,
    required String password,
    String? displayName,
    required String role,
    required String status,
  });

  Future<Either<Failure, AdminUser>> updateUser(
    String userId, {
    String? displayName,
    String? avatarUrl,
    String? avatarAltText,
    String? bio,
    String? preferredLanguageId,
    int? dailyLearningGoalMinutes,
    String? timezone,
    String? role,
    String? status,
    String? suspensionReason,
  });

  Future<Either<Failure, AdminUser>> suspendUser(String userId, String? reason);

  Future<Either<Failure, AdminUser>> reactivateUser(String userId);

  Future<Either<Failure, void>> revokeUserSessions(String userId);
}
