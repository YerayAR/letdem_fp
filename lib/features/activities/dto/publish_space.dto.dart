import 'package:letdem/services/api/models/endpoint.dart';

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
      "type": type,
      "image": image,
      "location": {
        "street_name": streetName,
        "lat": latitude,
        "lng": longitude,
      },
    };
  }
}
