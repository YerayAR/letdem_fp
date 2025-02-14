import 'package:letdem/features/auth/dto/email.dto.dart';
import 'package:letdem/features/auth/dto/login.dto.dart';
import 'package:letdem/features/auth/dto/register.dto.dart';
import 'package:letdem/features/auth/dto/verify_email.dto.dart';
import 'package:letdem/features/users/repository/user.repository.dart';
import 'package:letdem/services/api/models/endpoint.dart';

enum Environment { STG, PROD, DEV }

class EndPoints {
  static String baseURL =
      "http://letdemstagingalb-901145735.eu-central-1.elb.amazonaws.com/v1";

  static bool showApiLogs = true;

  static Endpoint<EditBasicInfoDTO> updateUserProfileEndpoint = Endpoint(
    url: "/users/me",
    method: HTTPMethod.PUT,
  );

  static Endpoint<LoginDTO> loginEndpoint = Endpoint(
    url: "/auth/login",
    method: HTTPMethod.POST,
    isProtected: false,
  );

  static Endpoint<RegisterDTO> registerEndpoint = Endpoint(
    url: "/auth/signup",
    method: HTTPMethod.POST,
    isProtected: false,
  );

  static Endpoint<VerifyEmailDTO> verifyEmailEndpoint = Endpoint(
    url: "/auth/account-verification/validate",
    method: HTTPMethod.POST,
    isProtected: false,
  );

  static Endpoint<EmailDTO> resendVerificationCodeEndpoint = Endpoint(
    url: "/auth/account-verification/resend-otp",
    method: HTTPMethod.POST,
    isProtected: false,
  );

  static Endpoint getUserProfileEndpoint = Endpoint(
    url: "/users/me",
    method: HTTPMethod.GET,
  );

  static Endpoint<EmailDTO> requestForgotPasswordEndpoint = Endpoint(
    url: "/auth/password-reset/request",
    method: HTTPMethod.POST,
    isProtected: false,
  );
  static Endpoint<VerifyEmailDTO> resetPasswordEndpoint = Endpoint(
    url: "/auth/password-reset/validate",
    method: HTTPMethod.POST,
    isProtected: false,
  );

  static Endpoint resendForgotPasswordVerificationCodeEndpoint = Endpoint(
    url: "/auth/password-reset/resend-otp",
    method: HTTPMethod.POST,
    isProtected: false,
  );
}
