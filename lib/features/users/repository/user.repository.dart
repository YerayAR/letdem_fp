import 'dart:ui';

import 'package:letdem/features/auth/dto/password_reset.dto.dart';
import 'package:letdem/models/activities/activity.model.dart';
import 'package:letdem/services/api/api.service.dart';
import 'package:letdem/services/api/endpoints.dart';
import 'package:letdem/services/api/models/endpoint.dart';
import 'package:letdem/services/api/models/response.model.dart';
import 'package:letdem/views/app/profile/screens/preferences/preferences.view.dart';

enum EarningStatus {
  missingInfo,
  pending,
  rejected,
  blocked,
  accepted,
}

enum EarningStep {
  personalInfo,
  addressInfo,
  documentUpload,
  bankAccountInfo,
  submitted,
}

class UserRepository extends IUserRepository {
  @override
  Future<void> createUser() {
    // TODO: implement createUser
    throw UnimplementedError();
  }

  @override
  Future<void> deleteUser() {
    // TODO: implement deleteUser
    throw UnimplementedError();
  }

  @override
  Future<LetDemUser> getUser() async {
    ApiResponse response = await ApiService.sendRequest(
      endpoint: EndPoints.getUserProfileEndpoint,
    );

    return LetDemUser.fromJSON(response.data);
  }

  @override
  Future<void> updateUser(EditBasicInfoDTO dto) {
    return ApiService.sendRequest(
      endpoint: EndPoints.updateUserProfileEndpoint.copyWithDTO(dto),
    );
  }

  @override
  Future changePassword(String oldPassword, String newPassword) async {
    return ApiService.sendRequest(
      endpoint: EndPoints.changePassword.copyWithDTO(
        ChangePasswordDTO(
          oldPassword: oldPassword,
          newPassword: newPassword,
        ),
      ),
    );
  }

  @override
  deleteAccount() async {
    return ApiService.sendRequest(
      endpoint: EndPoints.deleteAccountEndpoint,
    );
  }

  @override
  Future updatePreferencesEndpoint(PreferencesDTO dto) {
    return ApiService.sendRequest(
      endpoint: EndPoints.updatePreferencesEndpoint.copyWithDTO(dto),
    );
  }

  @override
  Future updateNotificationPreferences(PreferencesDTO preferences) async {
    return ApiService.sendRequest(
      endpoint: EndPoints.updatePreferencesEndpoint.copyWithDTO(preferences),
    );
  }

  @override
  Future changeLanguage(Locale locale) async {
    return ApiService.sendRequest(
      endpoint: EndPoints.updateLanguageEndpoint,
    );
  }
}

abstract class IUserRepository {
  Future<void> changeLanguage(Locale locale);
  Future<void> createUser();
  Future<void> deleteUser();

  Future updatePreferencesEndpoint(PreferencesDTO dto);

  Future deleteAccount();

  Future updateNotificationPreferences(PreferencesDTO preferences);

  Future<LetDemUser> getUser();

  Future changePassword(String oldPassword, String newPassword);

  Future<void> updateUser(EditBasicInfoDTO dto);
}

class AddressInfo {
  // Replace with actual fields
  AddressInfo();

  factory AddressInfo.fromJson(Map<String, dynamic> json) {
    return AddressInfo(); // Implement properly once you know the fields
  }
}

class DocumentInfo {
  // Replace with actual fields
  DocumentInfo();

  factory DocumentInfo.fromJson(Map<String, dynamic> json) {
    return DocumentInfo(); // Implement properly once you know the fields
  }
}

class PayoutMethod {
  // Replace with actual fields
  PayoutMethod();

  factory PayoutMethod.fromJson(Map<String, dynamic> json) {
    return PayoutMethod(); // Implement properly once you know the fields
  }
}

class EarningAccount {
  final double balance;
  final double pendingBalance;
  final String currency;
  final String legalFirstName;
  final String legalLastName;
  final String phone;
  final String birthday;
  final EarningStatus status;
  final EarningStep step;
  final AddressInfo? address;
  final DocumentInfo? document;
  final List<PayoutMethod> payoutMethods;

  EarningAccount({
    required this.balance,
    required this.pendingBalance,
    required this.currency,
    required this.legalFirstName,
    required this.legalLastName,
    required this.phone,
    required this.birthday,
    required this.status,
    required this.step,
    this.address,
    this.document,
    required this.payoutMethods,
  });

  factory EarningAccount.fromJson(Map<String, dynamic> json) {
    return EarningAccount(
      balance: double.tryParse(json['balance'].toString()) ?? 0.0,
      pendingBalance:
          double.tryParse((json['pending_balance']).toString()) ?? 0.0,
      currency: json['currency'] ?? '',
      legalFirstName: json['legal_first_name'] ?? '',
      legalLastName: json['legal_last_name'] ?? '',
      phone: json['phone'] ?? '',
      birthday: json['birthday'] ?? '',
      status: parseEarningStatus(json['status'].toString().toLowerCase()),
      step: parseEarningStep(json['step'].toString().toLowerCase()),
      address: json['address'] != null
          ? AddressInfo.fromJson(json['address'])
          : null,
      document: json['document'] != null
          ? DocumentInfo.fromJson(json['document'])
          : null,
      payoutMethods: (json['payout_methods'] as List<dynamic>?)
              ?.map((e) => PayoutMethod.fromJson(e))
              .toList() ??
          [],
    );
  }
}

EarningStatus parseEarningStatus(String? value) {
  switch (value) {
    case 'missing_info':
      return EarningStatus.missingInfo;
    case 'pending':
      return EarningStatus.pending;
    case 'rejected':
      return EarningStatus.rejected;
    case 'blocked':
      return EarningStatus.blocked;
    case 'accepted':
      return EarningStatus.accepted;
    default:
      return EarningStatus.missingInfo;
  }
}

EarningStep parseEarningStep(String? value) {
  switch (value) {
    case 'personal_info':
      return EarningStep.personalInfo;
    case 'address_info':
      return EarningStep.addressInfo;
    case 'document_info':
      return EarningStep.documentUpload;
    case 'bank_account_info':
      return EarningStep.bankAccountInfo;
    case 'submitted':
      return EarningStep.submitted;
    default:
      return EarningStep.personalInfo;
  }
}

getStatusString(EarningStatus status) {
  switch (status) {
    case EarningStatus.missingInfo:
      return 'Missing Info';
    case EarningStatus.pending:
      return 'Pending';
    case EarningStatus.rejected:
      return 'Rejected';
    case EarningStatus.blocked:
      return 'Blocked';
    case EarningStatus.accepted:
      return 'Accepted';
  }
}

getStepString(EarningStep step) {
  switch (step) {
    case EarningStep.personalInfo:
      return 'Personal Info';
    case EarningStep.addressInfo:
      return 'Address Info';
    case EarningStep.documentUpload:
      return 'Document Upload';
    case EarningStep.bankAccountInfo:
      return 'Bank Account Info';
    case EarningStep.submitted:
      return 'Submitted';
  }
}

class LetDemUser {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final bool isSocial;
  final int totalPoints;

  final int notificationsCount;

  final List<Activity> contributions;

  EarningAccount? earningAccount;

  final UserPreferences preferences;

  final NotificationPreferences notificationPreferences;

  LetDemUser({
    required this.id,
    required this.email,
    required this.preferences,
    required this.notificationPreferences,
    required this.firstName,
    required this.lastName,
    this.earningAccount,
    required this.isSocial,
    required this.totalPoints,
    required this.notificationsCount,
    required this.contributions,
  });

  factory LetDemUser.fromJSON(Map<String, dynamic> json) {
    return LetDemUser(
      id: json['id'],
      notificationPreferences:
          NotificationPreferences.fromJSON(json['notifications_preferences']),
      email: json['email'] ?? '',
      firstName: json['first_name'] ?? '',
      earningAccount: json['earning_account'] != null
          ? EarningAccount.fromJson(json['earning_account'])
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

  void setEarningAccount(EarningAccount account) {
    earningAccount = account;
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
}

class EditBasicInfoDTO extends DTO {
  final String firstName;
  final String lastName;

  EditBasicInfoDTO({
    required this.firstName,
    required this.lastName,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'first_name': firstName,
      'last_name': lastName,
    };
  }
}

class PreferencesDTO extends DTO {
  final List<Map<String, bool>> preferences;
  final List<Map<String, bool>> notificationsPreferences;

  PreferencesDTO({
    required this.preferences,
    required this.notificationsPreferences,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'alerts': {
        for (var preference in preferences) ...{
          preference.keys.first: preference.values.first,
        }
      },
      'notifications': {
        for (var preference in notificationsPreferences) ...{
          preference.keys.first: preference.values.first,
        }
      },
    };
  }
}

class NotificationPreferences {
  final bool pushNotifications;
  final bool emailNotifications;

  NotificationPreferences({
    required this.pushNotifications,
    required this.emailNotifications,
  });

  factory NotificationPreferences.fromJSON(Map<String, dynamic> json) {
    return NotificationPreferences(
      pushNotifications: json['push'],
      emailNotifications: json['email'],
    );
  }

  toJSON() {
    return {
      'push': pushNotifications,
      'email': emailNotifications,
    };
  }

  bool getPreference(String preferenceKey) {
    return toJSON()[preferenceKey];
  }
}
