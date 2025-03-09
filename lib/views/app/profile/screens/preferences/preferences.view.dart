import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:letdem/constants/ui/dimens.dart';
import 'package:letdem/extenstions/user.dart';
import 'package:letdem/features/users/user_bloc.dart';
import 'package:letdem/global/widgets/appbar.dart';
import 'package:letdem/global/widgets/body.dart';
import 'package:letdem/services/res/navigator.dart';
import 'package:letdem/views/app/profile/widgets/settings_container.widget.dart';
import 'package:letdem/views/app/profile/widgets/settings_row.widget.dart';

class PreferencesView extends StatefulWidget {
  const PreferencesView({super.key});

  @override
  State<PreferencesView> createState() => _PreferencesViewState();
}

class _PreferencesViewState extends State<PreferencesView> {
  List<Map<String, dynamic>> preferences = [
    {
      'key': 'available_spaces',
      'title': 'Available spaces',
      'value': true,
    },
    {
      'key': 'radar_alert',
      'title': 'Radar alerts',
      'value': false,
    },
    {
      'key': 'camera_alert',
      'title': 'Camera alerts',
      'value': false,
    },
    {
      'key': 'prohibited_zone_alert',
      'title': 'Prohibited zone alert',
      'value': false,
    },
    {
      'key': 'speed_limit_alert',
      'title': 'Speed limit alert',
      'value': false,
    },
    {
      'key': 'fatigue_alert',
      'title': 'Fatigue alert',
      'value': false,
    },
    {
      'key': 'police_alert',
      'title': 'Police alert',
      'value': false,
    },
    {
      'key': 'accident_alert',
      'title': 'Accident alert',
      'value': false,
    },
    {
      'key': 'road_closed_alert',
      'title': 'Road closed alert',
      'value': false,
    }
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final preferences = context.userProfile?.preferences;
      if (preferences != null) {
        setState(() {
          this.preferences = this.preferences.map((preference) {
            final value = preferences.getPreference(preference['key']) ?? false;
            return {
              ...preference,
              'value': value,
            };
          }).toList();
        });
      }
    });
  }

  submit() {
    context.read<UserBloc>().add(UpdatePreferencesEvent(
            preferences: preferences.map((preference) {
          return {
            preference['key'].toString(): preference['value'] as bool,
          };
        }).toList()));
    // Save preferences to the server
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          StyledBody(
            children: [
              StyledAppBar(
                title: 'Preferences',
                onTap: () {
                  NavigatorHelper.pop();
                },
                icon: Icons.close,
              ),
              Dimens.space(3),
              SettingsContainer(
                title: 'Notifications',
                child: Column(children: [
                  SettingsRow(
                    widget: ToggleSwitch(
                      value: true,
                      onChanged: (value) {},
                    ),
                    text: 'Alerts',
                  ),
                  SettingsRow(
                    showDivider: false,
                    widget: ToggleSwitch(
                      value: true,
                      onChanged: (value) {},
                    ),
                    text: 'Push Notifications',
                  ),
                ]),
              ),
              Dimens.space(5),
              SettingsContainer(
                title: 'Alerts',
                child: Column(
                  children: preferences.map((preference) {
                    return SettingsRow(
                      showDivider: preferences.indexOf(preference) !=
                          preferences.length - 1,
                      widget: ToggleSwitch(
                        value: preference['value'],
                        onChanged: (value) {
                          setState(() {
                            preference['value'] = value;
                          });
                          submit();
                        },
                      ),
                      text: preference['title'],
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class UserPreferences {
  final bool isProhibitedZoneAlert;
  final bool isAvailableSpaces;
  final bool isRadarAlerts;
  final bool isCameraAlerts;
  final bool isSpeedLimitAlert;
  final bool isFatigueAlert;
  final bool isPoliceAlert;
  final bool isAccidentAlert;
  final bool isRoadClosedAlert;

  UserPreferences({
    required this.isProhibitedZoneAlert,
    required this.isSpeedLimitAlert,
    required this.isFatigueAlert,
    required this.isAvailableSpaces,
    required this.isRadarAlerts,
    required this.isCameraAlerts,
    required this.isPoliceAlert,
    required this.isAccidentAlert,
    required this.isRoadClosedAlert,
  });

  Map<String, bool> toMap() {
    return {
      'available_spaces': isAvailableSpaces,
      'radar_alert': isRadarAlerts,
      'camera_alert': isCameraAlerts,
      'prohibited_zone_alert': isProhibitedZoneAlert,
      'speed_limit_alert': isSpeedLimitAlert,
      'fatigue_alert': isFatigueAlert,
      'police_alert': isPoliceAlert,
      'accident_alert': isAccidentAlert,
      'road_closed_alert': isRoadClosedAlert,
    };
  }

  bool getPreference(String preferenceKey) {
    return toMap()[preferenceKey] ?? false;
  }
}
