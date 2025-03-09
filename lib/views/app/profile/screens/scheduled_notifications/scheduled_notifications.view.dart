import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:iconly/iconly.dart';
import 'package:iconsax/iconsax.dart';
import 'package:letdem/constants/ui/colors.dart';
import 'package:letdem/constants/ui/dimens.dart';
import 'package:letdem/constants/ui/typo.dart';
import 'package:letdem/features/scheduled_notifications/schedule_notifications_bloc.dart';
import 'package:letdem/global/popups/popup.dart';
import 'package:letdem/global/widgets/appbar.dart';
import 'package:letdem/global/widgets/body.dart';
import 'package:letdem/global/widgets/button.dart';
import 'package:letdem/global/widgets/chip.dart';
import 'package:letdem/services/res/navigator.dart';
import 'package:letdem/views/app/notifications/views/notification.view.dart';
import 'package:letdem/views/app/profile/widgets/settings_container.widget.dart';

class ScheduledNotificationsView extends StatefulWidget {
  const ScheduledNotificationsView({super.key});

  @override
  State<ScheduledNotificationsView> createState() =>
      _ScheduledNotificationsViewState();
}

class _ScheduledNotificationsViewState
    extends State<ScheduledNotificationsView> {
  @override
  void initState() {
    context
        .read<ScheduleNotificationsBloc>()
        .add(FetchScheduledNotificationsEvent());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StyledBody(children: [
        StyledAppBar(
          onTap: () {
            NavigatorHelper.pop();
          },
          title: 'Scheduled Notifications',
          icon: Icons.close,
        ),
        Dimens.space(3),
        BlocConsumer<ScheduleNotificationsBloc, ScheduleNotificationsState>(
          listener: (context, state) {
            // TODO: implement listener
          },
          builder: (context, state) {
            if (state is ScheduleNotificationsError) {
              return const EmptyNotificationView();
            }

            if (state is ScheduleNotificationsLoading) {
              return const Expanded(
                child: Center(
                  child: CupertinoActivityIndicator(),
                ),
              );
            }
            if (state is ScheduleNotificationsLoaded) {
              return Expanded(
                child: ListView(
                  children: state.scheduledNotifications
                      .map((e) => ScheduleNotificationItem(
                            notification: e,
                          ))
                      .toList(),
                ),
              );
            }
            return SizedBox();
          },
        )
      ]),
    );
  }
}

class ScheduleNotificationItem extends StatelessWidget {
  final ScheduledNotification notification;
  const ScheduleNotificationItem({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar and icon stack
          Stack(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.neutral50,
                child: Icon(
                  IconlyBold.time_circle,
                  color: AppColors.neutral300,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: CircleAvatar(
                  radius: 9,
                  backgroundColor: Colors.white,
                  child: CircleAvatar(
                    radius: 8,
                    backgroundColor: AppColors.primary400,
                    child: const Icon(
                      IconlyBold.location,
                      color: Colors.white,
                      size: 10,
                    ),
                  ),
                ),
              ),
            ],
          ),

          Dimens.space(2), // Add horizontal spacing

          // Text content column - with Expanded to prevent overflow
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Space Reminder",
                      style:
                          Typo.largeBody.copyWith(fontWeight: FontWeight.bold),
                    ),
                    GestureDetector(
                      onTap: () {
                        AppPopup.showBottomSheet(
                          context,
                          Column(
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.all(14.0),
                                child: Row(
                                  children: [
                                    Text(
                                      'Space Reminder',
                                      style: Typo.heading1.copyWith(
                                        fontSize: 20,
                                      ),
                                    ),
                                    Spacer(),
                                    GestureDetector(
                                      onTap: () {
                                        NavigatorHelper.pop();
                                      },
                                      child: Icon(
                                        CupertinoIcons.clear,
                                        color: AppColors.neutral300,
                                        size: 20,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Dimens.space(1),
                              ListTile(
                                title: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 16,
                                      backgroundColor: AppColors.primary50,
                                      child: Icon(
                                        Iconsax.clock,
                                        color: AppColors.primary500,
                                        size: 14,
                                      ),
                                    ),
                                    Dimens.space(2),
                                    Text(
                                      'Reschedule Reminder',
                                      style: Typo.mediumBody.copyWith(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                                onTap: () {
                                  AppPopup.showBottomSheet(
                                    context,
                                    RescheduleNotificationCard(
                                      notification: notification,
                                    ),
                                  );
                                },
                              ),
                              Dimens.space(.5),
                              Divider(
                                color: AppColors.neutral50,
                              ),
                              Dimens.space(.5),
                              ListTile(
                                title: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 16,
                                      backgroundColor: AppColors.red50,
                                      child: Icon(
                                        Iconsax.trash,
                                        color: AppColors.red500,
                                        size: 14,
                                      ),
                                    ),
                                    Dimens.space(2),
                                    Text(
                                      'Delete Reminder',
                                      style: Typo.mediumBody.copyWith(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                                onTap: () {
                                  context.read<ScheduleNotificationsBloc>().add(
                                      DeleteScheduledNotificationEvent(
                                          notification.id));
                                  NavigatorHelper.pop();
                                },
                              ),
                              Dimens.space(2),
                            ],
                          ),
                        );
                      },
                      child: Icon(
                        CupertinoIcons.ellipsis,
                        color: AppColors.neutral300,
                        size: 17,
                      ),
                    ),
                  ],
                ),

                Dimens.space(1), // More vertical spacing
                // Rich text with bolded location
                RichText(
                  text: TextSpan(
                    style: Typo.mediumBody.copyWith(
                      color: AppColors.neutral500,
                    ),
                    children: [
                      TextSpan(text: "You have a reminder for a space at "),
                      TextSpan(
                        text: notification.location.streetName,
                        style: Typo.mediumBody.copyWith(
                          color: AppColors.neutral500,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 8), // More vertical spacing

                // Time text
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'From ${notification.startsAt.hour}:${notification.startsAt.minute} to ${notification.endsAt.hour}:${notification.endsAt.minute}',
                      style: Typo.mediumBody.copyWith(
                        color: AppColors.neutral500,
                      ),
                    ),
                    DecoratedChip(
                      text: 'Active',
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 6,
                      ),
                      textStyle: Typo.smallBody.copyWith(
                        color: AppColors.green600,
                        fontWeight: FontWeight.bold,
                      ),
                      color: AppColors.green600,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class RescheduleNotificationCard extends StatefulWidget {
  final ScheduledNotification notification;
  const RescheduleNotificationCard({super.key, required this.notification});

  @override
  State<RescheduleNotificationCard> createState() => _NavigationInfoCardState();
}

class _NavigationInfoCardState extends State<RescheduleNotificationCard> {
  bool notifyAvailableSpace = false;
  double radius = 100;

  bool isLocationAvailable = false;

  double distance = 0.0;

  @override
  void initState() {
    super.initState();
    getDistance();
  }

  void getDistance() async {
    // Check if location services are enabled
    setState(() {
      isLocationAvailable = false;
    });

    var currentLocation = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);

    // Get distance between two points
    distance = Geolocator.distanceBetween(
        widget.notification.location.point.lat,
        widget.notification.location.point.lng,
        currentLocation.latitude,
        currentLocation.longitude);
    print('Distance: $distance');

    setState(() {
      isLocationAvailable = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: isLocationAvailable
            ? [
                SizedBox(
                  height: 100,
                  child: Center(
                    child: CupertinoActivityIndicator(),
                  ),
                ),
              ]
            : [
                // Time and distance row
                Row(
                  children: [
                    Text(
                      // Format distance to miles to kilometers

                      "00 mins ${(distance / 1000).toStringAsFixed(1)} km",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        const Text(
                          "Traffic Level",
                          style: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(width: 8),
                        DecoratedChip(
                          text: "Moderate",
                          textStyle: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary500,
                          ),
                          color: AppColors.primary500,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 22),

                // Location
                Row(
                  children: [
                    Icon(IconlyLight.location, color: Colors.grey),
                    SizedBox(width: 8),
                    Text(
                      widget.notification.location.streetName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Arrival time
                Row(
                  children: [
                    Icon(IconlyLight.time_circle, color: Colors.grey),
                    SizedBox(width: 8),
                    Text(
                      "To Arrive in by 12:38pm",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Divider(color: Colors.grey.withOpacity(0.2)),
                const SizedBox(height: 16),

                // Notification toggle
                Row(
                  children: [
                    const Icon(IconlyLight.notification, color: Colors.grey),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        "Notify me of available space in this area",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    ToggleSwitch(
                      value: notifyAvailableSpace,
                      onChanged: (value) {
                        setState(() {
                          notifyAvailableSpace = value;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Time selection buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    PlatformTimePickerButton(
                        initialTime: "12:00 PM", onTimeSelected: (time) {}),
                    const SizedBox(width: 16),
                    PlatformTimePickerButton(
                        initialTime: "2:00 PM", onTimeSelected: (time) {}),
                  ],
                ),
                const SizedBox(height: 24),

                // Radius slider
                Row(
                  children: [
                    const Text(
                      "Radius (Meters)",
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                    Spacer(),
                    Text(
                      radius.toStringAsFixed(0),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: Colors.purple,
                    inactiveTrackColor: Colors.purple.withOpacity(0.2),
                    thumbColor: Colors.white,
                    overlayColor: Colors.purple.withOpacity(0.2),
                    thumbShape:
                        const RoundSliderThumbShape(enabledThumbRadius: 8),
                  ),
                  child: Slider(
                    value: radius,
                    min: 100,
                    max: 9000,
                    onChanged: (value) {
                      setState(() {
                        radius = value;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 24),

                // Reschedule button
                PrimaryButton(
                  text: 'Reschedule',
                ),
              ],
      ),
    );
  }
}

// Platform-aware Time Picker that uses different UI for iOS and Android
class PlatformTimePickerButton extends StatefulWidget {
  final String initialTime;
  final Function(TimeOfDay) onTimeSelected;
  final bool isSelected;

  const PlatformTimePickerButton({
    Key? key,
    required this.initialTime,
    required this.onTimeSelected,
    this.isSelected = false,
  }) : super(key: key);

  @override
  State<PlatformTimePickerButton> createState() =>
      _PlatformTimePickerButtonState();
}

class _PlatformTimePickerButtonState extends State<PlatformTimePickerButton> {
  late String displayTime;
  late TimeOfDay selectedTime;

  @override
  void initState() {
    super.initState();
    displayTime = widget.initialTime;
    // Convert string time to TimeOfDay - assuming format like "09:30 AM"
    final List<String> parts = widget.initialTime.split(' ');
    final List<String> timeParts = parts[0].split(':');
    int hour = int.parse(timeParts[0]);
    final int minute = int.parse(timeParts[1]);

    if (parts.length > 1 && parts[1] == 'PM' && hour < 12) {
      hour += 12;
    } else if (parts.length > 1 && parts[1] == 'AM' && hour == 12) {
      hour = 0;
    }

    selectedTime = TimeOfDay(hour: hour, minute: minute);
  }

  // Android Material style time picker
  Future<void> _showMaterialTimePicker(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: selectedTime,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.purple, // Header background
              onPrimary: Colors.white, // Header text
              onSurface: Colors.black, // Dial text
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.purple, // Button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime != null && pickedTime != selectedTime) {
      setState(() {
        selectedTime = pickedTime;
        // Format the time based on user's locale or specific format
        displayTime = _formatTimeOfDay(pickedTime);
      });
      widget.onTimeSelected(pickedTime);
    }
  }

  // iOS Cupertino style time picker
  void _showCupertinoTimePicker(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 280,
          padding: const EdgeInsets.only(top: 6.0),
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          color: CupertinoColors.systemBackground.resolveFrom(context),
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      child: const Text('Cancel'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    CupertinoButton(
                      child: const Text(
                        'Done',
                        style: TextStyle(color: CupertinoColors.activeBlue),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        widget.onTimeSelected(selectedTime);
                      },
                    ),
                  ],
                ),
                Expanded(
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.time,
                    initialDateTime: DateTime(
                      DateTime.now().year,
                      DateTime.now().month,
                      DateTime.now().day,
                      selectedTime.hour,
                      selectedTime.minute,
                    ),
                    onDateTimeChanged: (DateTime newDateTime) {
                      setState(() {
                        selectedTime = TimeOfDay(
                          hour: newDateTime.hour,
                          minute: newDateTime.minute,
                        );
                        displayTime = _formatTimeOfDay(selectedTime);
                      });
                    },
                    use24hFormat: false, // Set to true for 24h format
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Helper method to format TimeOfDay as a string
  String _formatTimeOfDay(TimeOfDay time) {
    final now = DateTime.now();
    final dateTime = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    // Format time based on preference (12h or 24h)
    final String formattedTime = dateTime.hour > 12
        ? '${dateTime.hour - 12}:${dateTime.minute.toString().padLeft(2, '0')} PM'
        : dateTime.hour == 12
            ? '12:${dateTime.minute.toString().padLeft(2, '0')} PM'
            : dateTime.hour == 0
                ? '12:${dateTime.minute.toString().padLeft(2, '0')} AM'
                : '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')} AM';

    return formattedTime;
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: OutlinedButton.icon(
        onPressed: () {
          // Use appropriate picker based on platform
          if (Platform.isIOS) {
            _showCupertinoTimePicker(context);
          } else {
            _showMaterialTimePicker(context);
          }
        },
        icon: const Icon(
          IconlyLight.time_circle,
          color: Colors.black54,
        ),
        label: Text(
          displayTime,
          style: TextStyle(
            color: widget.isSelected ? Colors.purple : Colors.black,
            fontWeight: widget.isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          side: BorderSide(
            color: widget.isSelected
                ? Colors.purple
                : Colors.grey.withOpacity(0.4),
            width: widget.isSelected ? 2.0 : 1.0,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          backgroundColor: widget.isSelected
              ? Colors.purple.withOpacity(0.05)
              : Colors.transparent,
        ),
      ),
    );
  }
}

// Example usage in a screen
class TimePickerDemoScreen extends StatefulWidget {
  const TimePickerDemoScreen({Key? key}) : super(key: key);

  @override
  State<TimePickerDemoScreen> createState() => _TimePickerDemoScreenState();
}

class _TimePickerDemoScreenState extends State<TimePickerDemoScreen> {
  TimeOfDay _selectedStartTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _selectedEndTime = const TimeOfDay(hour: 17, minute: 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Time Picker Demo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Time Range:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                PlatformTimePickerButton(
                  initialTime: '9:00 AM',
                  isSelected: true,
                  onTimeSelected: (TimeOfDay time) {
                    setState(() {
                      _selectedStartTime = time;
                    });
                  },
                ),
                const SizedBox(width: 12),
                PlatformTimePickerButton(
                  initialTime: '5:00 PM',
                  onTimeSelected: (TimeOfDay time) {
                    setState(() {
                      _selectedEndTime = time;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            // For demo purposes - show selected time range
            Text(
              'Selected range: ${_formatTimeOfDay(_selectedStartTime)} - ${_formatTimeOfDay(_selectedEndTime)}',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to format TimeOfDay
  String _formatTimeOfDay(TimeOfDay time) {
    final now = DateTime.now();
    final dateTime =
        DateTime(now.year, now.month, now.day, time.hour, time.minute);

    final String formattedTime = dateTime.hour > 12
        ? '${dateTime.hour - 12}:${dateTime.minute.toString().padLeft(2, '0')} PM'
        : dateTime.hour == 12
            ? '12:${dateTime.minute.toString().padLeft(2, '0')} PM'
            : dateTime.hour == 0
                ? '12:${dateTime.minute.toString().padLeft(2, '0')} AM'
                : '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')} AM';

    return formattedTime;
  }
}
