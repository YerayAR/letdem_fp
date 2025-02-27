import 'package:letdem/enums/EventTypes.dart';
import 'package:letdem/views/app/publish_space/screens/publish_space.view.dart';

class MapNearbyPayload {
  final List<Space> spaces;
  final List<Event> events;

  MapNearbyPayload({
    required this.spaces,
    required this.events,
  });

  factory MapNearbyPayload.fromJson(Map<String, dynamic> json) {
    return MapNearbyPayload(
      spaces: (json['spaces'] as List<dynamic>)
          .map((space) => Space.fromJson(space))
          .toList(),
      events: (json['events'] as List<dynamic>)
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

class Space {
  final String id;
  final PublishSpaceType type;
  final String image;
  final Location location;
  final DateTime created;
  final String resourceType;

  Space({
    required this.id,
    required this.type,
    required this.image,
    required this.location,
    required this.created,
    required this.resourceType,
  });

  factory Space.fromJson(Map<String, dynamic> json) {
    return Space(
      id: json['id'],
      type: getEnumFromText(json['type']),
      image: json['image'],
      location: Location.fromJson(json['location']),
      created: DateTime.parse(json['created']),
      resourceType: json['resourcetype'],
    );
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
  final Location location;
  final DateTime created;

  Event({
    required this.id,
    required this.type,
    required this.location,
    required this.created,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
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
