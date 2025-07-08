import 'package:flutter/material.dart';
import 'package:letdem/core/constants/assets.dart';
import 'package:letdem/core/extensions/locale.dart';

enum EventTypes {
  police,
  closeRoad,

  accident
}

String getEventMessage(EventTypes eventType, BuildContext context) {
  switch (eventType) {
    case EventTypes.police:
      return context.l10n.policeAhead;
    case EventTypes.closeRoad:
      return context.l10n.roadClosedAhead;
    case EventTypes.accident:
      return context.l10n.accidentAhead;
    default:
      return context.l10n.unknownEventAhead;
  }
}

String eventTypeToString(EventTypes type, BuildContext context) {
  switch (type) {
    case EventTypes.police:
      return context.l10n.police;
    case EventTypes.closeRoad:
      return context.l10n.closedRoad;
    case EventTypes.accident:
      return context.l10n.accident;
  }
}

String getEnumName(EventTypes t) {
  switch (t) {
    case EventTypes.accident:
      return "ACCIDENT";
    case EventTypes.police:
      return "POLICE";
    case EventTypes.closeRoad:
      return "CLOSED_ROAD";
  }
}

EventTypes getEventEnumFromText(String t) {
  switch (t) {
    case "ACCIDENT":
      return EventTypes.accident;
    case "POLICE":
      return EventTypes.police;
    case "CLOSED_ROAD":
      return EventTypes.closeRoad;

    default:
      return EventTypes.accident;
  }
}

String getEventTypeIcon(EventTypes type) {
  switch (type) {
    case EventTypes.police:
      return AppAssets.police;
    case EventTypes.closeRoad:
      return AppAssets.closeRoad;
    case EventTypes.accident:
      return AppAssets.accident;
  }

  // Police: 1E90FF
  // Accident: FF0000
  // Closed Road: FFA500
}

int getEventTypeIconColor(EventTypes type) {
  switch (type) {
    case EventTypes.police:
      return 0xff1E90FF;
    case EventTypes.closeRoad:
      return 0xffFFA500;
    case EventTypes.accident:
      return 0xffFF0000;
  }
}
