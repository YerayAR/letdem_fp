import 'package:letdem/services/api/models/endpoint.dart';

class PublishSpaceDTO extends DTO {
  final String? type;
  final String image;

  final double latitude;

  final String streetName;
  final double longitude;

  // "price": 5.50,
  // "phone": "+34688308181",
  // "time_to_wait": 50,

  final String? price;
  final int? waitTime;
  final String? phoneNumber;

  PublishSpaceDTO({
    required this.type,
    required this.image,
    required this.streetName,
    required this.latitude,
    required this.longitude,
    this.price,
    this.waitTime,
    this.phoneNumber,
  });

  @override
  Map<String, dynamic> toMap() {
    var map = {
      "type": type,
      "image": image,
      "location": {
        "street_name": streetName,
        "lat": latitude,
        "lng": longitude,
      },
    };

    if (price != null) {
      map["price"] = double.parse(price!.toString());
    }
    if (phoneNumber != null) {
      map["phone"] = phoneNumber;
    }

    if (waitTime != null) {
      map["time_to_wait"] = waitTime;
    }
    return map;
  }
}
