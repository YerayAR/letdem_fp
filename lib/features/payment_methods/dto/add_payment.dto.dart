import 'package:letdem/infrastructure/api/api/models/endpoint.dart';

class AddPaymentMethodDTO extends DTO {
  final String paymentMethodId;
  final String holderName;
  final String last4;
  final String brand;
  final bool isDefault;

  final String expirationDate;

  AddPaymentMethodDTO({
    required this.paymentMethodId,
    required this.holderName,
    required this.last4,
    required this.brand,
    required this.isDefault,
    required this.expirationDate,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'payment_method_id': paymentMethodId,
      'holder_name': holderName,
      'last4': last4,
      'expiration_date': expirationDate,
      'brand': brand,
      'is_default': isDefault,
    };
  }
}
