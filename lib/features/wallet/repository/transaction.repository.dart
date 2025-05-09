import 'package:letdem/services/api/api.service.dart';
import 'package:letdem/services/api/endpoints.dart';
import 'package:letdem/services/api/models/endpoint.dart';
import 'package:letdem/services/api/models/response.model.dart';

class TransactionRepository implements ITransactionRepository {
  @override
  Future<void> addTransaction(Transaction transaction) {
    // TODO: implement addTransaction
    throw UnimplementedError();
  }

  @override
  Future<void> deleteTransaction(String transactionId) {
    // TODO: implement deleteTransaction
    throw UnimplementedError();
  }

  @override
  Future<List<Transaction>> fetchTransactions(TransactionParams data) async {
    EndPoints.getTransactions.setParams([
      QParam(
        key: 'start_date',
        value:
            "${data.startDate.year}-${data.startDate.month}-${data.startDate.day}",
      ),
      QParam(
        key: 'end_date',
        value: "${data.endDate.year}-${data.endDate.month}-${data.endDate.day}",
      ),
      QParam(
        key: 'page_size',
        value: data.pageSize.toString(),
      ),
      QParam(
        key: 'page',
        value: data.page.toString(),
      ),
    ]);
    ApiResponse response =
        await ApiService.sendRequest(endpoint: EndPoints.getTransactions);

    return (response.data['results'] as List)
        .map((e) => Transaction.fromJson(e))
        .toList();
  }
}

class TransactionParams {
  // start_date=2025-05-02&end_date=2025-05-03&page_size=5&page=1

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

abstract class ITransactionRepository {
  Future<List<Transaction>> fetchTransactions(TransactionParams data);
  Future<void> addTransaction(Transaction transaction);
  Future<void> deleteTransaction(String transactionId);
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
