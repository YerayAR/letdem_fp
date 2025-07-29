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
  print('Converting status: $status');
  switch (status.toLowerCase()) {
    case 'confirmed':
      return ReservedStatus.confirmed;
    case 'pending':
      return ReservedStatus.pending;
    case 'reserved':
      return ReservedStatus.reserved;
    case 'cancelled':
      return ReservedStatus.canceled;
    case 'expired':
      return ReservedStatus.expired;
    default:
      throw ArgumentError('Unknown reserved status: $status');
  }
}

String reservedStatusToString(ReservedStatus status) {
  return status.name.toUpperCase();
}
