import 'package:dio/dio.dart';
import '../../../../core/network/api_constants.dart';
import '../models/notification_model.dart';

abstract class NotificationsRemoteDataSource {
  Future<List<NotificationModel>> getNotifications({
    bool? unreadOnly,
    int? page,
    int? pageSize,
  });
  Future<int> getUnreadCount();
  Future<void> markAsRead(String id);
  Future<void> markAllAsRead();
}

class NotificationsRemoteDataSourceImpl implements NotificationsRemoteDataSource {
  final Dio dio;

  NotificationsRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<NotificationModel>> getNotifications({
    bool? unreadOnly,
    int? page,
    int? pageSize,
  }) async {
    final queryParameters = <String, dynamic>{};
    if (unreadOnly != null) queryParameters['unreadOnly'] = unreadOnly;
    if (page != null) queryParameters['page'] = page;
    if (pageSize != null) queryParameters['pageSize'] = pageSize;

    final response = await dio.get(
      ApiConstants.getNotifications,
      queryParameters: queryParameters,
    );

    final items = response.data['data']['items'] as List<dynamic>;
    return items.map((json) => NotificationModel.fromJson(json)).toList();
  }

  @override
  Future<int> getUnreadCount() async {
    final response = await dio.get(ApiConstants.getUnreadCount);
    return response.data['data']['unreadCount'] as int;
  }

  @override
  Future<void> markAsRead(String id) async {
    final path = ApiConstants.markRead.replaceAll('{notificationId}', id);
    await dio.post(path);
  }

  @override
  Future<void> markAllAsRead() async {
    await dio.post(ApiConstants.markAllRead);
  }
}
