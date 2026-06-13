import '../../domain/entities/notification.dart';

class NotificationModel extends AppNotification {
  const NotificationModel({
    required super.id,
    required super.title,
    required super.body,
    required super.isRead,
    required super.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final summary = json['summary'] as Map<String, dynamic>?;
    final readAt = json['readAt'];
    final title = json['title'] as String? ?? summary?['title'] as String? ?? '';
    final body = json['body'] as String? ?? summary?['body'] as String? ?? '';
    final isRead = json['isRead'] as bool? ?? (readAt != null);

    return NotificationModel(
      id: json['id'] as String,
      title: title,
      body: body,
      isRead: isRead,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'summary': {
        'title': title,
        'body': body,
      },
      'isRead': isRead,
      'readAt': isRead ? createdAt.toIso8601String() : null,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
