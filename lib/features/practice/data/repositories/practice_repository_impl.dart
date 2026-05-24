import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/practice_repository.dart';
import '../../domain/entities/attempt.dart';
import '../datasources/practice_remote_data_source.dart';

class PracticeRepositoryImpl implements PracticeRepository {
  final PracticeRemoteDataSource remoteDataSource;

  PracticeRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, Map<String, dynamic>>> getLessonRuntime(String lessonId) async {
    try {
      final result = await remoteDataSource.getLessonRuntime(lessonId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, QuizAttempt>> startLessonAttempt(String lessonId) async {
    try {
      final result = await remoteDataSource.startLessonAttempt(lessonId);
      final attempt = QuizAttempt.fromJson(result);
      return Right(attempt);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> submitAttempt(String attemptId, List<Map<String, dynamic>> answers) async {
    try {
      final result = await remoteDataSource.submitAttempt(attemptId, answers);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
