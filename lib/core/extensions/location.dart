import 'package:flutter/cupertino.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

extension LocationPermissionExtension on BuildContext {
  Future<bool> get hasLocationPermission async {
    LocationPermission permission = await Geolocator.checkPermission();
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  Future<String?> getUserCountry() async {
    try {
      // Request permission if not granted
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

      // Get user position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Get country from coordinates
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      print("Placemarks: $placemarks");

      if (placemarks.isNotEmpty) {
        return placemarks.first.isoCountryCode;
      }
      return null;
    } catch (e) {
      debugPrint("Error getting country: $e");
      return null;
    }
  }
}
