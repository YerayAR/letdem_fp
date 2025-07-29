part of 'schedule_notifications_bloc.dart';

sealed class ScheduleNotificationsState extends Equatable {
  const ScheduleNotificationsState();
}

final class ScheduleNotificationsInitial extends ScheduleNotificationsState {
  @override
  List<Object> get props => [];
}

class ScheduleNotificationsLoading extends ScheduleNotificationsState {
  @override
  List<Object> get props => [];
}

class ScheduleNotificationsLoaded extends ScheduleNotificationsState {
  final List<ScheduledNotification> scheduledNotifications;

  const ScheduleNotificationsLoaded(this.scheduledNotifications);

  @override
  List<Object> get props => [scheduledNotifications];
}

class ScheduleNotificationCreated extends ScheduleNotificationsState {
  const ScheduleNotificationCreated();

  @override
  List<Object> get props => [];
}

class ScheduleNotificationsError extends ScheduleNotificationsState {
  final String message;

  const ScheduleNotificationsError(this.message);

  @override
  List<Object> get props => [message];
}

class ScheduledNotification {
  final String id;
  final DateTime startsAt;
  final DateTime endsAt;
  final bool isExpired;

  final double radius;
  final LocationData location;

  ScheduledNotification({
    required this.id,
    required this.startsAt,
    required this.endsAt,
    required this.isExpired,
    this.radius = 0,
    required this.location,
  });

  factory ScheduledNotification.fromJson(Map<String, dynamic> json) {
    return ScheduledNotification(
      id: json['id'],
      radius: json['radius'],
      startsAt: DateTime.parse(json['starts_at']).toLocal(),
      endsAt: DateTime.parse(json['ends_at']).toLocal(),
      isExpired: json['is_expired'],
      location: LocationData.fromJson(json['location']),
    );
  }
}

class LocationData {
  final String streetName;
  final CoordinatesData point;

  LocationData({
    required this.streetName,
    required this.point,
  });

  factory LocationData.fromJson(Map<String, dynamic> json) {
    return LocationData(
      streetName: json['street_name'],
      point: CoordinatesData.fromMap(json['point']),
    );
  }
}
