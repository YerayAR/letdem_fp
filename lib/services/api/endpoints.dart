import 'package:letdem/features/activities/repositories/activity.interface..dart';
import 'package:letdem/features/auth/dto/email.dto.dart';
import 'package:letdem/features/auth/dto/login.dto.dart';
import 'package:letdem/features/auth/dto/password_reset.dto.dart';
import 'package:letdem/features/auth/dto/register.dto.dart';
import 'package:letdem/features/auth/dto/verify_email.dto.dart';
import 'package:letdem/features/auth/repositories/auth.interface.dart';
import 'package:letdem/features/car/repository/car.repository.dart';
import 'package:letdem/features/search/dto/post_location.dto.dart';
import 'package:letdem/features/users/repository/user.repository.dart';
import 'package:letdem/services/api/models/endpoint.dart';

enum Environment { STG, PROD, DEV }

class EndPoints {
  static String baseURL = "https://api-staging.letdem.org/v1";

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

  static Endpoint<ResetPasswordDTO> resetForgotPasswordEndpoint = Endpoint(
    url: "/auth/password-reset",
    method: HTTPMethod.POST,
    isProtected: false,
  );

  static Endpoint resendForgotPasswordVerificationCodeEndpoint = Endpoint(
    url: "/auth/password-reset/resend-otp",
    method: HTTPMethod.POST,
    isProtected: false,
  );

  static Endpoint locationListEndpoint = Endpoint(
    url: "/users/me/addresses",
    method: HTTPMethod.GET,
  );
  static Endpoint<PostLetDemoLocationDTO> addWorkLocation = Endpoint(
    url: "/users/me/addresses/work",
    method: HTTPMethod.POST,
  );

  static Endpoint<PublishSpaceDTO> publishSpace = Endpoint(
    url: "/spaces/free",
    method: HTTPMethod.POST,
  );

  static Endpoint<PostLetDemoLocationDTO> addHomeLocation = Endpoint(
    url: "/users/me/addresses/home",
    method: HTTPMethod.POST,
  );

  static Endpoint deleteWorkLocation = Endpoint(
    url: "/users/me/addresses/work",
    method: HTTPMethod.DELETE,
  );

  static Endpoint deleteHomeLocation = Endpoint(
    url: "/users/me/addresses/home",
    method: HTTPMethod.DELETE,
  );
  // /v1/users/me/contributions?page_size=15&page=1
  static Endpoint getContributions = Endpoint(
    url: "/users/me/contributions?page_size=5&page=1",
    method: HTTPMethod.GET,
  );

  static Endpoint<PublishRoadEventDTO> publishRoadEvent = Endpoint(
    url: "/events",
    method: HTTPMethod.POST,
  );

  static Endpoint<TokenDTO> socialLogin = Endpoint(
    url: "/auth/social-login",
    method: HTTPMethod.POST,
    isProtected: false,
  );
  static Endpoint<TokenDTO> socialSignup = Endpoint(
    url: "/auth/social-signup",
    method: HTTPMethod.POST,
    isProtected: false,
  );
  static Endpoint getCar = Endpoint(
    url: "/users/me/car",
    method: HTTPMethod.GET,
  );

  static Endpoint<CreateCartDTO> registerCar = Endpoint(
    url: "/users/me/car",
    method: HTTPMethod.POST,
  );
  static Endpoint<CreateCartDTO> updateCar = Endpoint(
    url: "/users/me/car",
    method: HTTPMethod.PUT,
  );
  static Endpoint getNearby = Endpoint(
    url: "/maps/nearby",
    method: HTTPMethod.GET,
  );
}
