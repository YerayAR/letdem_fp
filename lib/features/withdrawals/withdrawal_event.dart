part of 'withdrawal_bloc.dart';

sealed class WithdrawalEvent extends Equatable {
  const WithdrawalEvent();
}

class FetchWithdrawals extends WithdrawalEvent {
  final String? methodId;
  const FetchWithdrawals({this.methodId});
  @override
  List<Object?> get props => [methodId];
}

class WithdrawMoneyEvent extends WithdrawalEvent {
  final PayoutMethod methodId;
  final double amount;
  const WithdrawMoneyEvent(this.methodId, this.amount);
  @override
  List<Object?> get props => [methodId, amount];
}
