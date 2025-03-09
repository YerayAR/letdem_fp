part of 'schedule_notifications_bloc.dart';

sealed class ScheduleNotificationsState extends Equatable {
  const ScheduleNotificationsState();
}

final class ScheduleNotificationsInitial extends ScheduleNotificationsState {
  @override
  List<Object> get props => [];
}
