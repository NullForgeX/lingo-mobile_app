import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/admin_user.dart';
import '../repositories/admin_repository.dart';

class UpdateAdminUser {
  final AdminRepository repository;

  UpdateAdminUser(this.repository);

  Future<Either<Failure, AdminUser>> call(
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
  }) {
    return repository.updateUser(
      userId,
      displayName: displayName,
      avatarUrl: avatarUrl,
      avatarAltText: avatarAltText,
      bio: bio,
      preferredLanguageId: preferredLanguageId,
      dailyLearningGoalMinutes: dailyLearningGoalMinutes,
      timezone: timezone,
      role: role,
      status: status,
      suspensionReason: suspensionReason,
    );
  }
}
