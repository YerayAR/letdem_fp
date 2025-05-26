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
  final List<Withdrawal> withdrawals;
  final bool isWithdrawalsLoading;
  const PayoutMethodSuccess(
      this.methods, this.withdrawals, this.isWithdrawalsLoading);

  PayoutMethodSuccess copyWith({
    List<PayoutMethod>? methods,
    List<Withdrawal>? withdrawals,
    bool? isWithdrawalsLoading,
  }) {
    return PayoutMethodSuccess(
      methods ?? this.methods,
      withdrawals ?? this.withdrawals,
      isWithdrawalsLoading ?? this.isWithdrawalsLoading,
    );
  }

  @override
  List<Object?> get props => [methods, withdrawals];
}

class PayoutMethodFailure extends PayoutMethodState {
  final String message;
  const PayoutMethodFailure(this.message);
  @override
  List<Object?> get props => [message];
}
