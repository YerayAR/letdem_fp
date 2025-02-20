import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:letdem/constants/credentials.dart';

class CurrentLocationPayload {
  final double latitude;
  final double longitude;
  final String? locationName;

  CurrentLocationPayload({
    required this.latitude,
    required this.longitude,
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
            longitude: position.longitude,
            locationName: data['features'][0]['place_name'],
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
}
