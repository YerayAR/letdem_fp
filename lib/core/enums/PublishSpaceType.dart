import 'package:flutter/material.dart';
import 'package:letdem/core/constants/assets.dart';
import 'package:letdem/core/extensions/locale.dart';

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

String getSpaceTypeText(PublishSpaceType type, BuildContext context) {
  switch (type) {
    case PublishSpaceType.free:
      return context.l10n.freeSpace;
    case PublishSpaceType.blueZone:
      return context.l10n.blueZone;
    case PublishSpaceType.disabled:
      return context.l10n.disabledSpace;
    case PublishSpaceType.greenZone:
      return context.l10n.greenZone;
    case PublishSpaceType.paidFree:
      return context.l10n.paidFreeSpace;
    case PublishSpaceType.paidBlue:
      return context.l10n.paidBlueZone;
    case PublishSpaceType.paidDisabled:
      return context.l10n.paidDisabledSpace;
    case PublishSpaceType.paidGreenZone:
      return context.l10n.paidGreenZone;
  }
}


String getSpaceAvailabilityMessage(PublishSpaceType spaceType, BuildContext context) {
  switch (spaceType) {
    case PublishSpaceType.free:
      return context.l10n.freeSpace;
    case PublishSpaceType.blueZone:
      return context.l10n.blueZone;
    case PublishSpaceType.disabled:
      return context.l10n.disabledSpace;
    case PublishSpaceType.greenZone:
      return context.l10n.greenZone;
    case PublishSpaceType.paidFree:
      return context.l10n.freeSpace;
    case PublishSpaceType.paidBlue:
      return context.l10n.blueZone;
    case PublishSpaceType.paidDisabled:
      return context.l10n.disabledSpace;
    case PublishSpaceType.paidGreenZone:
      return context.l10n.greenZone;
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
