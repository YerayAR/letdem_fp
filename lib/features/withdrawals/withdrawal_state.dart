part of 'withdrawal_bloc.dart';

sealed class WithdrawalState extends Equatable {
  const WithdrawalState();
}

final class WithdrawalInitial extends WithdrawalState {
  @override
  List<Object> get props => [];
}

final class WithdrawalLoading extends WithdrawalState {
  @override
  List<Object> get props => [];
}

final class WithdrawalSuccess extends WithdrawalState {
  final List<Withdrawal> withdrawals;
  const WithdrawalSuccess(this.withdrawals);
  @override
  List<Object> get props => [withdrawals];
}

final class WithdrawalFailure extends WithdrawalState {
  final String message;
  const WithdrawalFailure(this.message);
  @override
  List<Object> get props => [message];
}
