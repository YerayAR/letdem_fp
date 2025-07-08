import 'package:flutter/material.dart';
import 'package:letdem/core/enums/LetDemLocationType.dart';
import 'package:letdem/core/extensions/locale.dart';

class LocationUtils {
  static String getLocationTypeString(BuildContext context, LetDemLocationType type) {
    switch (type) {
      case LetDemLocationType.other:
        return context.l10n.otherLocation;
      case LetDemLocationType.home:
        return context.l10n.homeLocation;
      case LetDemLocationType.work:
        return context.l10n.workLocation;
    }
  }
}