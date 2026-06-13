import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/notifications_bloc.dart';
import '../bloc/notifications_event.dart';
import '../bloc/notifications_state.dart';
import '../../domain/entities/notification.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          BlocBuilder<NotificationsBloc, NotificationsState>(
            builder: (context, state) {
              if (state is NotificationsLoaded && state.unreadCount > 0) {
                return TextButton.icon(
                  onPressed: () {
                    context.read<NotificationsBloc>().add(MarkAllAsReadEvent());
                  },
                  icon: const Icon(Icons.done_all, color: AppColors.primaryLight, size: 20),
                  label: const Text(
                    'Mark all read',
                    style: TextStyle(
                      color: AppColors.primaryLight,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocBuilder<NotificationsBloc, NotificationsState>(
        builder: (context, state) {
          if (state is NotificationsLoading || state is NotificationsInitial) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is NotificationsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<NotificationsBloc>().add(LoadNotificationsEvent());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryLight,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            );
          } else if (state is NotificationsLoaded) {
            final notifications = state.notifications;

            if (notifications.isEmpty) {
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<NotificationsBloc>().add(RefreshNotificationsEvent());
                },
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.25),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.surfaceDark
                                  : AppColors.primaryLight.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.notifications_off_outlined,
                              size: 64,
                              color: AppColors.primaryLight,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'All caught up!',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'You don\'t have any notifications right now.',
                            style: TextStyle(
                              color: isDark ? Colors.white60 : Colors.black54,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<NotificationsBloc>().add(RefreshNotificationsEvent());
              },
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: notifications.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final notification = notifications[index];
                  return _buildNotificationCard(context, notification, isDark);
                },
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildNotificationCard(
    BuildContext context,
    AppNotification notification,
    bool isDark,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: notification.isRead
            ? (isDark ? AppColors.surfaceDark : Colors.white)
            : (isDark
                ? AppColors.surfaceDark.withValues(alpha: 0.8)
                : AppColors.primaryLight.withValues(alpha: 0.05)),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: notification.isRead
              ? (isDark ? AppColors.borderDark : Colors.grey[200]!)
              : AppColors.primaryLight.withValues(alpha: 0.3),
          width: notification.isRead ? 1.0 : 1.5,
        ),
        boxShadow: notification.isRead
            ? null
            : [
                BoxShadow(
                  color: AppColors.primaryLight.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Indicator Dot
              Container(
                margin: const EdgeInsets.only(top: 4, right: 12),
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: notification.isRead ? Colors.transparent : AppColors.primaryLight,
                  shape: BoxShape.circle,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: TextStyle(
                        fontWeight: notification.isRead ? FontWeight.w600 : FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      notification.body,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.white70 : Colors.black87,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _getRelativeTime(notification.createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white54 : Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
              if (!notification.isRead) ...[
                const SizedBox(width: 8),
                IconButton(
                  tooltip: 'Mark as read',
                  icon: const Icon(
                    Icons.check_circle_outline,
                    color: AppColors.primaryLight,
                    size: 24,
                  ),
                  onPressed: () {
                    context.read<NotificationsBloc>().add(MarkAsReadEvent(notification.id));
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _getRelativeTime(DateTime dateTime) {
    final duration = DateTime.now().difference(dateTime);

    if (duration.inMinutes < 1) {
      return 'Just now';
    } else if (duration.inMinutes < 60) {
      return '${duration.inMinutes}m ago';
    } else if (duration.inHours < 24) {
      return '${duration.inHours}h ago';
    } else if (duration.inDays == 1) {
      return 'Yesterday';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}
