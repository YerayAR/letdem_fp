import 'package:flutter/cupertino.dart';
import 'package:letdem/core/extensions/locale.dart';

import 'package:letdem/infrastructure/services/res/navigator.dart';

import 'package:letdem/infrastructure/services/location/location.service.dart';

String parseMeters(
    double distance, [
      bool longFormat = false,
    ]) {
  var context = NavigatorHelper.navigatorKey.currentState!.context;
  // distance is in km
  return distance < 1
      ? "${(1).toStringAsFixed(0)} ${context.l10n.meters}"
      : distance < 1000
      ? "${distance.toStringAsFixed(0)} ${context.l10n.meters}"
      : "${(distance / 1000).toStringAsFixed(1)} km";
}

String parseHours(BuildContext context, int min) {
  if (min <= 0) {
    return "1 ${context.l10n.minutesShort}";
  }

  if (min < 60) {
    return "$min ${context.l10n.minutesShort}";
  } else {
    return "${(min / 60).toStringAsFixed(0)} ${context.l10n.hoursShort}";
  }
}

TrafficLevel parseTrafficCongestion(int trafficDelaySeconds, int durationSeconds) {
  // Traffic level calculation
  double delayPercent = durationSeconds > 0
      ? (trafficDelaySeconds / durationSeconds) * 100
      : 0;

  if (delayPercent < 10) {
    return TrafficLevel.low;
  } else if (delayPercent < 25) {
    return  TrafficLevel.moderate;
  } else {
    return TrafficLevel.heavy;
  }
}