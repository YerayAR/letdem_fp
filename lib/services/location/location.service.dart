import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:letdem/constants/credentials.dart';
import 'package:letdem/models/map/coordinate.model.dart';

class CurrentLocationPayload {
  final double latitude;
  final double longitude;
  final String? locationName;

  final String? shortLocationName;

  CurrentLocationPayload({
    required this.latitude,
    required this.longitude,
    required this.shortLocationName,
    this.locationName,
  });

  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory CurrentLocationPayload.fromMap(Map<String, dynamic> map) {
    return CurrentLocationPayload(
      shortLocationName: '',
      latitude: map['latitude'],
      longitude: map['longitude'],
    );
  }

  String toJson() => json.encode(toMap());

  factory CurrentLocationPayload.fromJson(String source) =>
      CurrentLocationPayload.fromMap(json.decode(source));
}

class MapboxService {
  static Future<CurrentLocationPayload?> getPlaceFromLatLng() async {
    // use geolocator to get current location

    var position = await Geolocator.getCurrentPosition();

    final url =
        //     https://api.mapbox.com/search/geocode/v6/reverse?longitude={longitude}&latitude={latitude}
        'https://api.mapbox.com/geocoding/v5/mapbox.places/${position.longitude},${position.latitude}.json?access_token=${AppCredentials.mapBoxAccessToken}';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print(data);
        if (data['features'].isNotEmpty) {
          CurrentLocationPayload currentLocationPayload =
              CurrentLocationPayload(
            latitude: position.latitude,
            shortLocationName: data['features'][0]['text'],
            longitude: position.longitude,
            locationName: data['features'][0]['place_name'].split(',')[0],
          );
          return currentLocationPayload;
          // return data['features'][0]['place_name']; // Returns formatted address
        } else {
          return null;
        }
      } else {
        return null;
      }
    } catch (e) {
      print(e);
      return null;
    }
  }

  static Future<CoordinatesData?> getLatLng(String mapboxId) async {
    // https://api.mapbox.com/search/geocode/v6/forward?q=heath&proximity=ip&access_token=pk.eyJ1IjoidmhlbXNhcmEiLCJhIjoiY203cDZnaGltMGdndDJrcXlwdTY3ODY2biJ9.3C6sly2ynJCEVLb3t5uAjA

    final url =
        'https://api.mapbox.com/search/geocode/v6/forward?q=$mapboxId&proximity=ip&access_token=${AppCredentials.mapBoxAccessToken}';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        print(data);
        if (data['features'] != null && data['features'].isNotEmpty) {
          final lat = data['features'][0]['geometry']['coordinates'][1];
          final lng = data['features'][0]['geometry']['coordinates'][0];

          return CoordinatesData(latitude: lat, longitude: lng);
        } else {
          print('Failed to load data: ${response.statusCode}');
        }
      }
    } catch (e) {
      print('Error: $e');
    }
    return null;
  }
}
