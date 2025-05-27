import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:letdem/features/payout_methods/repository/payout.repository.dart';
import 'package:letdem/models/withdrawals/withdrawal.model.dart';

import 'repository/withdrawal.repository.dart';

part 'withdrawal_event.dart';
part 'withdrawal_state.dart';

class WithdrawalBloc extends Bloc<WithdrawalEvent, WithdrawalState> {
  final WithdrawalRepository withdrawalRepository;
  WithdrawalBloc({
    required this.withdrawalRepository,
  }) : super(WithdrawalInitial()) {
    on<WithdrawalEvent>(_onFetch);
    on<WithdrawMoneyEvent>(_onWithdraw);
  }

  Future<void> _onWithdraw(
      WithdrawMoneyEvent event, Emitter<WithdrawalState> emit) async {
    emit(WithdrawalLoading());
    try {
      await withdrawalRepository.withdrawMoney(event.methodId, event.amount);
      var newWithdrawals = await withdrawalRepository.fetchWithdrawals();
      emit(WithdrawalSuccess(newWithdrawals));
    } catch (e, sr) {
      print(e);
      print(sr);
      emit(WithdrawalFailure(e.toString()));
    }
  }

  Future<void> _onFetch(
      WithdrawalEvent event, Emitter<WithdrawalState> emit) async {
    emit(WithdrawalLoading());
    try {
      final withdrawals = await withdrawalRepository.fetchWithdrawals();
      emit(WithdrawalSuccess(withdrawals));
    } catch (e, sr) {
      print(e);
      print(sr);
      emit(WithdrawalFailure(e.toString()));
    }
  }
}
