import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';

abstract class HomeRepository {
  Future<Either<Failure, Map<String, dynamic>>> getDashboard();
  Future<Either<Failure, Map<String, dynamic>>> getLeaderboard({int page = 1, int pageSize = 20, String order = 'desc'});
}
