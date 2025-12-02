import 'package:letdem/infrastructure/api/api/models/endpoint.dart';

class MoneyTransferDTO extends DTO {
  final String recipientUuid;
  final double amount;
  final String currency;
  final String? description;

  MoneyTransferDTO({
    required this.recipientUuid,
    required this.amount,
    required this.currency,
    this.description,
  });

  @override
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'recipient_uuid': recipientUuid,
      'amount': amount,
      'currency': currency,
    };

    if (description != null && description!.trim().isNotEmpty) {
      map['description'] = description;
    }

    return map;
  }
}

class PointsTransferDTO extends DTO {
  final String recipientUuid;
  final int points;
  final String? description;

  PointsTransferDTO({
    required this.recipientUuid,
    required this.points,
    this.description,
  });

  @override
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'recipient_uuid': recipientUuid,
      'points': points,
    };

    if (description != null && description!.trim().isNotEmpty) {
      map['description'] = description;
    }

    return map;
  }
}
