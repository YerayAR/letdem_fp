class PaymentMethodModel {
  final String paymentMethodId;
  final String holderName;
  final String last4;
  final String brand;
  final bool isDefault;

  PaymentMethodModel({
    required this.paymentMethodId,
    required this.holderName,
    required this.last4,
    required this.brand,
    required this.isDefault,
  });

  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) {
    return PaymentMethodModel(
      paymentMethodId: json['id'],
      holderName: json['holder_name'],
      last4: json['last4'],
      brand: json['brand'],
      isDefault: json['is_default'],
    );
  }
}
