part of 'notifications_bloc.dart';

sealed class NotificationsState extends Equatable {
  const NotificationsState();
}

final class NotificationsInitial extends NotificationsState {
  @override
  List<Object> get props => [];
}

class NotificationsLoading extends NotificationsState {
  @override
  List<Object> get props => [];
}

class NotificationsLoaded extends NotificationsState {
  final NotificationModel notifications;

  NotificationsLoaded({required this.notifications});

  @override
  List<Object> get props => [notifications];
}

class NotificationsError extends NotificationsState {
  final String error;

  NotificationsError({required this.error});

  @override
  List<Object> get props => [error];
}
