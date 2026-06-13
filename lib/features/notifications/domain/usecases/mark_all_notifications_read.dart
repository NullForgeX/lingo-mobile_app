import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/notifications_repository.dart';

class MarkAllNotificationsRead {
  final NotificationsRepository repository;

  MarkAllNotificationsRead(this.repository);

  Future<Either<Failure, void>> call() {
    return repository.markAllAsRead();
  }
}
