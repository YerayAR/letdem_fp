import 'package:letdem/features/car/dto/create_car.dto.dart';
import 'package:letdem/features/car/repository/car.interface.dart';
import 'package:letdem/models/car/car.model.dart';
import 'package:letdem/services/api/api.service.dart';
import 'package:letdem/services/api/endpoints.dart';
import 'package:letdem/services/api/models/response.model.dart';

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
