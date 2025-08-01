import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:letdem/core/extensions/locale.dart';


String getMonthName(int month) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];
  return months[month - 1];
}

String formatDate(DateTime date, BuildContext context) {
  final now = DateTime.now();

  return DateFormat(
      context.isSpanish
          ? "dd 'de' MMM. yyyy"
          : "dd MMM. yyyy",
      context.isSpanish ? 'es' : 'en'
  )
      .format(now.toLocal());
}