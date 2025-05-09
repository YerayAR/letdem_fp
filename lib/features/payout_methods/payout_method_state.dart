part of 'payout_method_bloc.dart';

sealed class PayoutMethodState extends Equatable {
  const PayoutMethodState();
}

final class PayoutMethodInitial extends PayoutMethodState {
  @override
  List<Object> get props => [];
}
