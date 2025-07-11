import 'package:equatable/equatable.dart';
import 'package:letdem/core/enums/PublishSpaceType.dart';
import 'package:letdem/features/activities/activities_state.dart';
import 'package:letdem/features/activities/models/activity.model.dart';
import 'package:letdem/features/users/models/preferences.model.dart';
import 'package:letdem/features/users/presentation/views/preferences/preferences.view.dart';
import 'package:letdem/models/earnings_account/earning_account.model.dart';
import 'package:letdem/models/payment/payment.model.dart';

class UserReservationPayments {
  // {
  // "price": "9.00",
  // "type": "DISABLED",
  // "status": "CANCELLED",
  // "street": "10451 North Portal Avenue",
  // "created": "2025-06-30T01:02:31.703580Z"
  // },
  final String price;
  final PublishSpaceType type;
  final String status;
  final String street;
  final DateTime created;

  const UserReservationPayments({
    required this.price,
    required this.type,
    required this.status,
    required this.street,
    required this.created,
  });

  factory UserReservationPayments.fromJson(Map<String, dynamic> json) {
    return UserReservationPayments(
      price: json['price'] ?? '',
      type: getEnumFromText(json['type'], "PaidSpace"),
      status: json['status'] ?? '',
      street: json['street'] ?? '',
      created: DateTime.parse(json['created']),
    );
  }
}

class ConstantsSettings {
  final WithdrawalAmount withdrawalAmount;
  final SpacePrice spacePrice;
  final SpaceTimeToWait spaceTimeToWait;
  final int metersToShowTooCloseModal;

  ConstantsSettings({
    required this.withdrawalAmount,
    required this.spacePrice,
    required this.spaceTimeToWait,
    required this.metersToShowTooCloseModal,
  });

  factory ConstantsSettings.fromJson(Map<String, dynamic> json) {
    return ConstantsSettings(
      withdrawalAmount: WithdrawalAmount.fromJson(json['withdrawal_amount']),
      spacePrice: SpacePrice.fromJson(json['space_price']),
      spaceTimeToWait: SpaceTimeToWait.fromJson(json['space_time_to_wait']),
      metersToShowTooCloseModal: json['meters_to_show_too_close_modal'],
    );
  }
}

class WithdrawalAmount {
  final double minimum;
  final double maximum;

  WithdrawalAmount({required this.minimum, required this.maximum});

  factory WithdrawalAmount.fromJson(Map<String, dynamic> json) {
    return WithdrawalAmount(
      minimum: double.parse(json['minimum'].toString()),
      maximum: double.parse(json['maximum'].toString()),
    );
  }
}

class SpacePrice {
  final int minimum;
  final int maximum;

  SpacePrice({required this.minimum, required this.maximum});

  factory SpacePrice.fromJson(Map<String, dynamic> json) {
    return SpacePrice(
      minimum: json['minimum'],
      maximum: json['maximum'],
    );
  }
}

class SpaceTimeToWait {
  final int minimum;
  final int maximum;

  SpaceTimeToWait({required this.minimum, required this.maximum});

  factory SpaceTimeToWait.fromJson(Map<String, dynamic> json) {
    return SpaceTimeToWait(
      minimum: json['minimum'],
      maximum: json['maximum'],
    );
  }
}

class LetDemUser extends Equatable {
  final String id;
  final String email;
  final String firstName;

  final ReservedSpacePayload? activeReservation;

  final ConstantsSettings constantsSettings;
  final String lastName;

  final PaymentMethodModel? defaultPaymentMethod;
  final bool isSocial;
  final int totalPoints;
  final int notificationsCount;
  final List<Activity> contributions;
  final EarningAccount? earningAccount;
  final UserPreferences preferences;
  final NotificationPreferences notificationPreferences;

  const LetDemUser({
    required this.id,
    required this.email,
    required this.preferences,
    required this.notificationPreferences,
    required this.firstName,
    required this.lastName,
    this.earningAccount,
    this.defaultPaymentMethod,
    required this.constantsSettings,
    this.activeReservation,
    required this.isSocial,
    required this.totalPoints,
    required this.notificationsCount,
    required this.contributions,
  });

  LetDemUser copyWith({
    EarningAccount? earningAccount,
  }) {
    return LetDemUser(
      id: id,
      email: email,
      preferences: preferences,
      notificationPreferences: notificationPreferences,
      firstName: firstName,
      lastName: lastName,
      earningAccount: earningAccount ?? this.earningAccount,
      constantsSettings: constantsSettings,
      isSocial: isSocial,
      totalPoints: totalPoints,
      defaultPaymentMethod: defaultPaymentMethod,
      activeReservation: activeReservation,
      notificationsCount: notificationsCount,
      contributions: contributions,
    );
  }

  factory LetDemUser.fromJSON(Map<String, dynamic> json) {
    return LetDemUser(
      id: json['id'],
      notificationPreferences:
          NotificationPreferences.fromJSON(json['notifications_preferences']),
      email: json['email'] ?? '',
      constantsSettings: ConstantsSettings.fromJson(json['constants_settings']),
      firstName: json['first_name'] ?? '',
      earningAccount: json['earning_account'] != null
          ? EarningAccount.fromJson(json['earning_account'])
          : null,
      defaultPaymentMethod: json['default_payment_method'] != null
          ? PaymentMethodModel.fromJson(json['default_payment_method'])
          : null,
      activeReservation: json['active_reservation'] != null
          ? ReservedSpacePayload.fromJson(json['active_reservation'])
          : null,
      preferences: UserPreferences(
        isProhibitedZoneAlert: json['alerts_preferences']
            ['prohibited_zone_alert'],
        isSpeedLimitAlert: json['alerts_preferences']['speed_limit_alert'],
        isFatigueAlert: json['alerts_preferences']['fatigue_alert'],
        isPoliceAlert: json['alerts_preferences']['police_alert'],
        isAvailableSpaces: json['alerts_preferences']['available_spaces'],
        isRadarAlerts: json['alerts_preferences']['radar_alert'],
        isCameraAlerts: json['alerts_preferences']['camera_alert'],
        isAccidentAlert: json['alerts_preferences']['accident_alert'],
        isRoadClosedAlert: json['alerts_preferences']['road_closed_alert'],
      ),
      lastName: json['last_name'] ?? '',
      isSocial: json['is_social'] ?? false,
      totalPoints: json['total_points'] ?? 0,
      contributions: (json['contributions'] as List)
          .map((e) => Activity.fromJson(e))
          .toList(),
      notificationsCount: json['notifications_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJSON() {
    return {
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'is_social': isSocial,
      'total_points': totalPoints,
      'notifications_count': notificationsCount,
    };
  }

  @override
  List<Object?> get props => [
        id,
        email,
        firstName,
        lastName,
        isSocial,
        totalPoints,
        notificationsCount,
        contributions,
        earningAccount,
        preferences,
        notificationPreferences,
      ];
}
