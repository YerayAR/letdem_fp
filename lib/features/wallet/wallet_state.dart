part of 'wallet_bloc.dart';

sealed class WalletState extends Equatable {
  const WalletState();
}

final class WalletInitial extends WalletState {
  @override
  List<Object> get props => [];
}
