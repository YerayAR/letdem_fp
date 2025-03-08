import 'package:flutter/material.dart';
import 'package:letdem/constants/ui/dimens.dart';
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
  bool isAvailableSpaces = true;
  bool isRadarAlerts = false;
  bool isCameraAlerts = false;
  bool isProhibitedZoneAlert = false;
  bool isSpeedLimitAlert = false;
  bool isFatigueAlert = false;
  bool isPoliceAlert = false;
  bool isAccidentAlert = false;

  List preferences = [
    {
      'key': 'available_spaces',
      'title': 'Available spaces',
      'value': true,
    },
    {
      'key': 'radar_alerts',
      'title': 'Radar alerts',
      'value': false,
    },
    {
      'key': 'camera_alerts',
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
  ];

  submit() {
    // Save preferences to the server
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StyledBody(
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
            child: Column(
              children: preferences.map((preference) {
                return SettingsRow(
                  showDivider:
                      preferences.indexOf(preference) != preferences.length - 1,
                  widget: ToggleSwitch(
                    value: preference['value'],
                    onChanged: (value) {
                      setState(() {
                        preference['value'] = value;
                      });
                    },
                  ),
                  text: preference['title'],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
