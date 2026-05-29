import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class UpdateUserProfile {
  final AuthRepository repository;

  UpdateUserProfile(this.repository);

  Future<Either<Failure, User>> call({
    String? displayName,
    String? avatarUrl,
    String? avatarAltText,
    String? bio,
    String? preferredLanguageId,
    int? dailyLearningGoalMinutes,
    String? timezone,
  }) {
    return repository.updateUserProfile(
      displayName: displayName,
      avatarUrl: avatarUrl,
      avatarAltText: avatarAltText,
      bio: bio,
      preferredLanguageId: preferredLanguageId,
      dailyLearningGoalMinutes: dailyLearningGoalMinutes,
      timezone: timezone,
    );
  }
}
