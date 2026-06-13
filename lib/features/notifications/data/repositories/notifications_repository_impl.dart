import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/notification.dart';
import '../../domain/repositories/notifications_repository.dart';
import '../datasources/notifications_remote_data_source.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  final NotificationsRemoteDataSource remoteDataSource;

  NotificationsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<AppNotification>>> getNotifications({
    bool? unreadOnly,
    int? page,
    int? pageSize,
  }) async {
    try {
      final notifications = await remoteDataSource.getNotifications(
        unreadOnly: unreadOnly,
        page: page,
        pageSize: pageSize,
      );
      return Right(notifications);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to retrieve notifications.'));
    } catch (e) {
      return const Left(ServerFailure('An unexpected error occurred.'));
    }
  }

  @override
  Future<Either<Failure, int>> getUnreadCount() async {
    try {
      final count = await remoteDataSource.getUnreadCount();
      return Right(count);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to retrieve unread notification count.'));
    } catch (e) {
      return const Left(ServerFailure('An unexpected error occurred.'));
    }
  }

  @override
  Future<Either<Failure, void>> markAsRead(String id) async {
    try {
      await remoteDataSource.markAsRead(id);
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to mark notification as read.'));
    } catch (e) {
      return const Left(ServerFailure('An unexpected error occurred.'));
    }
  }

  @override
  Future<Either<Failure, void>> markAllAsRead() async {
    try {
      await remoteDataSource.markAllAsRead();
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to mark all notifications as read.'));
    } catch (e) {
      return const Left(ServerFailure('An unexpected error occurred.'));
    }
  }
}
