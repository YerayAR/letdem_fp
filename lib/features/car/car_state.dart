part of 'car_bloc.dart';

sealed class CarState extends Equatable {
  const CarState();
}

final class CarInitial extends CarState {
  @override
  List<Object> get props => [];
}

final class CarLoading extends CarState {
  @override
  List<Object> get props => [];
}

final class CarLoaded extends CarState {
  final Car? car;
  const CarLoaded(this.car);

  @override
  List<Object?> get props => [car];
}

final class CarError extends CarState {
  final String message;
  const CarError(this.message);

  @override
  List<Object> get props => [message];
}
