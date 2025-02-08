import 'package:letdem/services/api/models/endpoint.dart';

class EndPoints {
  static String baseURL = "https://api.plestu.com/v1";
  static String v2BaseURL = "https://api.plestu.com/v1";

  static bool showApiLogs = true;

  static Endpoint loginEndpoint = Endpoint(
    url: "/auth/login",
    method: HTTPMethod.POST,
    baseURL: v2BaseURL,
    isProtected: false,
  );
}
