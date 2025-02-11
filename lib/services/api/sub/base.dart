import 'dart:async';

import 'package:flutter/material.dart';
import 'package:letdem/services/api/models/error.dart';
import 'package:letdem/services/res/navigator.dart';
import 'package:letdem/services/storage/storage.service.dart';

class BaseApiService {
  static Future<Map<String, String>> getHeaders(
      bool mustAuthenticated, String? tokenKey) async {
    Locale currentLocale = Localizations.localeOf(
        NavigatorHelper.navigatorKey.currentState!.context);
    Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept-Language': currentLocale.toString(), // e.g., "en_US"
    };

    if (mustAuthenticated) {
      try {
        // Retrieve the authentication token from secure storage
        SecureStorageHelper secureStorage = SecureStorageHelper();
        String? token = await secureStorage.read(tokenKey ?? 'access_token');
        if (token == null || token.isEmpty) {
          throw ApiError(
              message: 'Token not found', status: ErrorStatus.unauthorized);
        }
        print(token);

        headers['Authorization'] = 'Token $token';
      } catch (e) {
        rethrow;
      }
    }
    // print(headers);
    return headers;
  }
}
