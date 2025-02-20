import 'package:letdem/services/api/api.service.dart';
import 'package:letdem/services/api/endpoints.dart';
import 'package:letdem/services/api/models/endpoint.dart';
import 'package:letdem/services/api/models/response.model.dart';
import 'package:letdem/views/app/activities/widgets/no_car_registered.widget.dart';

class CarRepository extends ICarRepository {
  @override
  Future<Car?> getCar() async {
    ApiResponse response =
        await ApiService.sendRequest(endpoint: EndPoints.getCar);

    return Car.fromJson(response.data);
  }

  @override
  Future<Car?> registerCar(CreateCartDTO dto) async {
    ApiResponse response = await ApiService.sendRequest(
      endpoint: EndPoints.registerCar.copyWithDTO(dto),
    );

    return Car.fromJson(response.data);
  }

  @override
  Future<Car?> updateCar(CreateCartDTO dto) async {
    ApiResponse response = await ApiService.sendRequest(
      endpoint: EndPoints.updateCar.copyWithDTO(dto),
    );
    return Car.fromJson(response.data);
  }
}

abstract class ICarRepository {
  Future<Car?> getCar();
  Future<Car?> registerCar(CreateCartDTO dto);
  Future<Car?> updateCar(CreateCartDTO dto);
}

class CreateCartDTO extends DTO {
  final String brand;
  final String registrationNumber;
  final CarTagType tagType;

  CreateCartDTO({
    required this.brand,
    required this.registrationNumber,
    required this.tagType,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'name': brand,
      'plate_number': registrationNumber,
      'label': tagType.name.toUpperCase(),
    };
  }
}

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
