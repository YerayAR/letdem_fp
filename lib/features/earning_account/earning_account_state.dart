import 'package:equatable/equatable.dart';
import 'package:letdem/models/earnings_account/earning_account.model.dart';

abstract class EarningsState extends Equatable {
  const EarningsState();

  @override
  List<Object?> get props => [];
}

class EarningsInitial extends EarningsState {}

class EarningsLoading extends EarningsState {}

class EarningsSuccess extends EarningsState {
  final EarningAccount info;

  const EarningsSuccess(this.info);

  @override
  List<Object?> get props => [info];
}

class EarningsFailure extends EarningsState {
  final String message;

  const EarningsFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class EarningsCompleted extends EarningsState {
  final EarningAccount info;

  const EarningsCompleted(
    this.info,
  );

  @override
  List<Object?> get props => [
        info,
      ];
}
