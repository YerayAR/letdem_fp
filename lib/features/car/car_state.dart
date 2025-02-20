part of 'car_bloc.dart';

sealed class CarState extends Equatable {
  const CarState();
}

final class CarInitial extends CarState {
  @override
  List<Object> get props => [];
}
