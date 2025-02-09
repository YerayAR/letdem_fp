import 'package:letdem/features/auth/dto/login.dto.dart';
import 'package:letdem/services/api/models/endpoint.dart';

enum Environment { STG, PROD, DEV }

class EndPoints {
  static String baseURL = "https://api-staging.letdem.org/v1";

  static bool showApiLogs = true;

  static Endpoint<LoginDTO> loginEndpoint = Endpoint(
    url: "/auth/login",
    method: HTTPMethod.POST,
    isProtected: false,
  );
}
