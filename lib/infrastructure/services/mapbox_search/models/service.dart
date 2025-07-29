import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HereSearchApiService {
  static final HereSearchApiService _instance =
      HereSearchApiService._internal();

  factory HereSearchApiService() => _instance;

  HereSearchApiService._internal();

  static const String _contentType = "application/json";

  // Replace with your Google Places API key
  static const String googleApiKey = "AIzaSyC7GS-4uZ8LUCoTfItD740nr48KpuL6P9g";
  Future<Map<String, dynamic>?> getPlaceDetailsLatLng(String placeId) async {
    // get current country

    final url =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&fields=geometry&key=$googleApiKey';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final jsonBody = jsonDecode(response.body);
        if (jsonBody['status'] == 'OK') {
          final location = jsonBody['result']?['geometry']?['location'];
          if (location != null) {
            return {
              'lat': location['lat'] as double,
              'lng': location['lng'] as double,
            };
          }
        } else {
          if (kDebugMode) {
            print(
                "❌ [GOOGLE PLACE DETAILS] API error: ${jsonBody['status']}, message: ${jsonBody['error_message'] ?? 'N/A'}");
          }
        }
      } else {
        if (kDebugMode) {
          print(
              "❌ [GOOGLE PLACE DETAILS] Request failed with status: ${response.statusCode}");
        }
      }
    } catch (e, st) {
      if (kDebugMode) {
        print("💥 [GOOGLE PLACE DETAILS] Exception: $e");
        print(st.toString());
      }
    }
    return null;
  }

  /// Calculate distance between two lat/lng points in meters using Haversine formula
  double calculateDistanceMeters(
      double startLat, double startLng, double endLat, double endLng) {
    const earthRadius = 6371000; // meters

    final dLat = _degreesToRadians(endLat - startLat);
    final dLng = _degreesToRadians(endLng - startLng);

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degreesToRadians(startLat)) *
            math.cos(_degreesToRadians(endLat)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (math.pi / 180);
  }

  /// Example traffic level based on distance (dummy logic, you can replace with real API)
  /// Returns traffic level as String: 'Low', 'Moderate', 'Heavy'
  String getTrafficLevel(double distanceMeters) {
    if (distanceMeters < 1000) {
      return 'Low';
    } else if (distanceMeters < 5000) {
      return 'Moderate';
    } else {
      return 'Heavy';
    }
  }

  /// This method now calls **Google Places Autocomplete API**
  /// but returns List<HerePlace> (same as Prediction model)
  Future<List<HerePlace>> getLocationResults(
      String query, BuildContext context) async {
    if (kDebugMode) {
      print("🔍 [GOOGLE API] Starting location search for query: '$query'");
    }

    var countryCode =
        WidgetsBinding.instance.platformDispatcher.locale.countryCode;

    // Build Google Places Autocomplete URL
    final String url =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json'
        '?input=${Uri.encodeQueryComponent(query)}'
        '&key=$googleApiKey'
        '&language=en'
        '&components=country:${countryCode}';

    try {
      if (kDebugMode) {
        print("📡 [GOOGLE API] Request URL: $url");
        print("📤 [GOOGLE API] Making HTTP GET request...");
      }

      final response = await http.get(Uri.parse(url), headers: {
        "Content-Type": _contentType,
      });

      if (kDebugMode) {
        print("📥 [GOOGLE API] Response status: ${response.statusCode}");
      }

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonBody = jsonDecode(response.body);
        if (kDebugMode) {
          print("📄 [GOOGLE API] Raw response: ${response.body}");
        }

        final List<dynamic> predictionsJson = jsonBody["predictions"] ?? [];

        final List<HerePlace> places = predictionsJson
            .map((e) => HerePlace.fromJson(e as Map<String, dynamic>))
            .toList();

        return places;
      } else {
        if (kDebugMode) {
          print(
              "❌ [GOOGLE API] Request failed with status: ${response.statusCode}");
          print("❌ [GOOGLE API] Response body: ${response.body}");
        }
        return [];
      }
    } catch (e, st) {
      if (kDebugMode) {
        print("💥 [GOOGLE API] Exception occurred: $e");
        print(st.toString());
      }
      return [];
    }
  }
}

class HerePlace {
  String? description;
  String? id;
  List<MatchedSubstrings>? matchedSubstrings;
  String placeId;
  String? reference;
  StructuredFormatting? structuredFormatting;
  List<Terms>? terms;
  List<String>? types;
  // String? lat;
  // String? lng;

  HerePlace({
    this.description,
    this.id,
    this.matchedSubstrings,
    required this.placeId,
    this.reference,
    this.structuredFormatting,
    this.terms,
    this.types,
    // this.lat,
    // this.lng,
  });

  factory HerePlace.fromJson(Map<String, dynamic> json) {
    return HerePlace(
      description: json['description'],
      id: json['id'],
      matchedSubstrings: json['matched_substrings'] != null
          ? (json['matched_substrings'] as List)
              .map((v) => MatchedSubstrings.fromJson(v))
              .toList()
          : null,
      placeId: json['place_id'],
      reference: json['reference'],
      structuredFormatting: json['structured_formatting'] != null
          ? StructuredFormatting.fromJson(json['structured_formatting'])
          : null,
      terms: json['terms'] != null
          ? (json['terms'] as List).map((v) => Terms.fromJson(v)).toList()
          : null,
      types: json['types'] != null ? List<String>.from(json['types']) : null,
      // lat: json['lat'],
      // lng: json['lng'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'id': id,
      'matched_substrings': matchedSubstrings?.map((e) => e.toJson()).toList(),
      'place_id': placeId,
      'reference': reference,
      'structured_formatting': structuredFormatting?.toJson(),
      'terms': terms?.map((e) => e.toJson()).toList(),
      'types': types,
      // 'lat': lat,
      // 'lng': lng,
    };
  }
}

class MatchedSubstrings {
  int? length;
  int? offset;

  MatchedSubstrings({this.length, this.offset});

  factory MatchedSubstrings.fromJson(Map<String, dynamic> json) {
    return MatchedSubstrings(
      length: json['length'],
      offset: json['offset'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'length': length,
      'offset': offset,
    };
  }
}

class StructuredFormatting {
  String? mainText;
  String? secondaryText;

  StructuredFormatting({this.mainText, this.secondaryText});

  factory StructuredFormatting.fromJson(Map<String, dynamic> json) {
    return StructuredFormatting(
      mainText: json['main_text'],
      secondaryText: json['secondary_text'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'main_text': mainText,
      'secondary_text': secondaryText,
    };
  }
}

class Terms {
  int? offset;
  String? value;

  Terms({this.offset, this.value});

  factory Terms.fromJson(Map<String, dynamic> json) {
    return Terms(
      offset: json['offset'],
      value: json['value'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'offset': offset,
      'value': value,
    };
  }
}
