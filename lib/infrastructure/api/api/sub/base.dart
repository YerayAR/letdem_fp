import 'dart:async';

import 'package:flutter/material.dart';
import 'package:letdem/infrastructure/api/api/models/error.dart';
import 'package:letdem/infrastructure/services/res/navigator.dart';
import 'package:letdem/infrastructure/storage/storage/storage.service.dart';

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
        String? token = true
            ? "6f6a4848fe99f94929f04aa760aa29622538ba27"
            : await SecureStorageHelper().read(tokenKey ?? 'access_token');
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
    return headers;
  }
}
