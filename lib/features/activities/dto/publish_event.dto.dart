
import 'package:letdem/infrastructure/api/api/models/endpoint.dart';
import 'package:letdem/infrastructure/api/api/models/error.dart';

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
    // check for invalid latitude and longitude

    if (latitude < -90 || latitude > 90) {
      throw ApiError(
        message: "Invalid latitude",
      );
    }
    if (longitude < -180 || longitude > 180) {
      throw ApiError(
        message: "Invalid longitude",
      );
    }

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
