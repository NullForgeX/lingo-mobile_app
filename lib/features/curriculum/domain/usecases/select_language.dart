import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../auth/domain/entities/user.dart';
import '../repositories/curriculum_repository.dart';

class SelectLanguage {
  final CurriculumRepository repository;

  SelectLanguage(this.repository);

  Future<Either<Failure, User>> call(String languageId) {
    return repository.selectLanguage(languageId);
  }
}
