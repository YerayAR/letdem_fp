import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:letdem/core/extensions/locale.dart';

import 'package:letdem/infrastructure/toast/toast/toast.dart';


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
  return DateFormat(
      context.isSpanish
          ? "dd 'de' MMM. yyyy"
          : "dd MMM. yyyy",
      context.isSpanish ? 'es' : 'en'
  ).format(date.toLocal());
}


bool validateDateTime(BuildContext context, DateTime? start, DateTime? end) {
  DateTime now = DateTime.now();

  if (start == null || end == null) {
    Toast.showError(context.l10n.timesRequired);
    return false;
  }

  if (start.isAfter(end) || start.isAtSameMomentAs(end)) {
    Toast.showError(context.l10n.startBeforeEnd);
    return false;
  }

  if (start.isBefore(now) || end.isBefore(now)) {
    Toast.showError(context.l10n.timeGreaterThanCurrent);
    return false;
  }

  // Ensure difference is not greater than 5 days (including milliseconds rounding)
  if (end.difference(start).inMilliseconds >
      const Duration(days: 5).inMilliseconds) {
    Toast.showError(context.l10n.maxScheduleDays);
    return false;
  }

  return true;
}
