import 'package:intl/intl.dart';

extension DateTimeExtensions on DateTime {
  String toLocalFormattedString({String format = 'yyyy-MM-dd HH:mm:ss'}) {
    return DateFormat(format).format(toLocal());
  }

  static String fromUtcString(String utcTime,
      {String format = 'yyyy-MM-dd HH:mm:ss'}) {
    DateTime dateTime = DateTime.parse(utcTime).toLocal();
    return DateFormat(format).format(dateTime);
  }
}
