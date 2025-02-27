import 'package:letdem/features/car/dto/create_car.dto.dart';
import 'package:letdem/models/car/car.model.dart';

abstract class ICarRepository {
  Future<Car?> getCar();
  Future<Car?> registerCar(CreateCartDTO dto);
  Future<Car?> updateCar(CreateCartDTO dto);
}
