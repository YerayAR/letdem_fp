import 'package:letdem/services/api/models/endpoint.dart';

class ReserveSpaceDTO extends DTO {
  final String paymentMethodID;

  ReserveSpaceDTO({required this.paymentMethodID});

  @override
  Map<String, dynamic> toMap() {
    return {
      "payment_method_id": paymentMethodID,
    };
  }
}
