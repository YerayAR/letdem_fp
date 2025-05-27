import 'package:letdem/infrastructure/api/api/models/endpoint.dart';

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
