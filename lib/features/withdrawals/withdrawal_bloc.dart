import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:letdem/features/payout_methods/payout_method_bloc.dart';
import 'package:letdem/features/payout_methods/repository/payout.repository.dart';
import 'package:letdem/services/api/api.service.dart';
import 'package:letdem/services/api/endpoints.dart';
import 'package:letdem/services/api/models/endpoint.dart';

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

class WithdrawalRepository extends WithdrawalInterface {
  Future<List<Withdrawal>> fetchWithdrawals({String? methodId}) async {
    var res = await ApiService.sendRequest(endpoint: EndPoints.getWithdrawals);

    return res.data['results']
        .map<Withdrawal>((e) => Withdrawal.fromJson(e))
        .toList();
  }

  @override
  Future<void> withdrawMoney(PayoutMethod methodId, double amount) async {
    await ApiService.sendRequest(
      endpoint: EndPoints.withdrawMoney.copyWithDTO(
        WithdrawMoneyDTO(
          methodId: methodId.id,
          amount: amount,
        ),
      ),
    );
  }
}

abstract class WithdrawalInterface {
  Future<List<Withdrawal>> fetchWithdrawals({String? methodId});
  Future<void> withdrawMoney(PayoutMethod methodId, double amount);
}

class WithdrawMoneyDTO extends DTO {
  final String methodId;
  final double amount;

  WithdrawMoneyDTO({
    required this.methodId,
    required this.amount,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'payout_method_id': methodId,
      'amount': amount,
    };
  }
}
