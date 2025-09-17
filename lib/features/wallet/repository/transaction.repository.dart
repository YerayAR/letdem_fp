import 'package:letdem/infrastructure/api/api/api.service.dart';
import 'package:letdem/infrastructure/api/api/endpoints.dart';
import 'package:letdem/infrastructure/api/api/models/endpoint.dart';
import 'package:letdem/infrastructure/api/api/models/response.model.dart';

import '../../../models/transactions/transactions.model.dart';
import 'transaction.interface.dart';

class TransactionRepository implements ITransactionRepository {
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

  @override
  Future<List<Transaction>> fetchLastTransactions(TransactionParams data) async {
    EndPoints.getTransactions.setParams([
      QParam(
        key: 'page_size',
        value: '5',
      ),
      QParam(
        key: 'page',
        value: '1',
      ),
    ]);
    ApiResponse response =
    await ApiService.sendRequest(endpoint: EndPoints.getTransactions);

    return (response.data['results'] as List)
        .map((e) => Transaction.fromJson(e))
        .toList();
  }
}
