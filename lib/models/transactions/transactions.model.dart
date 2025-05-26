class TransactionParams {
  final DateTime startDate;
  final DateTime endDate;
  final int pageSize;
  final int page;
  TransactionParams({
    required this.startDate,
    required this.endDate,
    required this.pageSize,
    required this.page,
  });
}

enum TransactionType {
  SPACE_PAYMENT,
  WITHDRAW,
  SPACE_TRANSFER,
  SPACE_WITHDRAWAL,
  SPACE_DEPOSIT,
}

TransactionType getTransactionType(String type) {
  switch (type) {
    case 'SPACE_PAYMENT':
      return TransactionType.SPACE_PAYMENT;
    case 'WITHDRAW':
      return TransactionType.WITHDRAW;
    case 'SPACE_TRANSFER':
      return TransactionType.SPACE_TRANSFER;
    case 'SPACE_WITHDRAWAL':
      return TransactionType.SPACE_WITHDRAWAL;
    case 'SPACE_DEPOSIT':
      return TransactionType.SPACE_DEPOSIT;
    default:
      throw Exception('Unknown transaction type: $type');
  }
}

class Transaction {
  // {amount: 2.00, currency: eur, source: SPACE_PAYMENT, created: 2025-05-09T00:49:26.802051Z}
  final double amount;
  final TransactionType source;
  final DateTime created;

  Transaction(
      {required this.amount, required this.source, required this.created});

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      amount: getTransactionType(json['source']) == TransactionType.WITHDRAW
          ? double.parse(json['amount'].toString()) * -1
          : double.parse(json['amount'].toString()),
      source: getTransactionType(json['source']),
      created: DateTime.parse(json['created']),
    );
  }
}
