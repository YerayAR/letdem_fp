import 'package:letdem/models/transactions/transactions.model.dart';

abstract class ITransactionRepository {
  Future<List<Transaction>> fetchTransactions(TransactionParams data);
  Future<List<Transaction>> fetchLastTransactions(TransactionParams data);
}
