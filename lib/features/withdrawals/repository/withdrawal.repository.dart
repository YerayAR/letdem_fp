import 'package:letdem/features/payout_methods/repository/payout.repository.dart';
import 'package:letdem/features/withdrawals/dto/withdraw.dto.dart';
import 'package:letdem/models/withdrawals/withdrawal.bloc.dart';
import 'package:letdem/services/api/api.service.dart';
import 'package:letdem/services/api/endpoints.dart';

import 'withdrawel.interface.dart';

class WithdrawalRepository extends WithdrawalInterface {
  @override
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
