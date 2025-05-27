import 'package:letdem/core/constants/assets.dart';

enum PublishSpaceType {
  free,
  blueZone,
  disabled,
  greenZone,

  paidFree,
  paidBlue,
  paidDisabled,
  paidGreenZone,
}

String getSpaceTypeText(PublishSpaceType type) {
  switch (type) {
    case PublishSpaceType.free:
      return 'Free';
    case PublishSpaceType.blueZone:
      return 'Blue Zone';
    case PublishSpaceType.disabled:
      return 'Disabled';
    case PublishSpaceType.greenZone:
      return 'Green';
    case PublishSpaceType.paidFree:
      return 'Paid Free';
    case PublishSpaceType.paidBlue:
      return 'Paid Blue Zone';
    case PublishSpaceType.paidDisabled:
      return 'Paid Disabled';
    case PublishSpaceType.paidGreenZone:
      return 'Paid Green Zone';
  }
}

String getSpaceAvailabilityMessage(PublishSpaceType spaceType) {
  switch (spaceType) {
    case PublishSpaceType.free:
      return 'Free';
    case PublishSpaceType.blueZone:
      return 'Blue Zone';
    case PublishSpaceType.disabled:
      return 'Disabled';
    case PublishSpaceType.greenZone:
      return 'Green Zone';
    case PublishSpaceType.paidFree:
      return 'Free';
    case PublishSpaceType.paidBlue:
      return 'Blue Zone';
    case PublishSpaceType.paidDisabled:
      return 'Disabled';
    case PublishSpaceType.paidGreenZone:
      return 'Green Zone';
  }
}

PublishSpaceType getEnumFromText(String text, String resourceType) {
  switch (text) {
    case 'FREE':
      return resourceType == 'PaidSpace'
          ? PublishSpaceType.paidFree
          : PublishSpaceType.free;
    case 'BLUE':
      return resourceType == 'PaidSpace'
          ? PublishSpaceType.paidBlue
          : PublishSpaceType.blueZone;
    case 'DISABLED':
      return resourceType == 'PaidSpace'
          ? PublishSpaceType.paidDisabled
          : PublishSpaceType.disabled;
    case 'GREEN':
      return resourceType == 'PaidSpace'
          ? PublishSpaceType.paidGreenZone
          : PublishSpaceType.greenZone;

    default:
      return PublishSpaceType.greenZone;
  }
}

String getEnumText(PublishSpaceType type) {
  switch (type) {
    case PublishSpaceType.free:
      return 'FREE';
    case PublishSpaceType.blueZone:
      return 'BLUE';
    case PublishSpaceType.disabled:
      return 'DISABLED';
    case PublishSpaceType.greenZone:
      return 'GREEN';
    case PublishSpaceType.paidFree:
      return 'FREE';
    case PublishSpaceType.paidBlue:
      return 'BLUE';
    case PublishSpaceType.paidDisabled:
      return 'DISABLED';
    case PublishSpaceType.paidGreenZone:
      return 'GREEN';
  }
}

String getSpaceTypeIcon(PublishSpaceType type) {
  switch (type) {
    case PublishSpaceType.free:
      return AppAssets.free;
    case PublishSpaceType.blueZone:
      return AppAssets.blue;
    case PublishSpaceType.disabled:
      return AppAssets.disabled;
    case PublishSpaceType.greenZone:
      return AppAssets.green;
    case PublishSpaceType.paidFree:
      return AppAssets.free;
    case PublishSpaceType.paidBlue:
      return AppAssets.blue;
    case PublishSpaceType.paidDisabled:
      return AppAssets.disabled;
    case PublishSpaceType.paidGreenZone:
      return AppAssets.green;
  }
}
