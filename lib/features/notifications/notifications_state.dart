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
  final NotificationModel unreadNotifications;

  const NotificationsLoaded({
    required this.unreadNotifications,
  });

  @override
  List<Object> get props => [unreadNotifications];
}

class NotificationsError extends NotificationsState {
  final String error;

  const NotificationsError({required this.error});

  @override
  List<Object> get props => [error];
}
