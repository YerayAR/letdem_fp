import 'package:flutter/material.dart';
import 'package:letdem/core/extensions/locale.dart';

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

  String getMonthName(BuildContext context) {
    switch (expMonth) {
      case '01' || '1':
        return context.l10n.monthJan;
      case '02' || '2':
        return context.l10n.monthFeb;
      case '03' || '3':
        return context.l10n.monthMar;
      case '04' || '4':
        return context.l10n.monthApr;
      case '05' || '5':
        return context.l10n.monthMay;
      case '06' || '6':
        return context.l10n.monthJun;
      case '07' || '7':
        return context.l10n.monthJul;
      case '08' || '8':
        return context.l10n.monthAug;
      case '09' || '9':
        return context.l10n.monthSep;
      case '10' || '10':
        return context.l10n.monthOct;
      case '11' || '11':
        return context.l10n.monthNov;
      case '12' || '12':
        return context.l10n.monthDec;
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
