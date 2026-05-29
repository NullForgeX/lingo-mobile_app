import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/error/failures.dart';
import '../../../auth/domain/entities/user.dart';
import '../../domain/repositories/curriculum_repository.dart';
import '../datasources/curriculum_remote_data_source.dart';

class CurriculumRepositoryImpl implements CurriculumRepository {
  final CurriculumRemoteDataSource remoteDataSource;

  CurriculumRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<dynamic>>> getLanguages() async {
    try {
      final result = await remoteDataSource.getLanguages();
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getLanguageDetail(String languageId) async {
    try {
      final result = await remoteDataSource.getLanguageDetail(languageId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<dynamic>>> getUnits(String languageId) async {
    try {
      final result = await remoteDataSource.getUnits(languageId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<dynamic>>> getLessons(String unitId) async {
    try {
      final result = await remoteDataSource.getLessons(unitId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> selectLanguage(String languageId) async {
    try {
      final userModel = await remoteDataSource.selectLanguage(languageId);
      return Right(userModel);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to select language.'));
    } catch (e) {
      return const Left(ServerFailure('An unexpected error occurred.'));
    }
  }
}
