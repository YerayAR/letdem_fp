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

class CreateScheduledNotificationEvent extends ScheduleNotificationsEvent {
  final DateTime startsAt;
  final DateTime endsAt;

  final String? eventID;
  final bool isUpdate;
  final LocationData location;

  final double radius;

  const CreateScheduledNotificationEvent({
    required this.startsAt,
    required this.endsAt,
    this.isUpdate = false,
    this.eventID,
    required this.radius,
    required this.location,
  });

  @override
  List<Object> get props => [startsAt, endsAt, location, isUpdate];
}
