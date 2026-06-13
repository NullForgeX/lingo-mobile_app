import 'package:equatable/equatable.dart';

abstract class NotificationsEvent extends Equatable {
  const NotificationsEvent();

  @override
  List<Object?> get props => [];
}

class LoadNotificationsEvent extends NotificationsEvent {}

class RefreshNotificationsEvent extends NotificationsEvent {}

class MarkAsReadEvent extends NotificationsEvent {
  final String id;

  const MarkAsReadEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class MarkAllAsReadEvent extends NotificationsEvent {}
