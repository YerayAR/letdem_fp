part of 'wallet_bloc.dart';

sealed class WalletEvent extends Equatable {
  const WalletEvent();
}

class FetchTransactionsEvent extends WalletEvent {
  final TransactionParams filters;
  const FetchTransactionsEvent(this.filters);

  @override
  List<Object?> get props => [filters];
}
