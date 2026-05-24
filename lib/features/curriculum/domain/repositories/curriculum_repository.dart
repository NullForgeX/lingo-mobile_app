import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';

abstract class CurriculumRepository {
  Future<Either<Failure, List<dynamic>>> getLanguages();
  Future<Either<Failure, List<dynamic>>> getUnits(String languageId);
  Future<Either<Failure, List<dynamic>>> getLessons(String unitId);
}
