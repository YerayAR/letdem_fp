import 'package:letdem/features/payout_methods/repository/payout.repository.dart';
import 'package:letdem/models/withdrawals/withdrawal.model.dart';

abstract class WithdrawalInterface {
  Future<List<Withdrawal>> fetchWithdrawals({String? methodId});
  Future<void> withdrawMoney(PayoutMethod methodId, double amount);
}
