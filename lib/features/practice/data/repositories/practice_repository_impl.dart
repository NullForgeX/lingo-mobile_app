import 'package:dartz/dartz.dart';
import 'package:hive/hive.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/practice_repository.dart';
import '../../domain/entities/attempt.dart';
import '../datasources/practice_remote_data_source.dart';

class PracticeRepositoryImpl implements PracticeRepository {
  final PracticeRemoteDataSource remoteDataSource;

  PracticeRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, Map<String, dynamic>>> getLessonDetail(String lessonId) async {
    final cacheBox = Hive.box('curriculum_cache_box');
    if (cacheBox.containsKey('lesson_detail_$lessonId')) {
      final cached = Map<String, dynamic>.from(cacheBox.get('lesson_detail_$lessonId') as Map);
      return Right(cached);
    }
    try {
      final result = await remoteDataSource.getLessonDetail(lessonId);
      await cacheBox.put('lesson_detail_$lessonId', result);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getLessonRuntime(String lessonId) async {
    final cacheBox = Hive.box('curriculum_cache_box');
    if (cacheBox.containsKey('lesson_runtime_$lessonId')) {
      final cached = Map<String, dynamic>.from(cacheBox.get('lesson_runtime_$lessonId') as Map);
      return Right(cached);
    }
    try {
      final result = await remoteDataSource.getLessonRuntime(lessonId);
      await cacheBox.put('lesson_runtime_$lessonId', result);
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

  @override
  Future<Either<Failure, QuizAttempt>> startExerciseAttempt(String exerciseId) async {
    try {
      final result = await remoteDataSource.startExerciseAttempt(exerciseId);
      final attempt = QuizAttempt.fromJson(result);
      return Right(attempt);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> listAttempts({int page = 1, int pageSize = 20, String order = 'desc'}) async {
    try {
      final result = await remoteDataSource.listAttempts(page: page, pageSize: pageSize, order: order);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, QuizAttempt>> abandonAttempt(String attemptId) async {
    try {
      final result = await remoteDataSource.abandonAttempt(attemptId);
      final attempt = QuizAttempt.fromJson(result);
      return Right(attempt);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
