class PaymentMethodModel {
  final String paymentMethodId;
  final String holderName;
  final String last4;
  final String brand;

  final String expMonth;
  final String expYear;
  final bool isDefault;

  PaymentMethodModel({
    required this.paymentMethodId,
    required this.holderName,
    required this.last4,
    required this.expMonth,
    required this.expYear,
    required this.brand,
    required this.isDefault,
  });

  getMonthName() {
    switch (expMonth) {
      case '01':
        return 'Jan';
      case '02':
        return 'Feb';
      case '03':
        return 'Mar';
      case '04':
        return 'Apr';
      case '05':
        return 'May';
      case '06':
        return 'Jun';
      case '07':
        return 'Jul';
      case '08':
        return 'Aug';
      case '09':
        return 'Sep';
      case '10':
        return 'Oct';
      case '11':
        return 'Nov';
      case '12':
        return 'Dec';
      default:
        return '';
    }
  }

  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) {
    return PaymentMethodModel(
      paymentMethodId: json['id'],
      holderName: json['holder_name'],
      expMonth: json['expiration_date'] == null
          ? ""
          : json['expiration_date']['month'].toString(),
      expYear: json['expiration_date'] == null
          ? ""
          : json['expiration_date']['year'].toString(),
      last4: json['last4'],
      brand: json['brand'],
      isDefault: json['is_default'],
    );
  }
}
