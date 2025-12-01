import 'package:letdem/infrastructure/api/api/api.service.dart';
import 'package:letdem/infrastructure/api/api/endpoints.dart';

import '../dto/transfers.dto.dart';

class TransferRepository {
  /// Envío de dinero entre usuarios.
  Future<void> sendMoney({
    required String recipientUuid,
    required double amount,
    String currency = 'EUR',
    String? description,
  }) async {
    final endpoint = EndPoints.sendMoneyTransfer.copyWithDTO(
      MoneyTransferDTO(
        recipientUuid: recipientUuid,
        amount: amount,
        currency: currency,
        description: description,
      ),
    );

    await ApiService.sendRequest(endpoint: endpoint);
  }

  /// Envío de puntos entre usuarios.
  Future<void> sendPoints({
    required String recipientUuid,
    required int points,
    String? description,
  }) async {
    final endpoint = EndPoints.sendPointsTransfer.copyWithDTO(
      PointsTransferDTO(
        recipientUuid: recipientUuid,
        points: points,
        description: description,
      ),
    );

    await ApiService.sendRequest(endpoint: endpoint);
  }
}
