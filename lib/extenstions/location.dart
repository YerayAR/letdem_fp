import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';

extension LocationPermissionExtension on BuildContext {
  Future<bool> get hasLocationPermission async {
    LocationPermission permission = await Geolocator.checkPermission();
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }
}
