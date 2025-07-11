import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

extension PriceFormatter on num {
  String formatPrice(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;

    final format = NumberFormat.currency(
      symbol: '',
      decimalDigits: 2,
      locale: locale == 'es' ? 'es_ES' : 'en_GB',
    );

    return '${format.format(this).trim()}€';
  }
}
