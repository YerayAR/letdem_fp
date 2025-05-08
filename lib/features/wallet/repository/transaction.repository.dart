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
        value: data.startDate.toIso8601String(),
      ),
      QParam(
        key: 'end_date',
        value: data.endDate.toIso8601String(),
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
        .map((e) => Transaction(
              id: e['id'],
              amount: e['amount'],
              description: e['description'],
              date: DateTime.parse(e['date']),
            ))
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

class Transaction {
  final String id;
  final double amount;
  final String description;
  final DateTime date;

  Transaction({
    required this.id,
    required this.amount,
    required this.description,
    required this.date,
  });
}
