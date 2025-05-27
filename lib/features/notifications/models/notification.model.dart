import 'package:geolocator/geolocator.dart';
import 'package:letdem/features/map/presentation/views/route.view.dart';

class NotificationResult {
  final String id;
  final NotificationPayloadType type;
  final bool read;
  final NotificationObject notificationObject;

  String? distance;
  final DateTime created;

  NotificationResult({
    required this.id,
    required this.type,
    required this.read,
    this.distance,
    required this.notificationObject,
    required this.created,
  });

  setDistance(Position currentPosition) {
    final distance = Geolocator.distanceBetween(
        currentPosition.latitude,
        currentPosition.longitude,
        notificationObject.location.point.lat,
        notificationObject.location.point.lng);

    this.distance = parseMeters(distance);
  }

  factory NotificationResult.fromJson(Map<String, dynamic> json) =>
      NotificationResult(
        id: json['id'],
        type: notificationTypeFromString(json['type']),
        read: json['read'],
        notificationObject:
            NotificationObject.fromJson(json['notification_object']),
        created: DateTime.parse(json['created']),
      );
}

enum NotificationPayloadType {
  spaceReserved,
  spaceOccupied,
  spaceNearby,
  disabled,
  free,
  blue,

  green
}

String formatedNotificationType(NotificationPayloadType type) {
  switch (type) {
    case NotificationPayloadType.spaceReserved:
      return 'Paid Space Reserved';
    case NotificationPayloadType.spaceNearby:
      return 'New space published';
    case NotificationPayloadType.spaceOccupied:
      return 'Space Occupied';
    case NotificationPayloadType.disabled:
      return 'Disabled';
    case NotificationPayloadType.free:
      return 'Free';
    case NotificationPayloadType.blue:
      return 'Blue';
    case NotificationPayloadType.green:
      return 'Green';
  }
}

NotificationPayloadType notificationTypeFromString(String type) {
  switch (type) {
    case 'SPACE_RESERVED':
      return NotificationPayloadType.spaceReserved;
    case 'SPACE_NEARBY':
      return NotificationPayloadType.spaceNearby;
    case 'SPACE_OCCUPIED':
      return NotificationPayloadType.spaceOccupied;
    default:
      throw Exception('Unknown notification type');
  }
}

class NotificationObject {
  final String id;
  final String type;
  final String image;
  final Location location;
  final DateTime created;
  final String resourceType;

  NotificationObject({
    required this.id,
    required this.type,
    required this.image,
    required this.location,
    required this.created,
    required this.resourceType,
  });

  factory NotificationObject.fromJson(Map<String, dynamic> json) =>
      NotificationObject(
        id: json['id'],
        type: (json['type']),
        image: json['image'],
        location: Location.fromJson(json['location']),
        created: DateTime.parse(json['created']),
        resourceType: json['resourcetype'],
      );
}

class Location {
  final String streetName;
  final Point point;

  Location({
    required this.streetName,
    required this.point,
  });

  factory Location.fromJson(Map<String, dynamic> json) => Location(
        streetName: json['street_name'],
        point: Point.fromJson(json['point']),
      );
}

class Point {
  final double lng;
  final double lat;

  Point({
    required this.lng,
    required this.lat,
  });

  factory Point.fromJson(Map<String, dynamic> json) => Point(
        lng: json['lng'].toDouble(),
        lat: json['lat'].toDouble(),
      );
}
