import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/notifications_repository.dart';

class GetUnreadCount {
  final NotificationsRepository repository;

  GetUnreadCount(this.repository);

  Future<Either<Failure, int>> call() {
    return repository.getUnreadCount();
  }
}
