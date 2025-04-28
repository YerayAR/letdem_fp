import 'package:letdem/enums/CarTagType.dart';
import 'package:letdem/views/app/activities/widgets/no_car_registered.widget.dart';

class Car {
  final String id;
  final String brand;
  final String registrationNumber;
  final CarTagType tagType;

  final LastParkingLocation? lastParkingLocation;

  Car({
    required this.id,
    required this.brand,
    required this.registrationNumber,
    required this.tagType,
    required this.lastParkingLocation,
  });

  factory Car.fromJson(Map<String, dynamic> json) {
    return Car(
      id: json['id'],
      brand: json['name'],
      registrationNumber: json['plate_number'],
      lastParkingLocation: json['parked_place'] != null
          ? LastParkingLocation.fromJson(json['parked_place'])
          : null,
      tagType: fromJsonToTag(json['label']),
    );
  }
}

class LastParkingLocation {
  final String streetName;
  final double lat;
  final double lng;

  LastParkingLocation({
    required this.lat,
    required this.lng,
    required this.streetName,
  });

  factory LastParkingLocation.fromJson(Map<String, dynamic> json) {
    return LastParkingLocation(
      lat: json['point']['lat'],
      lng: json['point']['lng'],
      streetName: json['street_name'],
    );
  }
}
