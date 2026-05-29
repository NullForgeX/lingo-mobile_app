import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../auth/domain/entities/user.dart';

abstract class CurriculumRepository {
  Future<Either<Failure, List<dynamic>>> getLanguages();
  Future<Either<Failure, Map<String, dynamic>>> getLanguageDetail(String languageId);
  Future<Either<Failure, List<dynamic>>> getUnits(String languageId);
  Future<Either<Failure, List<dynamic>>> getLessons(String unitId);
  Future<Either<Failure, User>> selectLanguage(String languageId);
}
