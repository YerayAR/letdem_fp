import 'package:letdem/core/constants/assets.dart';

enum EventTypes {
  police,
  closeRoad,

  accident
}

String getEventMessage(EventTypes eventType) {
  switch (eventType) {
    case EventTypes.police:
      return 'Police ahead';
    case EventTypes.closeRoad:
      return 'Road closed ahead';
    case EventTypes.accident:
      return 'Accident ahead';
    default:
      return 'Unknown event ahead';
  }
}

String eventTypeToString(EventTypes type) {
  switch (type) {
    case EventTypes.police:
      return "Police";
    case EventTypes.closeRoad:
      return "Closed Road";
    case EventTypes.accident:
      return "Accident";
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
}
