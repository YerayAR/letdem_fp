import 'package:letdem/core/extensions/locale.dart';
import 'package:letdem/infrastructure/services/res/navigator.dart';

extension TimeFormatter on int {
  String toFormattedTime() {
    if (this < 60) {
      return "1 ${NavigatorHelper.navigatorKey.currentContext!.l10n.minutes}"
          .toLowerCase();
    } else if (this < 3600) {
      final minutes = (this / 60).floor();
      return "${minutes} ${NavigatorHelper.navigatorKey.currentContext!.l10n.minutes}"
          .toLowerCase();
    } else {
      final hours = (this / 3600).floor();
      final minutes = ((this % 3600) / 60).floor();
      return minutes > 0 ? "${hours}h ${minutes}m" : "${hours}h";
    }
  }

  String toFormattedDistance() {
    if (this >= 1000) {
      final km = (this / 1000).round();
      return "$km km";
    } else {
      return "$this ${NavigatorHelper.navigatorKey.currentContext!.l10n.meters}";
    }
  }
}
