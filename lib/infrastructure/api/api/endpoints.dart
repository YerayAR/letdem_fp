import 'package:letdem/features/activities/dto/event_feedback.dto.dart';
import 'package:letdem/features/activities/dto/publish_event.dto.dart';
import 'package:letdem/features/activities/dto/publish_space.dto.dart';
import 'package:letdem/features/activities/dto/reserve_space.dto.dart';
import 'package:letdem/features/activities/dto/take_space.dto.dart';
import 'package:letdem/features/auth/dto/email.dto.dart';
import 'package:letdem/features/auth/dto/login.dto.dart';
import 'package:letdem/features/auth/dto/password_reset.dto.dart';
import 'package:letdem/features/auth/dto/register.dto.dart';
import 'package:letdem/features/auth/dto/token.dto.dart';
import 'package:letdem/features/auth/dto/verify_email.dto.dart';
import 'package:letdem/features/car/dto/create_car.dto.dart';
import 'package:letdem/features/earning_account/dto/earning_account.dto.dart';
import 'package:letdem/features/payout_methods/repository/payout.repository.dart';
import 'package:letdem/features/scheduled_notifications/repository/schedule_notifications.repository.dart';
import 'package:letdem/features/search/dto/post_location.dto.dart';
import 'package:letdem/features/users/dto/edit_basic_info.dto.dart';
import 'package:letdem/features/withdrawals/dto/withdraw.dto.dart';
import 'package:letdem/features/wallet/dto/transfers.dto.dart';
import 'package:letdem/infrastructure/api/api/models/endpoint.dart';

import '../../../features/activities/dto/extend_time_space.dto.dart';
import '../../../features/users/repository/user.repository.dart';

enum Environment { STG, PROD, DEV }

class EndPoints {
  /// Base URL de la API principal.
  ///
  /// - En desarrollo: pasa, por ejemplo, `--dart-define=API_BASE_URL=http://10.0.2.2:8000/v1`.
  /// - En staging: `--dart-define=API_BASE_URL=https://api-staging.letdem.org/v1`.
  /// - En producción: `--dart-define=API_BASE_URL=https://api.letdem.com/v1`.
  ///
  /// Si no se define, por defecto apunta a `https://api-staging.letdem.org/v1`.
  static const String baseURL = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api-staging.letdem.org/v1',
  );

  // Auth Base URL (Staging)
  static const String authBaseURL = 'https://api-staging.letdem.org/v1';

  static bool showApiLogs = true;
  static Endpoint<DeviceIdDTO> updateDeviceIdEndpoint = Endpoint(
    url: "/users/me/update-device-id",
    method: HTTPMethod.PUT,
  );

  // v1/spaces/1d75c325fab445edb60a9eebef996b0f
  static Endpoint getSpaceDetails(String id) =>
      Endpoint(url: "/spaces/$id", method: HTTPMethod.GET);

  static Endpoint<EditBasicInfoDTO> updateUserProfileEndpoint = Endpoint(
    url: "/users/me",
    method: HTTPMethod.PUT,
  );

  // resendVerificationCodeForgotPasswordEndpoint
  static Endpoint<EmailDTO> resendVerificationCodeForgotPasswordEndpoint =
      Endpoint(
        url: "/auth/password-reset/resend-otp",
        method: HTTPMethod.POST,
        isProtected: false,
        baseURL: authBaseURL,
      );

  // getReservationHistoryEndpoint
  static Endpoint getReservationHistoryEndpoint = Endpoint(
    url: "/credits/reservations",
    method: HTTPMethod.GET,
  );

  // delete space
  static Endpoint deleteSpace(String id) =>
      Endpoint(url: "/spaces/$id", method: HTTPMethod.DELETE);

  static Endpoint getOrdersEndpoint = Endpoint(
    url: "/credits/orders?page_size=100&page=1",
    method: HTTPMethod.GET,
  );

  static Endpoint<ReserveSpaceDTO> reserveSpace(String id) =>
      Endpoint(url: "/spaces/$id/reserve", method: HTTPMethod.POST);

  static Endpoint getWithdrawals = Endpoint(
    url: "/credits/withdrawals",
    method: HTTPMethod.GET,
  );

  /// Transferencias de dinero entre usuarios.
  static Endpoint<MoneyTransferDTO> sendMoneyTransfer = Endpoint(
    url: "/credits/transfers/money",
    method: HTTPMethod.POST,
  );

  /// Transferencias de puntos entre usuarios.
  static Endpoint<PointsTransferDTO> sendPointsTransfer = Endpoint(
    url: "/credits/transfers/points",
    method: HTTPMethod.POST,
  );

  static Endpoint<LoginDTO> loginEndpoint = Endpoint(
    url: "/auth/login",
    method: HTTPMethod.POST,
    isProtected: false,
    baseURL: authBaseURL,
  );
  static Endpoint getPayoutMethods = Endpoint(
    url: "/credits/payout-methods",
    method: HTTPMethod.GET,
    isProtected: true,
  );

  static Endpoint<WithdrawMoneyDTO> withdrawMoney = Endpoint(
    url: "/credits/withdrawals",
    method: HTTPMethod.POST,
    isProtected: true,
  );

  static Endpoint<PayoutMethodDTO> addPayoutMethod = Endpoint(
    url: "/credits/payout-methods",
    method: HTTPMethod.POST,
    isProtected: true,
  );

  static Endpoint<ConfirmationCodeDTO> confirmReservation(String id) =>
      Endpoint(url: "/reservations/$id/confirm", method: HTTPMethod.POST);

  static Endpoint<ExtendTimeSpaceDTO> extendTimeSpace(String id) =>
      Endpoint(url: "spaces/$id/extend-expiration", method: HTTPMethod.PUT);

  static Endpoint deletePayoutMethod(String id) =>
      Endpoint(url: "/credits/payout-methods/$id", method: HTTPMethod.DELETE);

  static Endpoint<RegisterDTO> registerEndpoint = Endpoint(
    url: "/auth/signup",
    method: HTTPMethod.POST,
    isProtected: false,
    baseURL: authBaseURL,
  );

  static Endpoint<VerifyEmailDTO> verifyEmailEndpoint = Endpoint(
    url: "/auth/account-verification/validate",
    method: HTTPMethod.POST,
    isProtected: false,
    baseURL: authBaseURL,
  );

  static Endpoint<EmailDTO> resendVerificationCodeEndpoint = Endpoint(
    url: "/auth/account-verification/resend-otp",
    method: HTTPMethod.POST,
    isProtected: false,
    baseURL: authBaseURL,
  );

  static Endpoint getUserProfileEndpoint = Endpoint(
    url: "/users/me",
    method: HTTPMethod.GET,
  );

  static Endpoint<EmailDTO> requestForgotPasswordEndpoint = Endpoint(
    url: "/auth/password-reset/request",
    method: HTTPMethod.POST,
    isProtected: false,
    baseURL: authBaseURL,
  );
  static Endpoint<VerifyEmailDTO> resetPasswordEndpoint = Endpoint(
    url: "/auth/password-reset/validate",
    method: HTTPMethod.POST,
    isProtected: false,
    baseURL: authBaseURL,
  );

  static Endpoint<ResetPasswordDTO> resetForgotPasswordEndpoint = Endpoint(
    url: "/auth/password-reset",
    method: HTTPMethod.POST,
    isProtected: false,
    baseURL: authBaseURL,
  );

  static Endpoint resendForgotPasswordVerificationCodeEndpoint = Endpoint(
    url: "/auth/password-reset/resend-otp",
    method: HTTPMethod.POST,
    isProtected: false,
    baseURL: authBaseURL,
  );

  static Endpoint locationListEndpoint = Endpoint(
    url: "/users/me/addresses",
    method: HTTPMethod.GET,
  );
  static Endpoint<PostLetDemoLocationDTO> addWorkLocation = Endpoint(
    url: "/users/me/addresses/work",
    method: HTTPMethod.POST,
  );

  static Endpoint<PublishSpaceDTO> publishSpaceFree = Endpoint(
    url: "/spaces/free",
    method: HTTPMethod.POST,
  );
  static Endpoint<PublishSpaceDTO> publishSpacePaid = Endpoint(
    url: "/spaces/paid",
    method: HTTPMethod.POST,
  );

  static Endpoint takeSpace(String id) => Endpoint<TakeSpaceDTO>(
    url: "/spaces/$id/feedback",
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

  static Endpoint cancelReservation(String id) => Endpoint(
    url: "/reservations/$id/cancel",
    method: HTTPMethod.POST,
    dtoNullable: true,
  );
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
    baseURL: authBaseURL,
  );
  static Endpoint<TokenDTO> socialSignup = Endpoint(
    url: "/auth/social-signup",
    method: HTTPMethod.POST,
    isProtected: false,
    baseURL: authBaseURL,
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

  static Endpoint<ChangePasswordDTO> changePassword = Endpoint(
    url: "/users/me/change-password",
    method: HTTPMethod.PUT,
    isProtected: true,
  );

  static Endpoint deleteAccountEndpoint = Endpoint(
    url: "/users/me/delete-account",
    method: HTTPMethod.DELETE,
    isProtected: true,
  );

  static Endpoint<PreferencesDTO> updatePreferencesEndpoint = Endpoint(
    url: "/users/me/preferences",
    method: HTTPMethod.PUT,
  );

  static Endpoint updateLanguageEndpoint = Endpoint(
    url: "/users/me/language",
    method: HTTPMethod.PUT,
  );

  static Endpoint getScheduleNotification = Endpoint(
    url: "/users/me/scheduled-notifications?page_size=3&page=1",
    method: HTTPMethod.GET,
  );

  static Endpoint<CreateScheduledNotificationDTO> createScheduleNotification =
      Endpoint(
        url: "/users/me/scheduled-notifications",
        method: HTTPMethod.POST,
      );

  static Endpoint deleteScheduleNotification(String id) {
    return Endpoint(
      url: "/users/me/scheduled-notifications/$id",
      method: HTTPMethod.DELETE,
    );
  }

  static Endpoint<CreateScheduledNotificationDTO> updateScheduleNotification(
    String id,
  ) {
    return Endpoint(
      url: "/users/me/scheduled-notifications/$id",
      method: HTTPMethod.PUT,
    );
  }

  static Endpoint getRoute = Endpoint(
    url: "/maps/routes",
    method: HTTPMethod.GET,
  );

  static var notifications = Endpoint(
    url: "/users/me/notifications",
    method: HTTPMethod.GET,
  );

  static var clearNotifications = Endpoint(
    url: "/users/me/notifications",
    method: HTTPMethod.DELETE,
  );

  static readNotification(String id) {
    return Endpoint(
      url: "users/me/notifications/$id/read",
      method: HTTPMethod.PUT,
    );
  }

  static Endpoint<EarningsAccountDTO> submitEarningsAccount = Endpoint(
    url: "/credits/earnings/account",
    method: HTTPMethod.POST,
  );
  static Endpoint<EarningsAddressDTO> submitEarningsAddress = Endpoint(
    url: "/credits/earnings/address",
    method: HTTPMethod.POST,
  );
  static Endpoint<EarningsDocumentDTO> submitEarningsDocument = Endpoint(
    url: "/credits/earnings/document",
    method: HTTPMethod.POST,
  );
  static Endpoint<EarningsBankAccountDTO> submitBankAccount = Endpoint(
    url: "/credits/earnings/bank-account",
    method: HTTPMethod.POST,
  );
  static markNotificationAsRead(String id) {
    return Endpoint(
      url: "/users/me/notifications/$id/read",
      method: HTTPMethod.PUT,
    );
  }

  static Endpoint addPaymentMethod = Endpoint(
    url: '/credits/payment-methods',
    method: HTTPMethod.POST,
  );

  static Endpoint getPaymentMethods = Endpoint(
    url: '/credits/payment-methods',
    method: HTTPMethod.GET,
  );

  static Endpoint removePaymentMethod(String id) {
    return Endpoint(
      url: '/credits/payment-methods/$id',
      method: HTTPMethod.DELETE,
    );
  }

  static Endpoint setDefaultPaymentMethod(String id) {
    return Endpoint(
      url: '/credits/payment-methods/$id/mark-as-default',
      method: HTTPMethod.PUT,
    );
  }

  static Endpoint getTransactions = Endpoint(
    url: '/credits/transactions',
    method: HTTPMethod.GET,
  );
  static Endpoint<EventFeedBackDTO> eventFeedBack(String id) =>
      Endpoint(url: "/events/$id/feedback", method: HTTPMethod.POST);
}
