import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:letdem/core/enums/CarTagType.dart';
import 'package:letdem/features/car/dto/create_car.dto.dart';
import 'package:letdem/features/car/repository/car.repository.dart';
import 'package:letdem/infrastructure/api/api/models/error.dart';
import 'package:letdem/models/car/car.model.dart';

part 'car_event.dart';
part 'car_state.dart';

class CarBloc extends Bloc<CarEvent, CarState> {
  final CarRepository carRepository;
  CarBloc({
    required this.carRepository,
  }) : super(CarInitial()) {
    on<GetCarEvent>(_onGetCarEvent);
    on<CreateCarEvent>(_onCreateCarEvent);
    on<ClearCarEvent>(_onClearCarEvent);
  }

  void _onClearCarEvent(ClearCarEvent event, Emitter<CarState> emit) {
    emit(CarInitial());
  }

  void _onCreateCarEvent(CreateCarEvent event, Emitter<CarState> emit) async {
    emit(CarLoading());
    try {
      final car = event.isUpdating
          ? await carRepository.updateCar(CreateCartDTO(
              brand: event.brand,
              registrationNumber: event.registrationNumber,
              tagType: event.tagType,
            ))
          : await carRepository.registerCar(CreateCartDTO(
              brand: event.brand,
              registrationNumber: event.registrationNumber,
              tagType: event.tagType,
            ));
      emit(CarLoaded(car));
    } on ApiError catch (e, st) {
      print(st);
      print(e);
      emit(CarError(e.message));
    } catch (e, st) {
      print(st);
      print(e);
      emit(CarError(e.toString()));
    }
  }

  void _onGetCarEvent(GetCarEvent event, Emitter<CarState> emit) async {
    emit(CarLoading());
    try {
      final car = await carRepository.getCar();
      emit(CarLoaded(car));
    } catch (e, st) {
      print("$st - $e");
      emit(CarError(e.toString()));
    }
  }
}
