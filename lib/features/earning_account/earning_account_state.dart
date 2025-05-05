import 'package:equatable/equatable.dart';

abstract class EarningsState extends Equatable {
  const EarningsState();

  @override
  List<Object?> get props => [];
}

class EarningsInitial extends EarningsState {}

class EarningsLoading extends EarningsState {}

class EarningsSuccess extends EarningsState {}

class EarningsFailure extends EarningsState {
  final String message;

  const EarningsFailure(this.message);

  @override
  List<Object?> get props => [message];
}
