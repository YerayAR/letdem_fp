import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:letdem/core/constants/credentials.dart';
import 'package:letdem/core/extensions/location.dart';

class HereSearchApiService {
  static final HereSearchApiService _instance =
      HereSearchApiService._internal();

  factory HereSearchApiService() {
    return _instance;
  }

  HereSearchApiService._internal();

  static const String _baseUrl =
      "https://autosuggest.search.hereapi.com/v1/autosuggest";
  static const String _contentType = "application/json";

  Future<List<HerePlace>> getLocationResults(
      String query, BuildContext context) async {
    if (kDebugMode) {
      print("🔍 [HERE API] Starting location search for query: '$query'");
    }

    try {
      var country = await context.getUserCountry();

      // Get user's current location for distance calculation

      var countryCodeRaw = country!['countryCode'];
      var lat = country['latitude'];
      var lng = country['longitude'];

      // If we have user's current location, use it instead of country center

      if (kDebugMode) {
        print("🌍 [HERE API] User country: ${country ?? 'null'}");
      }

      // Build the base URL with required parameters
      // Using 'at' parameter tells HERE to sort results by distance from this point
      String url =
          "$_baseUrl?q=${Uri.encodeQueryComponent(query)}&apiKey=${AppCredentials.hereApiKey}&limit=10&lang=en&at=$lat,$lng";

      // Add country filter if available
      if (countryCodeRaw != null) {
        final countryCode = _convertToISO3(countryCodeRaw.toUpperCase());
        url += "&in=countryCode:$countryCode";
      } else {
        // Use a radius search around user's location instead of global bbox
        url += "&in=circle:$lat,$lng;r=50000"; // 50km radius
      }

      if (kDebugMode) {
        final safeUrl =
            url.replaceAll(AppCredentials.hereApiKey, '[API_KEY_HIDDEN]');
        print("📡 [HERE API] Request URL: $safeUrl");
        print("📤 [HERE API] Making HTTP GET request...");
      }

      final response = await http.get(Uri.parse(url), headers: {
        "Content-Type": _contentType,
      });

      if (kDebugMode) {
        print("📥 [HERE API] Response status: ${response.statusCode}");
        print("📥 [HERE API] Response headers: ${response.headers}");
      }

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print("✅ [HERE API] Request successful");
          print(
              "📄 [HERE API] Response body length: ${response.body.length} characters");
          print("📄 [HERE API] Raw response: ${response.body}");
        }

        final Map<String, dynamic> data = jsonDecode(response.body);

        if (kDebugMode) {
          print("🔧 [HERE API] Parsed JSON keys: ${data.keys.toList()}");
          print("🔧 [HERE API] Items count: ${data["items"]?.length ?? 0}");
        }

        final List<HerePlace> places = data["items"] != null
            ? List<HerePlace>.from(
                data["items"].map((x) => HerePlace.fromJson(x)))
            : [];

        // HERE API automatically sorts by distance when using 'at' parameter
        // No manual sorting needed!

        if (kDebugMode) {
          print(
              "🏆 [HERE API] Successfully parsed ${places.length} places (sorted by distance)");
          for (int i = 0; i < places.length; i++) {
            print("   ${i + 1}. ${places[i].toString()}");
          }
        }

        return places;
      } else {
        if (kDebugMode) {
          print(
              "❌ [HERE API] Request failed with status: ${response.statusCode}");
          print("❌ [HERE API] Error response body: ${response.body}");
          print("❌ [HERE API] Error response headers: ${response.headers}");
        }
        return [];
      }
    } catch (e, st) {
      if (kDebugMode) {
        print("💥 [HERE API] Exception occurred: $e");
        print("💥 [HERE API] Exception type: ${e.runtimeType}");
        print("💥 [HERE API] Full stacktrace:");
        print(st.toString());
      }
      return [];
    }
  }

  // Get user's current location
  Future<Position?> _getCurrentLocation() async {
    try {
      bool serviceEnabled;
      LocationPermission permission;

      // Check if location services are enabled
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (kDebugMode) {
          print("⚠️ [LOCATION] Location services are disabled");
        }
        return null;
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (kDebugMode) {
            print("⚠️ [LOCATION] Location permissions are denied");
          }
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (kDebugMode) {
          print("⚠️ [LOCATION] Location permissions are permanently denied");
        }
        return null;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 10),
      );

      if (kDebugMode) {
        print(
            "📍 [LOCATION] Current position: ${position.latitude}, ${position.longitude}");
      }

      return position;
    } catch (e) {
      if (kDebugMode) {
        print("💥 [LOCATION] Error getting current location: $e");
      }
      return null;
    }
  }

  // Calculate distance between two coordinates using Haversine formula
  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // Earth's radius in kilometers

    double dLat = _degreesToRadians(lat2 - lat1);
    double dLon = _degreesToRadians(lon2 - lon1);

    double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degreesToRadians(lat1)) *
            math.cos(_degreesToRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    double distance = earthRadius * c;

    return distance;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (math.pi / 180);
  }

  String? _convertToISO3(String iso2Code) {
    final Map<String, String> iso2ToIso3 = {
      'AD': 'AND',
      'AE': 'ARE',
      'AF': 'AFG',
      'AG': 'ATG',
      'AI': 'AIA',
      'AL': 'ALB',
      'AM': 'ARM',
      'AO': 'AGO',
      'AQ': 'ATA',
      'AR': 'ARG',
      'AS': 'ASM',
      'AT': 'AUT',
      'AU': 'AUS',
      'AW': 'ABW',
      'AX': 'ALA',
      'AZ': 'AZE',
      'BA': 'BIH',
      'BB': 'BRB',
      'BD': 'BGD',
      'BE': 'BEL',
      'BF': 'BFA',
      'BG': 'BGR',
      'BH': 'BHR',
      'BI': 'BDI',
      'BJ': 'BEN',
      'BL': 'BLM',
      'BM': 'BMU',
      'BN': 'BRN',
      'BO': 'BOL',
      'BQ': 'BES',
      'BR': 'BRA',
      'BS': 'BHS',
      'BT': 'BTN',
      'BV': 'BVT',
      'BW': 'BWA',
      'BY': 'BLR',
      'BZ': 'BLZ',
      'CA': 'CAN',
      'CC': 'CCK',
      'CD': 'COD',
      'CF': 'CAF',
      'CG': 'COG',
      'CH': 'CHE',
      'CI': 'CIV',
      'CK': 'COK',
      'CL': 'CHL',
      'CM': 'CMR',
      'CN': 'CHN',
      'CO': 'COL',
      'CR': 'CRI',
      'CU': 'CUB',
      'CV': 'CPV',
      'CW': 'CUW',
      'CX': 'CXR',
      'CY': 'CYP',
      'CZ': 'CZE',
      'DE': 'DEU',
      'DJ': 'DJI',
      'DK': 'DNK',
      'DM': 'DMA',
      'DO': 'DOM',
      'DZ': 'DZA',
      'EC': 'ECU',
      'EE': 'EST',
      'EG': 'EGY',
      'EH': 'ESH',
      'ER': 'ERI',
      'ES': 'ESP',
      'ET': 'ETH',
      'FI': 'FIN',
      'FJ': 'FJI',
      'FK': 'FLK',
      'FM': 'FSM',
      'FO': 'FRO',
      'FR': 'FRA',
      'GA': 'GAB',
      'GB': 'GBR',
      'GD': 'GRD',
      'GE': 'GEO',
      'GF': 'GUF',
      'GG': 'GGY',
      'GH': 'GHA',
      'GI': 'GIB',
      'GL': 'GRL',
      'GM': 'GMB',
      'GN': 'GIN',
      'GP': 'GLP',
      'GQ': 'GNQ',
      'GR': 'GRC',
      'GS': 'SGS',
      'GT': 'GTM',
      'GU': 'GUM',
      'GW': 'GNB',
      'GY': 'GUY',
      'HK': 'HKG',
      'HM': 'HMD',
      'HN': 'HND',
      'HR': 'HRV',
      'HT': 'HTI',
      'HU': 'HUN',
      'ID': 'IDN',
      'IE': 'IRL',
      'IL': 'ISR',
      'IM': 'IMN',
      'IN': 'IND',
      'IO': 'IOT',
      'IQ': 'IRQ',
      'IR': 'IRN',
      'IS': 'ISL',
      'IT': 'ITA',
      'JE': 'JEY',
      'JM': 'JAM',
      'JO': 'JOR',
      'JP': 'JPN',
      'KE': 'KEN',
      'KG': 'KGZ',
      'KH': 'KHM',
      'KI': 'KIR',
      'KM': 'COM',
      'KN': 'KNA',
      'KP': 'PRK',
      'KR': 'KOR',
      'KW': 'KWT',
      'KY': 'CYM',
      'KZ': 'KAZ',
      'LA': 'LAO',
      'LB': 'LBN',
      'LC': 'LCA',
      'LI': 'LIE',
      'LK': 'LKA',
      'LR': 'LBR',
      'LS': 'LSO',
      'LT': 'LTU',
      'LU': 'LUX',
      'LV': 'LVA',
      'LY': 'LBY',
      'MA': 'MAR',
      'MC': 'MCO',
      'MD': 'MDA',
      'ME': 'MNE',
      'MF': 'MAF',
      'MG': 'MDG',
      'MH': 'MHL',
      'MK': 'MKD',
      'ML': 'MLI',
      'MM': 'MMR',
      'MN': 'MNG',
      'MO': 'MAC',
      'MP': 'MNP',
      'MQ': 'MTQ',
      'MR': 'MRT',
      'MS': 'MSR',
      'MT': 'MLT',
      'MU': 'MUS',
      'MV': 'MDV',
      'MW': 'MWI',
      'MX': 'MEX',
      'MY': 'MYS',
      'MZ': 'MOZ',
      'NA': 'NAM',
      'NC': 'NCL',
      'NE': 'NER',
      'NF': 'NFK',
      'NG': 'NGA',
      'NI': 'NIC',
      'NL': 'NLD',
      'NO': 'NOR',
      'NP': 'NPL',
      'NR': 'NRU',
      'NU': 'NIU',
      'NZ': 'NZL',
      'OM': 'OMN',
      'PA': 'PAN',
      'PE': 'PER',
      'PF': 'PYF',
      'PG': 'PNG',
      'PH': 'PHL',
      'PK': 'PAK',
      'PL': 'POL',
      'PM': 'SPM',
      'PN': 'PCN',
      'PR': 'PRI',
      'PS': 'PSE',
      'PT': 'PRT',
      'PW': 'PLW',
      'PY': 'PRY',
      'QA': 'QAT',
      'RE': 'REU',
      'RO': 'ROU',
      'RS': 'SRB',
      'RU': 'RUS',
      'RW': 'RWA',
      'SA': 'SAU',
      'SB': 'SLB',
      'SC': 'SYC',
      'SD': 'SDN',
      'SE': 'SWE',
      'SG': 'SGP',
      'SH': 'SHN',
      'SI': 'SVN',
      'SJ': 'SJM',
      'SK': 'SVK',
      'SL': 'SLE',
      'SM': 'SMR',
      'SN': 'SEN',
      'SO': 'SOM',
      'SR': 'SUR',
      'SS': 'SSD',
      'ST': 'STP',
      'SV': 'SLV',
      'SX': 'SXM',
      'SY': 'SYR',
      'SZ': 'SWZ',
      'TC': 'TCA',
      'TD': 'TCD',
      'TF': 'ATF',
      'TG': 'TGO',
      'TH': 'THA',
      'TJ': 'TJK',
      'TK': 'TKL',
      'TL': 'TLS',
      'TM': 'TKM',
      'TN': 'TUN',
      'TO': 'TON',
      'TR': 'TUR',
      'TT': 'TTO',
      'TV': 'TUV',
      'TW': 'TWN',
      'TZ': 'TZA',
      'UA': 'UKR',
      'UG': 'UGA',
      'UM': 'UMI',
      'US': 'USA',
      'UY': 'URY',
      'UZ': 'UZB',
      'VA': 'VAT',
      'VC': 'VCT',
      'VE': 'VEN',
      'VG': 'VGB',
      'VI': 'VIR',
      'VN': 'VNM',
      'VU': 'VUT',
      'WF': 'WLF',
      'WS': 'WSM',
      'YE': 'YEM',
      'YT': 'MYT',
      'ZA': 'ZAF',
      'ZM': 'ZMB',
      'ZW': 'ZWE',
    };

    return iso2ToIso3[iso2Code];
  }

  // Alternative method using Geocoding API with distance sorting
  Future<List<HerePlace>> getGeocodingResults(
      String query, BuildContext context) async {
    if (kDebugMode) {
      print(
          "🔍 [HERE GEOCODING] Starting geocoding search for query: '$query'");
    }

    try {
      var country = await context.getUserCountry();

      // Get user's current location for distance calculation
      Position? userPosition = await _getCurrentLocation();

      if (country == null || country.isEmpty) {
        if (kDebugMode) {
          print(
              "🌍 [HERE GEOCODING] No country context available, using global search");
        }
      }

      if (kDebugMode) {
        print("🌍 [HERE GEOCODING] User country: ${country ?? 'null'}");
      }

      final String url =
          "https://geocode.search.hereapi.com/v1/geocode?q=$query&apiKey=${AppCredentials.hereAccessKeySecret}"
          "&limit=10${country != null ? '&in=countryCode:${_convertToISO3(country['countryCode']!.toUpperCase())!.toUpperCase()}' : ''}"
          "${userPosition != null ? '&at=${userPosition.latitude},${userPosition.longitude}' : ''}"; // Add 'at' parameter for distance sorting

      if (kDebugMode) {
        final safeUrl = url.replaceAll(
            AppCredentials.hereAccessKeySecret, '[API_KEY_HIDDEN]');
        print("📡 [HERE GEOCODING] Request URL: $safeUrl");
        print("📤 [HERE GEOCODING] Making HTTP GET request...");
      }

      final response = await http.get(Uri.parse(url), headers: {
        "Content-Type": _contentType,
      });

      if (kDebugMode) {
        print("📥 [HERE GEOCODING] Response status: ${response.statusCode}");
        print("📥 [HERE GEOCODING] Response headers: ${response.headers}");
      }

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print("✅ [HERE GEOCODING] Request successful");
          print(
              "📄 [HERE GEOCODING] Response body length: ${response.body.length} characters");
          print("📄 [HERE GEOCODING] Raw response: ${response.body}");
        }

        final Map<String, dynamic> data = jsonDecode(response.body);

        if (kDebugMode) {
          print("🔧 [HERE GEOCODING] Parsed JSON keys: ${data.keys.toList()}");
          print(
              "🔧 [HERE GEOCODING] Items count: ${data["items"]?.length ?? 0}");
        }

        final List<HerePlace> places = data["items"] != null
            ? List<HerePlace>.from(
                data["items"].map((x) => HerePlace.fromJson(x)))
            : [];

        // HERE API automatically sorts by distance when using 'at' parameter
        // No manual sorting needed!

        if (kDebugMode) {
          print(
              "🏆 [HERE GEOCODING] Successfully parsed ${places.length} places (sorted by distance)");
          for (int i = 0; i < places.length; i++) {
            print("   ${i + 1}. ${places[i].toString()}");
          }
        }

        return places;
      } else {
        if (kDebugMode) {
          print(
              "❌ [HERE GEOCODING] Request failed with status: ${response.statusCode}");
          print("❌ [HERE GEOCODING] Error response body: ${response.body}");
          print(
              "❌ [HERE GEOCODING] Error response headers: ${response.headers}");

          if (response.statusCode == 401) {
            print("🔑 [HERE GEOCODING] Authentication error - check API key");
          } else if (response.statusCode == 403) {
            print("🚫 [HERE GEOCODING] Forbidden - check API permissions");
          } else if (response.statusCode == 429) {
            print("🚦 [HERE GEOCODING] Rate limit exceeded");
          } else if (response.statusCode >= 500) {
            print("🔧 [HERE GEOCODING] Server error - HERE API may be down");
          }
        }
        return [];
      }
    } catch (e, st) {
      if (kDebugMode) {
        print("💥 [HERE GEOCODING] Exception occurred: $e");
        print("💥 [HERE GEOCODING] Exception type: ${e.runtimeType}");
        print("💥 [HERE GEOCODING] Full stacktrace:");
        print(st.toString());

        if (e is FormatException) {
          print(
              "📝 [HERE GEOCODING] JSON parsing error - invalid response format");
        } else if (e is TimeoutException) {
          print("⏰ [HERE GEOCODING] Request timeout");
        } else if (e is SocketException) {
          print("🌐 [HERE GEOCODING] Network connection error");
        }
      }
      return [];
    }
  }
}

class HerePlace {
  final String id;
  final String title;
  final String? address;
  final double? latitude;
  final double? longitude;
  final String? category;
  final String? resultType;
  final HereAddress? addressDetails;

  HerePlace({
    required this.id,
    required this.title,
    this.address,
    this.latitude,
    this.longitude,
    this.category,
    this.resultType,
    this.addressDetails,
  });
  factory HerePlace.fromJson(Map<String, dynamic> json) {
    final address = json['address'];
    final categories = json['categories'];

    final position = json['position'];

    // log latitude and longitude if they are not null

    var latitude = position != null
        ? position['lat'] != null
            ? position['lat'].toDouble()
            : json['latitude']?.toDouble()
        : json['latitude']?.toDouble();
    var longitude = position != null
        ? position['lng'] != null
            ? position['lng'].toDouble()
            : json['longitude']?.toDouble()
        : json['longitude']?.toDouble();

    print("Latitude: $latitude, Longitude: $longitude");

    return HerePlace(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      address: address is String
          ? address
          : address != null && address['label'] != null
              ? address['label']
              : null,
      latitude: latitude,
      longitude: longitude,
      category:
          (categories != null && categories is List && categories.isNotEmpty)
              ? categories[0]['name']
              : null,
      resultType: json['resultType'],
      addressDetails: address is Map<String, dynamic>
          ? HereAddress.fromJson(address)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'category': category,
      'resultType': resultType,
      'addressDetails': addressDetails?.toJson(),
    };
  }
}

class HereAddress {
  final String? label;
  final String? countryCode;
  final String? countryName;
  final String? stateCode;
  final String? state;
  final String? county;
  final String? city;
  final String? district;
  final String? street;
  final String? houseNumber;
  final String? postalCode;

  HereAddress({
    this.label,
    this.countryCode,
    this.countryName,
    this.stateCode,
    this.state,
    this.county,
    this.city,
    this.district,
    this.street,
    this.houseNumber,
    this.postalCode,
  });

  factory HereAddress.fromJson(Map<String, dynamic> json) {
    return HereAddress(
      label: json['label'],
      countryCode: json['countryCode'],
      countryName: json['countryName'],
      stateCode: json['stateCode'],
      state: json['state'],
      county: json['county'],
      city: json['city'],
      district: json['district'],
      street: json['street'],
      houseNumber: json['houseNumber'],
      postalCode: json['postalCode'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'countryCode': countryCode,
      'countryName': countryName,
      'stateCode': stateCode,
      'state': state,
      'county': county,
      'city': city,
      'district': district,
      'street': street,
      'houseNumber': houseNumber,
      'postalCode': postalCode,
    };
  }
}
