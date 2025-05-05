part of 'earning_account_bloc.dart';

sealed class EarningAccountState extends Equatable {
  const EarningAccountState();
}

final class EarningAccountInitial extends EarningAccountState {
  @override
  List<Object> get props => [];
}
