part of 'notifications_bloc.dart';

sealed class NotificationsEvent extends Equatable {
  const NotificationsEvent();
}

class MarkNotificationAsReadEvent extends NotificationsEvent {
  final String id;

  const MarkNotificationAsReadEvent({required this.id});

  @override
  List<Object> get props => [id];
}

class ClearNotificationsEvent extends NotificationsEvent {
  @override
  List<Object> get props => [];
}

class LoadNotificationsEvent extends NotificationsEvent {
  final bool showUnread;

  LoadNotificationsEvent({this.showUnread = false});
  @override
  List<Object> get props => [showUnread];
}

class ReadNotificationEvent extends NotificationsEvent {
  final String id;

  ReadNotificationEvent({required this.id});

  @override
  List<Object> get props => [id];
}

// In notifications_event.dart
class FilterNotificationsEvent extends NotificationsEvent {
  final bool showUnread;

  FilterNotificationsEvent({required this.showUnread});

  @override
  List<Object> get props => [showUnread];
}
