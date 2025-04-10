import 'dart:ui';

import 'package:letdem/features/auth/dto/password_reset.dto.dart';
import 'package:letdem/models/activities/activity.model.dart';
import 'package:letdem/services/api/api.service.dart';
import 'package:letdem/services/api/endpoints.dart';
import 'package:letdem/services/api/models/endpoint.dart';
import 'package:letdem/services/api/models/response.model.dart';
import 'package:letdem/views/app/profile/screens/preferences/preferences.view.dart';

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

class LetDemUser {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final bool isSocial;
  final int totalPoints;

  final int notificationsCount;

  final List<Activity> contributions;

  final UserPreferences preferences;

  final NotificationPreferences notificationPreferences;

  LetDemUser({
    required this.id,
    required this.email,
    required this.preferences,
    required this.notificationPreferences,
    required this.firstName,
    required this.lastName,
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
