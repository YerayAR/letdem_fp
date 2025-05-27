import 'package:letdem/core/enums/PublishSpaceType.dart';

class Order {
  final String price;
  final PublishSpaceType type;
  final ReservedStatus status;
  final String street;
  final DateTime created;

  Order({
    required this.price,
    required this.type,
    required this.status,
    required this.street,
    required this.created,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      price: json['price'],
      type: getEnumFromText(json['type'], ""),
      status: reservedStatusFromString(json['status']),
      street: json['street'],
      created: DateTime.parse(json['created']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'price': price,
      'type': type,
      'status': reservedStatusToString(status),
      'street': street,
      'created': created.toIso8601String(),
    };
  }
}

enum ReservedStatus {
  confirmed,
  pending,
  reserved,
  canceled,
  expired,
}

ReservedStatus reservedStatusFromString(String status) {
  return ReservedStatus.values.firstWhere(
    (e) => e.name.toLowerCase() == status.toLowerCase(),
    orElse: () => ReservedStatus.pending,
  );
}

String reservedStatusToString(ReservedStatus status) {
  return status.name.toUpperCase();
}
