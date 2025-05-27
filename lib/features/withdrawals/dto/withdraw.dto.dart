import 'package:letdem/infrastructure/api/api/models/endpoint.dart';

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
