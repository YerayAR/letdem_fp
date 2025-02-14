import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';
import 'package:letdem/services/api/endpoints.dart';
import 'package:letdem/services/api/models/endpoint.dart';
import 'package:letdem/services/api/models/error.dart';
import 'package:letdem/services/api/models/response.model.dart';
import 'package:letdem/services/api/sub/base.dart';
import 'package:letdem/services/toast/toast.dart';

class ApiService extends BaseApiService {
  static final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
    ),
  );

  static Future<ApiResponse> sendMultiPartRequest({
    required Endpoint endpoint,
    required Function(double v) onProgress,
  }) async {
    try {
      var uri = "${EndPoints.baseURL}${endpoint.url}";

      // Handle query parameters
      if (endpoint.queryParameter != null) {
        List<Map<String, dynamic>> queryParams =
            endpoint.queryParameter!.map((e) => e.toMap()).toList();

        uri = Uri.parse(uri)
            .replace(queryParameters: _flattenMapList(queryParams))
            .toString();
      }

      // Add headers
      Options options = Options(
        headers: await BaseApiService.getHeaders(
            endpoint.isProtected, endpoint.tokenKey),
      );

      // Create form data
      FormData formData = FormData();
      if (endpoint.dto != null) {
        log("Adding fields: \${endpoint.dto!.toMap()}");
        Map<String, dynamic> dtoMap = endpoint.dto!.toMap();
        dtoMap.forEach((key, value) {
          formData.fields.add(MapEntry(key, value.toString()));
        });
      }

      // Add images
      if (endpoint.images != null) {
        for (var image in endpoint.images!) {
          var file = image.file;
          if (await file.exists()) {
            var mimeType = 'application/octet-stream';
            formData.files.add(
              MapEntry(
                image.key,
                await MultipartFile.fromFile(
                  file.path,
                  contentType: MediaType.parse(mimeType),
                ),
              ),
            );
          } else {
            log("File not found: \${file.path}");
          }
        }
      } else {
        log("No images to upload.");
      }

      debugPrint("Sending ${endpoint.getHTTPMethod()} request to $uri");
      Response response = endpoint.method.name.toLowerCase() == "put"
          ? await _dio.put(
              uri,
              data: formData,
              options: options,
              onSendProgress: (int sent, int total) {
                double progress = (sent / total) * 100;
                onProgress(progress);
              },
            )
          : await _dio.post(
              uri,
              data: formData,
              options: options,
              onSendProgress: (int sent, int total) {
                double progress = (sent / total) * 100;
                onProgress(progress);
              },
            );

      debugPrint("Status code: ${response.statusCode}");
      debugPrint("Body: ${response.data}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResponse(
          success: true,
          status: RequestStatus.success,
          data:
              (response.data is List) ? {'data': response.data} : response.data,
        );
      }

      // Failed response
      String err =
          response.data['message'] ?? response.data['error'] ?? 'Unknown error';
      throw ApiError(message: err);
    } on DioException catch (e) {
      _handleDioError(e);
    } on TimeoutException {
      throw ApiError(message: 'The request has timed out');
    } catch (e, srt) {
      print(srt);
      debugPrint('Error occurred: \${e.runtimeType} - \${e.toString()}');
      if (e is ApiError) {
        rethrow;
      }
      throw ApiError(message: "Something went wrong");
    }
    throw ApiError(message: "Unexpected error occurred, no response received");
  }

  // Send an HTTP request and handle the response
  static Future<ApiResponse> sendRequest({
    required Endpoint endpoint,
  }) async {
    try {
      var url = "${EndPoints.baseURL}${endpoint.url}";

      endpoint.checkDTO();

      if (endpoint.queryParameter != null) {
        List<Map<String, dynamic>> queryParams =
            endpoint.queryParameter!.map((e) => e.toMap()).toList();

        url = Uri.parse(url)
            .replace(queryParameters: _flattenMapList(queryParams))
            .toString();
      }

      Options options = Options(
        headers: await BaseApiService.getHeaders(
            endpoint.isProtected, endpoint.tokenKey),
      );
      if (EndPoints.showApiLogs) {
        debugPrint("""
════════════════════════════════════════════════════════════════════════════════════════════════
      API REQUEST           🐶
════════════════════════════════════════════════════════════════════════════════════════════════
      URL       :- $url
      Data  :- ${endpoint.dto?.toMap()}


════════════════════════════════════════════════════════════════════════════════════════════════
""");
      }

      Response response;
      if (endpoint.method.name.toLowerCase() == 'get') {
        response = await _dio.get(url, options: options);
      } else {
        response = await _dio.request(
          url,
          data: endpoint.dto?.toMap(),
          options: options.copyWith(method: endpoint.getHTTPMethod()),
        );
      }

      if (EndPoints.showApiLogs) {
        debugPrint("""
════════════════════════════════════════════════════════════════════════════════════════════════
      API RESPONSE    🐶
════════════════════════════════════════════════════════════════════════════════════════════════
      URL       :- $url
      StatusCode:- ${response.statusCode}
      Response  :-

${response.data}

════════════════════════════════════════════════════════════════════════════════════════════════
""");
      }
      // Handle unauthenticated responses
      if (response.statusCode == 401) {
        if (endpoint == EndPoints.loginEndpoint) {
          throw ApiError(
            message: 'Invalid Credentials',
            status: ErrorStatus.unauthorized,
          );
        } else {
          // NavigatorHelper.replaceAll(const LoginScreen());
        }
      }

      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 204) {
        return ApiResponse(
          success: true,
          status: RequestStatus.success,
          data: response.data == null
              ? {}
              : (response.data is List)
                  ? {'data': response.data}
                  : response.data,
        );
      }

      String err = response.data['message'] ??
          response.data['error'] ??
          fromCode(response.statusCode ?? 0);

      throw ApiError(
        message: err,
        status: fromCode(response.statusCode ?? 0),
        data: (response.data is List) ? {'data': response.data} : response.data,
      );
    } on HandshakeException {
      throw ApiError(
        message: 'No internet connection',
        status: ErrorStatus.noInternet,
      );
    } on DioException catch (e) {
      _handleDioError(e);
    } on TimeoutException {
      throw ApiError(
          message: 'The request is timed out', status: ErrorStatus.timeout);
    } catch (e) {
      debugPrint('An error occurred: $e');
      if (e.runtimeType == ApiError) {
        rethrow;
      }
      throw ApiError(
          message: "Something went wrong", status: ErrorStatus.unauthorized);
    }
    throw ApiError(message: "Unexpected error occurred, no response received");
  }

  static void _handleDioError(DioException e) {
    print("-----------------");
    print(e.type);
    print("-----------------");

    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.badCertificate ||
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      Toast.showError("No internet connection");
      throw ApiError(
          message: "No internet connection", status: ErrorStatus.noInternet);
    }
    if (EndPoints.showApiLogs) {
      debugPrint("""
════════════════════════════════════════════════════════════════════════════════════════════════
      API RESPONSE    🐶
════════════════════════════════════════════════════════════════════════════════════════════════
      URL       :- ${e.response?.data ?? e.error}
      StatusCode:- ${e.message}
      Response  :-


════════════════════════════════════════════════════════════════════════════════════════════════
""");
    }
    debugPrint('Dio error occurred: ${e.message}');
    var message = e.response == null
        ? "Unknown error"
        : e.response!.data?['message'] ?? "Unknown error";

    throw ApiError(
        message: message, status: fromCode(e.response?.statusCode ?? 0));
  }
}

Map<String, dynamic> _flattenMapList(List<Map<String, dynamic>> list) {
  Map<String, dynamic> result = {};
  for (var map in list) {
    result.addAll(map);
  }
  return result;
}
