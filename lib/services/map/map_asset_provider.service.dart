import 'package:flutter/services.dart';
import 'package:letdem/constants/ui/assets.dart';
import 'package:letdem/enums/EventTypes.dart';
import 'package:letdem/views/app/publish_space/screens/publish_space.view.dart';

class MapAssetsProvider {
  late Uint8List freeMarker, greenMarker, blueMarker, disasterMarker;

  late Uint8List currentLocationMarker;

  late Uint8List destinationMarker;
  late Uint8List accidentMarker, closedRoadMarker, policeMarker;

  Future<void> loadAssets() async {
    freeMarker = await _loadImage(AppAssets.freeMapMarker);
    destinationMarker = await _loadImage(AppAssets.destinationMapMarker);
    greenMarker = await _loadImage(AppAssets.greenMapMarker);
    blueMarker = await _loadImage(AppAssets.blueMapMarker);
    disasterMarker = await _loadImage(AppAssets.disabledMapMarker);

    currentLocationMarker =
        await _loadImage(AppAssets.currentLocationMapMarker);

    accidentMarker = await _loadImage(AppAssets.accidentMapMarker);
    closedRoadMarker = await _loadImage(AppAssets.closedRoadMapMarker);
    policeMarker = await _loadImage(AppAssets.policeMapMarker);
  }

  // getter for current location marker
  Uint8List get currentLocationMarkerImageData => currentLocationMarker;

  Future<Uint8List> _loadImage(String path) async {
    ByteData byteData = await rootBundle.load(path);
    return Uint8List.view(byteData.buffer);

    // return byteData.buffer.asUint8List();
  }

  Uint8List getImageForType(PublishSpaceType type) {
    switch (type) {
      case PublishSpaceType.free:
        return freeMarker;
      case PublishSpaceType.greenZone:
        return greenMarker;
      case PublishSpaceType.blueZone:
        return blueMarker;
      case PublishSpaceType.disabled:
        return disasterMarker;
    }
  }

  static String getAssetEvent(EventTypes type) {
    switch (type) {
      case EventTypes.accident:
        return AppAssets.accident;
      case EventTypes.police:
        return AppAssets.policeMapMarker;
      case EventTypes.closeRoad:
        return AppAssets.closedRoadMapMarker;
    }
  }

  Uint8List getEventIcon(EventTypes type) {
    switch (type) {
      case EventTypes.accident:
        return accidentMarker;
      case EventTypes.police:
        return policeMarker;
      case EventTypes.closeRoad:
        return closedRoadMarker;
    }
  }
}
