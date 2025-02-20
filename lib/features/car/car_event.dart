part of 'car_bloc.dart';

sealed class CarEvent extends Equatable {
  const CarEvent();
}

final class GetCarEvent extends CarEvent {
  const GetCarEvent();

  @override
  // TODO: implement props
  List<Object?> get props => [];
}

final class CreateCarEvent extends CarEvent {
  final String brand;
  final String registrationNumber;
  final CarTagType tagType;

  final bool isUpdating;

  const CreateCarEvent({
    required this.brand,
    required this.registrationNumber,
    this.isUpdating = false,
    required this.tagType,
  });

  @override
  // TODO: implement props
  List<Object?> get props => [brand, registrationNumber, tagType];
}
