enum WithdrawalStatus { completed, failed, pending }

WithdrawalStatus payoutStatusFromString(String value) {
  switch (value.toUpperCase()) {
    case 'COMPLETED':
      return WithdrawalStatus.completed;
    case 'FAILED':
      return WithdrawalStatus.failed;
    case 'PENDING':
      return WithdrawalStatus.pending;
    default:
      throw ArgumentError('Unknown payout status: $value');
  }
}

String payoutStatusToString(WithdrawalStatus status) {
  return status.name.toUpperCase();
}

class Withdrawal {
  final String id;
  final double amount;
  final WithdrawalStatus status;
  final String maskedPayoutMethod;
  final DateTime created;

  Withdrawal({
    required this.id,
    required this.amount,
    required this.status,
    required this.maskedPayoutMethod,
    required this.created,
  });

  factory Withdrawal.fromJson(Map<String, dynamic> json) {
    return Withdrawal(
      id: json['id'],
      amount: double.parse(json['amount']),
      status: payoutStatusFromString(json['status']),
      maskedPayoutMethod: json['masked_payout_method'],
      created: DateTime.parse(json['created']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount.toStringAsFixed(2),
      'status': payoutStatusToString(status),
      'masked_payout_method': maskedPayoutMethod,
      'created': created.toIso8601String(),
    };
  }
}
