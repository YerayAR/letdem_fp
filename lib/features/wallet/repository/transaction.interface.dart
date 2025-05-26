import 'package:letdem/models/transactions/transactions.model.dart';

abstract class ITransactionRepository {
  Future<List<Transaction>> fetchTransactions(TransactionParams data);
  Future<void> addTransaction(Transaction transaction);
  Future<void> deleteTransaction(String transactionId);
}
