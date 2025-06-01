import 'package:letdem/core/enums/EventTypes.dart';
import 'package:letdem/core/enums/PublishSpaceType.dart';

class MapNearbyPayload {
  final List<Space> spaces;
  final List<Event> events;

  final List<Alert> alerts;

  MapNearbyPayload({
    required this.spaces,
    required this.events,
    required this.alerts,
  });

  factory MapNearbyPayload.fromJson(Map<String, dynamic> json) {
    return MapNearbyPayload(
      spaces: json['spaces'] == null
          ? []
          : (json['spaces'] as List<dynamic>)
              .map((space) => Space.fromJson(space))
              .toList(),
      alerts: json['alerts'] == null
          ? []
          : (json['alerts'] as List<dynamic>)
              .map((alert) => Alert.fromJson(alert))
              .toList(),
      events: json['events'] == null
          ? []
          : // Check if events is null
          (json['events'] as List<dynamic>)
              .map((event) => Event.fromJson(event))
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'spaces': spaces.map((space) => space.toJson()).toList(),
      'events': events.map((event) => event.toJson()).toList(),
    };
  }
}

String getTimeLeftMessage(DateTime now, DateTime reservationEndTime) {
  final difference = reservationEndTime.difference(now);

  if (difference.isNegative) {
    return 'Reservation expired';
  } else if (difference.inMinutes < 1) {
    return 'Less than a minute left';
  } else {
    return '${difference.inMinutes} mins left to reserve space';
  }
}

class Space {
  final String id;
  final PublishSpaceType type;
  final String image;

  final String? price;
  final Location location;
  final DateTime created;
  final String resourceType;

  final DateTime? expirationDate;

  final bool isPremium;

  Space({
    required this.id,
    required this.type,
    required this.image,
    required this.location,
    this.expirationDate,
    required this.created,
    this.price,
    this.isPremium = false,
    required this.resourceType,
  });

  factory Space.fromJson(Map<String, dynamic> json) {
    return Space(
        id: json['id'],
        type: getEnumFromText(json['type'], json['resourcetype'] ?? ""),
        image: json['image'],
        location: Location.fromJson(json['location']),
        price: json['price']?.toString(),
        created: DateTime.parse(json['created']),
        resourceType: json['resourcetype'] ?? "",
        expirationDate: json['expires_at'] != null
            ? DateTime.parse(json['expires_at'])
            : null,
        isPremium: json['resourcetype'] == 'PaidSpace');
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'image': image,
      'location': location.toJson(),
      'created': created.toIso8601String(),
      'resourcetype': resourceType,
    };
  }
}

class Event {
  final String id;
  final EventTypes type;

  final bool isOwner;
  final Location location;
  final DateTime created;

  Event({
    required this.id,
    required this.type,
    required this.location,
    required this.isOwner,
    required this.created,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      isOwner: json['is_owner'] ?? false,
      type: getEventEnumFromText(json['type']),
      location: Location.fromJson(json['location']),
      created: DateTime.parse(json['created']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'location': location.toJson(),
      'created': created.toIso8601String(),
    };
  }
}

class Location {
  final String streetName;
  final String address;
  final Point point;

  Location({
    required this.streetName,
    required this.address,
    required this.point,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      streetName: json['street_name'],
      address: json.keys
          .where((key) => key != 'street_name' && key != 'point')
          .map((key) => json[key])
          .join(', '),
      point: Point.fromJson(json['point']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'street_name': streetName,
      'address': address,
      'point': point.toJson(),
    };
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
      lng: json['lng'].toDouble(),
      lat: json['lat'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lng': lng,
      'lat': lat,
    };
  }
}

class Alert {
  final String type;
  final String road;
  final double latitude;
  final double longitude;
  final String direction;
  final double distance;

  Alert({
    required this.type,
    required this.road,
    required this.latitude,
    required this.longitude,
    required this.direction,
    required this.distance,
  });

  factory Alert.fromJson(Map<String, dynamic> json) {
    return Alert(
      type: json['type'] as String,
      road: json['road'] as String,
      latitude: double.tryParse(json['latitude'].toString()) ?? 0.0,
      longitude: double.tryParse(json['longitude'].toString()) ?? 0.0,
      direction: json['direction'] as String,
      distance: (json['distance'] as num).toDouble(),
    );
  }
}
