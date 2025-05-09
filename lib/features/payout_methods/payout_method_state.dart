part of 'payout_method_bloc.dart';

abstract class PayoutMethodState extends Equatable {
  const PayoutMethodState();
  @override
  List<Object?> get props => [];
}

class PayoutMethodInitial extends PayoutMethodState {}

class PayoutMethodLoading extends PayoutMethodState {}

class PayoutMethodSuccess extends PayoutMethodState {
  final List<PayoutMethod> methods;
  const PayoutMethodSuccess(this.methods);
  @override
  List<Object?> get props => [methods];
}

class PayoutMethodFailure extends PayoutMethodState {
  final String message;
  const PayoutMethodFailure(this.message);
  @override
  List<Object?> get props => [message];
}
