import 'package:letdem/services/api/models/endpoint.dart';

abstract class IActivityRepository {
  Future<ActivityResponse> getActivities();
  Future<Activity> getActivity(String id);
  Future<void> addActivity(Activity activity);
  Future<void> updateActivity(Activity activity);
  Future<void> deleteActivity(String id);

  Future publishSpace(PublishSpaceDTO dto);

  Future publishRoadEvent(PublishRoadEventDTO dto);
}

class ActivityResponse {
  final int count;
  final String? next;
  final String? previous;
  final List<Activity> results;

  ActivityResponse({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory ActivityResponse.fromJson(Map<String, dynamic> json) {
    return ActivityResponse(
      count: json['count'],
      next: json['next'],
      previous: json['previous'],
      results: (json['results'] as List<dynamic>)
          .map((e) => Activity.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'count': count,
      'next': next,
      'previous': previous,
      'results': results.map((e) => e.toJson()).toList(),
    };
  }
}

class Activity {
  final String id;
  final String type;
  final String action;
  final int points;
  final DateTime created;

  Activity({
    required this.id,
    required this.type,
    required this.action,
    required this.points,
    required this.created,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id'],
      type: json['type'],
      action: json['action'],
      points: json['points'],
      created: DateTime.parse(json['created']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'action': action,
      'points': points,
      'created': created.toIso8601String(),
    };
  }
}

void main() {
  // Example JSON
  String jsonString = '''
  {
    "count": 1,
    "next": null,
    "previous": null,
    "results": [
      {
        "id": "cb44c25c25644da59fd07e7d0ddf09ab",
        "type": "SPACE",
        "action": "SPACE_CREATED",
        "points": 4,
        "created": "2025-02-20T01:42:15.239036Z"
      }
    ]
  }
  ''';

  // Parsing JSON
}

class PublishSpaceDTO extends DTO {
  final String? type;
  final String image;

  final double latitude;

  final String streetName;
  final double longitude;

  PublishSpaceDTO({
    required this.type,
    required this.image,
    required this.streetName,
    required this.latitude,
    required this.longitude,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      "type": "FREE",
      "image": image,
      "location": {
        "street_name": streetName,
        "lat": latitude,
        "lng": longitude,
      },
    };
  }
}

class PublishRoadEventDTO extends DTO {
  final String? type;
  final double latitude;
  final double longitude;
  final String streetName;

  PublishRoadEventDTO({
    required this.type,
    required this.latitude,
    required this.longitude,
    required this.streetName,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      "type": type,
      "location": {
        "street_name": streetName,
        "lat": latitude,
        "lng": longitude,
      },
    };
  }
}
