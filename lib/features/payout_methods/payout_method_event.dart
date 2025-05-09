part of 'payout_method_bloc.dart';

abstract class PayoutMethodEvent extends Equatable {
  const PayoutMethodEvent();
  @override
  List<Object?> get props => [];
}

class FetchPayoutMethods extends PayoutMethodEvent {}

class AddPayoutMethod extends PayoutMethodEvent {
  final PayoutMethodDTO method;
  const AddPayoutMethod(this.method);
  @override
  List<Object?> get props => [method];
}

class DeletePayoutMethod extends PayoutMethodEvent {
  final String methodId;
  const DeletePayoutMethod(this.methodId);
  @override
  List<Object?> get props => [methodId];
}
