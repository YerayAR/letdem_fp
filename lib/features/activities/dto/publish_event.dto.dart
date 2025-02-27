import 'package:letdem/services/api/models/endpoint.dart';

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
