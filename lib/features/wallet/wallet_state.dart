part of 'wallet_bloc.dart';

sealed class WalletState extends Equatable {
  const WalletState();
}

final class WalletInitial extends WalletState {
  @override
  List<Object> get props => [];
}

final class WalletLoading extends WalletState {
  @override
  List<Object> get props => [];
}

final class WalletSuccess extends WalletState {
  final List<Transaction> transactions;

  const WalletSuccess(this.transactions);

  @override
  List<Object> get props => [transactions];
}

final class WalletFailure extends WalletState {
  final String message;

  const WalletFailure(this.message);

  @override
  List<Object> get props => [message];
}
