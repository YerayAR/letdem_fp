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
  final Location location;

  ScheduledNotification({
    required this.id,
    required this.startsAt,
    required this.endsAt,
    required this.isExpired,
    required this.location,
  });

  factory ScheduledNotification.fromJson(Map<String, dynamic> json) {
    return ScheduledNotification(
      id: json['id'],
      startsAt: DateTime.parse(json['starts_at']).toUtc(),
      endsAt: DateTime.parse(json['ends_at']).toUtc(),
      isExpired: json['is_expired'],
      location: Location.fromJson(json['location']),
    );
  }
}

class Location {
  final String streetName;
  final Point point;

  Location({
    required this.streetName,
    required this.point,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      streetName: json['street_name'],
      point: Point.fromJson(json['point']),
    );
  }
}

class Point {
  final double lng;
  final double lat;

  Point({
    required this.lng,
    required this.lat,
  });

  factory Point.fromJson(Map<String, dynamic> json) {
    return Point(
      lng: json['lng'],
      lat: json['lat'],
    );
  }
}
