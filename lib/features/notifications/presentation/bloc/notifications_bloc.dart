import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import '../../domain/entities/notification.dart';
import '../../domain/usecases/get_notifications.dart';
import '../../domain/usecases/get_unread_count.dart';
import '../../domain/usecases/mark_notification_read.dart';
import '../../domain/usecases/mark_all_notifications_read.dart';
import 'notifications_event.dart';
import 'notifications_state.dart';

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  final GetNotifications getNotifications;
  final GetUnreadCount getUnreadCount;
  final MarkNotificationRead markNotificationRead;
  final MarkAllNotificationsRead markAllNotificationsRead;

  NotificationsBloc({
    required this.getNotifications,
    required this.getUnreadCount,
    required this.markNotificationRead,
    required this.markAllNotificationsRead,
  }) : super(NotificationsInitial()) {
    on<LoadNotificationsEvent>(_onLoadNotifications);
    on<RefreshNotificationsEvent>(_onRefreshNotifications);
    on<MarkAsReadEvent>(_onMarkAsRead);
    on<MarkAllAsReadEvent>(_onMarkAllAsRead);
  }

  void _onLoadNotifications(
    LoadNotificationsEvent event,
    Emitter<NotificationsState> emit,
  ) async {
    emit(NotificationsLoading());
    await _fetchAndEmitNotifications(emit);
  }

  void _onRefreshNotifications(
    RefreshNotificationsEvent event,
    Emitter<NotificationsState> emit,
  ) async {
    await _fetchAndEmitNotifications(emit);
  }

  void _onMarkAsRead(
    MarkAsReadEvent event,
    Emitter<NotificationsState> emit,
  ) async {
    // Optimistic UI updates
    final currentState = state;
    if (currentState is NotificationsLoaded) {
      final updatedNotifications = currentState.notifications.map((n) {
        if (n.id == event.id) {
          return AppNotification(
            id: n.id,
            title: n.title,
            body: n.body,
            isRead: true,
            createdAt: n.createdAt,
          );
        }
        return n;
      }).toList();
      final newUnreadCount = (currentState.unreadCount - 1).clamp(0, 999);
      emit(NotificationsLoaded(
        notifications: updatedNotifications,
        unreadCount: newUnreadCount,
      ));
    }

    final result = await markNotificationRead(event.id);
    result.fold(
      (failure) {
        // Rollback on failure (fetch fresh data)
        add(RefreshNotificationsEvent());
      },
      (_) {},
    );
  }

  void _onMarkAllAsRead(
    MarkAllAsReadEvent event,
    Emitter<NotificationsState> emit,
  ) async {
    // Optimistic UI updates
    final currentState = state;
    if (currentState is NotificationsLoaded) {
      final updatedNotifications = currentState.notifications.map((n) {
        return AppNotification(
          id: n.id,
          title: n.title,
          body: n.body,
          isRead: true,
          createdAt: n.createdAt,
        );
      }).toList();
      emit(NotificationsLoaded(
        notifications: updatedNotifications,
        unreadCount: 0,
      ));
    }

    final result = await markAllNotificationsRead();
    result.fold(
      (failure) {
        // Rollback on failure (fetch fresh data)
        add(RefreshNotificationsEvent());
      },
      (_) {},
    );
  }

  Future<void> _fetchAndEmitNotifications(
    Emitter<NotificationsState> emit,
  ) async {
    final isGuest = Hive.box('auth_preferences_box').get('isGuest', defaultValue: false) as bool;
    if (isGuest) {
      emit(const NotificationsLoaded(
        notifications: [],
        unreadCount: 0,
      ));
      return;
    }

    final notificationsResult = await getNotifications();
    final countResult = await getUnreadCount();

    notificationsResult.fold(
      (failure) => emit(NotificationsError(failure.message)),
      (notifications) {
        countResult.fold(
          (failure) => emit(NotificationsError(failure.message)),
          (unreadCount) {
            emit(NotificationsLoaded(
              notifications: notifications,
              unreadCount: unreadCount,
            ));
          },
        );
      },
    );
  }
}
