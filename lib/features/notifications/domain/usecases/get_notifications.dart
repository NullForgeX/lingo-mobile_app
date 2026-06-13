import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/notification.dart';
import '../repositories/notifications_repository.dart';

class GetNotifications {
  final NotificationsRepository repository;

  GetNotifications(this.repository);

  Future<Either<Failure, List<AppNotification>>> call({
    bool? unreadOnly,
    int? page,
    int? pageSize,
  }) {
    return repository.getNotifications(
      unreadOnly: unreadOnly,
      page: page,
      pageSize: pageSize,
    );
  }
}
