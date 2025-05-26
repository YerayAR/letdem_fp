import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:letdem/core/constants/credentials.dart';
import 'package:letdem/core/extensions/location.dart';
import 'package:letdem/infrastructure/services/mapbox_search/models/model.dart';

class MapboxSearchApiService {
  static final MapboxSearchApiService _instance =
      MapboxSearchApiService._internal();

  factory MapboxSearchApiService() {
    return _instance;
  }

  MapboxSearchApiService._internal();

  static const String _baseUrl =
      "https://api.mapbox.com/search/searchbox/v1/suggest";
  static const String _contentType = "application/json";

  Future<List<MapBoxPlace>> getLocationResults(
      String query, BuildContext context) async {
    try {
      var country = await context.getUserCountry();

      final String url =
          "$_baseUrl?q=$query&access_token=${AppCredentials.mapBoxAccessToken}"
          "&session_token=${DateTime.now().millisecondsSinceEpoch}&country=${country?.toLowerCase()}&limit=10";

      final response = await http.get(Uri.parse(url), headers: {
        "Content-Type": _contentType,
        "Authorization": "Bearer ${AppCredentials.mapBoxAccessToken}",
      });

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return data["suggestions"] != null
            ? List<MapBoxPlace>.from(
                data["suggestions"].map((x) => MapBoxPlace.fromJson(x)))
            : [];
      } else {
        if (kDebugMode) {
          print("Error: ${response.statusCode} - ${response.body}");
        }
      }
    } catch (e, st) {
      if (kDebugMode) {
        print("Exception: $e");
        print("Stacktrace: $st");
      }
    }
    return [];
  }
}
