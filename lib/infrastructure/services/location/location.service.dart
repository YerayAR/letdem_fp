import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:letdem/core/constants/credentials.dart';
import 'package:letdem/core/extensions/locale.dart';
import 'package:letdem/infrastructure/api/api/api.service.dart';
import 'package:letdem/infrastructure/api/api/endpoints.dart';
import 'package:letdem/infrastructure/api/api/models/endpoint.dart';
import 'package:letdem/infrastructure/api/api/models/response.model.dart';
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

  static Future<RouteInfo> getRoutes({
    required double currentPointLatitude,
    required double currentPointLongitude,
    String? destination,
    double? destinationLatitude,
    double? destinationLongitude,
  }) async {
    List<QParam> params = [];

    assert(destination != null ||
        (destinationLatitude != null && destinationLongitude != null));

    if (destinationLatitude != null && destinationLongitude != null) {
      params.add(QParam(
        key: 'destination-point',
        value: '$destinationLatitude,$destinationLongitude',
      ));
    } else {
      params.add(QParam(key: 'destination-address', value: destination!));
    }

    params.add(
      QParam(
          key: 'current-point',
          value: '$currentPointLatitude,$currentPointLongitude'),
    );

    EndPoints.getRoute.setParams(params);

    ApiResponse response =
        await ApiService.sendRequest(endpoint: EndPoints.getRoute);

    return RouteInfo.fromMap(response.data['routes'][0]);
  }

  static Future<CoordinatesData?> getLatLng(String mapboxId) async {
    print('mapboxId: $mapboxId');
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

enum TrafficLevel {
  low,
  moderate,
  heavy,
}

String formatTrafficLevel(TrafficLevel level, BuildContext context) {
  switch (level) {
    case TrafficLevel.low:
      return context.l10n.trafficLow;
    case TrafficLevel.moderate:
      return context.l10n.trafficModerate;
    case TrafficLevel.heavy:
      return context.l10n.trafficHeavy;
  }
}

TrafficLevel fromString(String value) {
  switch (value) {
    case 'low':
      return TrafficLevel.low;
    case 'moderate':
      return TrafficLevel.moderate;
    case 'heavy':
      return TrafficLevel.heavy;
    default:
      return TrafficLevel.moderate; // Default case
  }
}

class RouteInfo {
  final TrafficLevel tafficLevel;
  final double distance;

  final int duration;

  final DateTime arrivingAt;

  RouteInfo(
      {required this.tafficLevel,
      required this.distance,
      required this.duration,
      required this.arrivingAt});

  factory RouteInfo.fromMap(Map<String, dynamic> map) {
    return RouteInfo(
      tafficLevel: fromString(map['traffic_level'] as String),
      distance: double.parse(map['distance'].toString()),
      duration: int.parse(map['duration'].toString()),
      arrivingAt: DateTime.parse(map['arriving_at']),
    );
  }
}
