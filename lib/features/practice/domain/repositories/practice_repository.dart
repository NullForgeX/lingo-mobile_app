import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/attempt.dart';

abstract class PracticeRepository {
  Future<Either<Failure, Map<String, dynamic>>> getLessonRuntime(String lessonId);
  Future<Either<Failure, QuizAttempt>> startLessonAttempt(String lessonId);
  Future<Either<Failure, Map<String, dynamic>>> submitAttempt(String attemptId, List<Map<String, dynamic>> answers);
}
