import 'package:letdem/enums/CarTagType.dart';
import 'package:letdem/views/app/activities/widgets/no_car_registered.widget.dart';

class Car {
  final String id;
  final String brand;
  final String registrationNumber;
  final CarTagType tagType;

  Car({
    required this.id,
    required this.brand,
    required this.registrationNumber,
    required this.tagType,
  });

  factory Car.fromJson(Map<String, dynamic> json) {
    return Car(
      id: json['id'],
      brand: json['name'],
      registrationNumber: json['plate_number'],
      tagType: fromJsonToTag(json['label']),
    );
  }
}
