part of 'notifications_bloc.dart';

sealed class NotificationsEvent extends Equatable {
  const NotificationsEvent();
}

class LoadNotificationsEvent extends NotificationsEvent {
  @override
  List<Object> get props => [];
}

class ReadNotificationEvent extends NotificationsEvent {
  final String id;

  ReadNotificationEvent({required this.id});

  @override
  List<Object> get props => [id];
}
