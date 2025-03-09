part of 'schedule_notifications_bloc.dart';

sealed class ScheduleNotificationsEvent extends Equatable {
  const ScheduleNotificationsEvent();
}

class FetchScheduledNotificationsEvent extends ScheduleNotificationsEvent {
  const FetchScheduledNotificationsEvent();

  @override
  List<Object> get props => [];
}

class DeleteScheduledNotificationEvent extends ScheduleNotificationsEvent {
  final String id;

  const DeleteScheduledNotificationEvent(this.id);

  @override
  List<Object> get props => [id];
}
