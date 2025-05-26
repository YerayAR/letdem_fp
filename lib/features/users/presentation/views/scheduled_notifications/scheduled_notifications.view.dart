import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconly/iconly.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
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
import 'package:letdem/services/toast/toast.dart';
import 'package:letdem/views/app/maps/route.view.dart';
import 'package:letdem/views/app/notifications/views/notification.view.dart';

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
        .add(const FetchScheduledNotificationsEvent());
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
                child: state.scheduledNotifications.isEmpty
                    ? const EmptyScheduleNotificationView()
                    : ListView(
                        children: state.scheduledNotifications
                            .map((e) => ScheduleNotificationItem(
                                  notification: e,
                                ))
                            .toList(),
                      ),
              );
            }
            return const SizedBox();
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
                                    const Spacer(),
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
                      const TextSpan(
                          text: "You have a reminder for a space at "),
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

                const SizedBox(height: 8), // More vertical spacing

                // Time text
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${DateFormat('MMM d HH:mm').format(notification.startsAt)} - ${DateFormat('MMM d HH:mm').format(notification.endsAt)}',
                      style: Typo.mediumBody.copyWith(
                        color: AppColors.neutral500,
                      ),
                    ),
                    DecoratedChip(
                      text: notification.isExpired ? 'Expired' : 'Active',
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 6,
                      ),
                      textStyle: Typo.smallBody.copyWith(
                        color: notification.isExpired
                            ? AppColors.secondary600
                            : AppColors.green600,
                        fontWeight: FontWeight.bold,
                      ),
                      color: notification.isExpired
                          ? AppColors.secondary500
                          : AppColors.green500,
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
  late double radius;

  bool isLocationAvailable = false;

  @override
  void initState() {
    super.initState();
    radius =
        widget.notification.radius < 100 ? 100 : widget.notification.radius;

    _startsAt = widget.notification.startsAt;
    _endsAt = widget.notification.endsAt;
    _selectedStartTime = TimeOfDay(
        hour: widget.notification.startsAt.hour,
        minute: widget.notification.startsAt.minute);
    _selectedEndTime = TimeOfDay(
        hour: widget.notification.endsAt.hour,
        minute: widget.notification.endsAt.minute);
    getDistance();
  }

  late DateTime _startsAt;
  late DateTime _endsAt;

  late TimeOfDay _selectedStartTime;
  late TimeOfDay _selectedEndTime;

  // RouteInfo? routeInfo;

  void getDistance() async {
    // Check if location services are enabled
    setState(() {
      isLocationAvailable = true;
    });

    // var currentLocation = await Geolocator.getCurrentPosition(
    //     desiredAccuracy: LocationAccuracy.best);

    // var routeInfoData = await MapboxService.getRoutes(
    //     currentPointLatitude: currentLocation.latitude,
    //     currentPointLongitude: currentLocation.longitude,
    //     destination: widget.notification.location.streetName);

    setState(() {
      // routeInfo = routeInfoData;
      isLocationAvailable = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ScheduleNotificationsBloc, ScheduleNotificationsState>(
      listener: (context, state) {
        if (state is ScheduleNotificationCreated) {
          Toast.show('Notification rescheduled successfully');
          context
              .read<ScheduleNotificationsBloc>()
              .add(const FetchScheduledNotificationsEvent());
          NavigatorHelper.pop();
        }
        // TODO: implement listener
      },
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.all(16),
          // decoration: BoxDecoration(
          //   color: Colors.white,
          //   borderRadius: BorderRadius.circular(16),
          //   boxShadow: [
          //     BoxShadow(
          //       color: Colors.grey.withOpacity(0.1),
          //       spreadRadius: 1,
          //       blurRadius: 10,
          //       offset: const Offset(0, 2),
          //     ),
          //   ],
          // ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: isLocationAvailable
                ? [
                    const SizedBox(
                      height: 100,
                      child: Center(
                        child: CupertinoActivityIndicator(),
                      ),
                    ),
                  ]
                : [
                    Text("Reschedule Notification",
                        style: Typo.heading1.copyWith(
                          fontSize: 20,
                        )),
                    // Time and distance row
                    // Row(
                    //   children: [
                    //     Text(
                    //       // Format distance to miles to kilometers
                    //
                    //       "${parseHours(routeInfo!.duration)} (${parseMeters(routeInfo!.distance)})",
                    //       style: const TextStyle(
                    //         fontSize: 18,
                    //         fontWeight: FontWeight.bold,
                    //       ),
                    //     ),
                    //     const Spacer(),
                    //     Row(
                    //       children: [
                    //         const Text(
                    //           "Traffic Level",
                    //           style: TextStyle(
                    //             fontSize: 14,
                    //           ),
                    //         ),
                    //         const SizedBox(width: 8),
                    //         DecoratedChip(
                    //           text: toBeginningOfSentenceCase(
                    //               routeInfo!.tafficLevel),
                    //           textStyle: TextStyle(
                    //             fontSize: 14,
                    //             fontWeight: FontWeight.w600,
                    //             color: AppColors.primary500,
                    //           ),
                    //           color: AppColors.primary500,
                    //         ),
                    //       ],
                    //     ),
                    //   ],
                    // ),
                    const SizedBox(height: 22),

                    // Location
                    Row(
                      children: [
                        const Icon(IconlyLight.location, color: Colors.grey),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            widget.notification.location.streetName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    // const SizedBox(height: 16),
                    //
                    // // Arrival time
                    // Row(
                    //   children: [
                    //     Icon(IconlyLight.time_circle, color: Colors.grey),
                    //     SizedBox(width: 8),
                    //     Text(
                    //       // 24 hour format
                    //       "To be Arrived by ${DateFormat('HH:mm').format(routeInfo!.arrivingAt.toLocal())}",
                    //       // "To Arrive in by ${DateFormat('hh:mm a').format(routeInfo!.arrivingAt.toLocal())}",
                    //       style: TextStyle(
                    //         fontSize: 16,
                    //         fontWeight: FontWeight.w500,
                    //       ),
                    //     ),
                    //   ],
                    // ),
                    const SizedBox(height: 16),
                    Divider(color: Colors.grey.withOpacity(0.2)),
                    const SizedBox(height: 16),

                    Text(
                      "Date & Time",
                      style: Typo.mediumBody
                          .copyWith(color: Colors.black, fontSize: 16),
                    ),
                    Dimens.space(3),
                    Row(
                      spacing: 15,
                      children: [
                        PlatformDatePickerButton(
                            initialDate: _startsAt,
                            onDateSelected: (date) {
                              setState(() {
                                _startsAt = date;
                              });
                            }),
                        PlatformTimePickerButton(
                            initialTime: _selectedStartTime,
                            onTimeSelected: (time) {
                              setState(() {
                                _selectedStartTime = time;
                              });
                            }),
                      ],
                    ),
                    Dimens.space(1),

                    Row(
                      spacing: 15,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        PlatformDatePickerButton(
                            initialDate: _endsAt,
                            onDateSelected: (date) {
                              setState(() {
                                _endsAt = date;
                              });
                            }),
                        PlatformTimePickerButton(
                            initialTime: _selectedEndTime,
                            onTimeSelected: (time) {
                              setState(() {
                                _selectedEndTime = time;
                              });
                            }),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Radius slider
                    Row(
                      children: [
                        const Text(
                          "Receive notifications up to (meters)",
                          style: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          radius.toStringAsFixed(0),
                          style: const TextStyle(
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
                      onTap: () {
                        // check if the the end time is greater than the start time

                        DateTime start = DateTime(
                          _startsAt.year,
                          _startsAt.month,
                          _startsAt.day,
                          _selectedStartTime.hour,
                          _selectedStartTime.minute,
                        );

                        DateTime end = DateTime(
                          _endsAt.year,
                          _endsAt.month,
                          _endsAt.day,
                          _selectedEndTime.hour,
                          _selectedEndTime.minute,
                        );

                        if (!validateDateTime(start, end)) {
                          return;
                        }

                        context.read<ScheduleNotificationsBloc>().add(
                              CreateScheduledNotificationEvent(
                                startsAt: start,
                                endsAt: end,
                                isUpdate: true,
                                eventID: widget.notification.id,
                                location: widget.notification.location,
                                radius: radius,
                              ),
                            );
                        NavigatorHelper.pop();
                      },
                      isLoading: state is ScheduleNotificationsLoading,
                      text: 'Reschedule',
                    ),
                    Dimens.space(2)
                  ],
          ),
        );
      },
    );
  }
}

// Platform-aware Time Picker that uses different UI for iOS and Android
class PlatformTimePickerButton extends StatefulWidget {
  final TimeOfDay initialTime;
  final Function(TimeOfDay) onTimeSelected;
  final bool isSelected;

  const PlatformTimePickerButton({
    super.key,
    required this.initialTime,
    required this.onTimeSelected,
    this.isSelected = false,
  });

  @override
  State<PlatformTimePickerButton> createState() =>
      _PlatformTimePickerButtonState();
}

class _PlatformTimePickerButtonState extends State<PlatformTimePickerButton> {
  late TimeOfDay selectedTime;

  @override
  void initState() {
    super.initState();

    selectedTime = widget.initialTime;
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
                    // set 24 hour format

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
                      });
                    },
                    use24hFormat: true, // Set to true for 24h format
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

    // Format time in 24-hour format
    final String formattedTime =
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';

    return formattedTime;
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: widget.isSelected
                ? Colors.purple
                : Colors.grey.withOpacity(0.4),
            width: widget.isSelected ? 2.0 : 1.0,
          ),
          borderRadius: BorderRadius.circular(24),
          color: widget.isSelected
              ? Colors.purple.withOpacity(0.05)
              : Colors.transparent,
        ),
        child: TextButton(
          onPressed: () {
            if (Platform.isIOS) {
              _showCupertinoTimePicker(context);
            } else {
              _showMaterialTimePicker(context);
            }
          },
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatTimeOfDay(selectedTime),
                style: TextStyle(
                  color: widget.isSelected ? Colors.purple : Colors.black,
                  fontWeight:
                      widget.isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              const Icon(
                IconlyLight.time_circle,
                size: 23,
                color: Colors.black54,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PlatformDatePickerButton extends StatefulWidget {
  final DateTime initialDate;
  final Function(DateTime) onDateSelected;
  final bool isSelected;

  const PlatformDatePickerButton({
    super.key,
    required this.initialDate,
    required this.onDateSelected,
    this.isSelected = false,
  });

  @override
  State<PlatformDatePickerButton> createState() =>
      _PlatformDatePickerButtonState();
}

class _PlatformDatePickerButtonState extends State<PlatformDatePickerButton> {
  late DateTime selectedDate;

  @override
  void initState() {
    super.initState();
    selectedDate = widget.initialDate;
  }

  // Android Material style date picker
  Future<void> _showMaterialDatePicker(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.purple, // Header background color
              onPrimary: Colors.white, // Header text color
              onSurface: Colors.black, // Body text color
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

    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  // iOS Cupertino style date picker
  void _showCupertinoDatePicker(BuildContext context) {
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
                        widget.onDateSelected(selectedDate);
                      },
                    ),
                  ],
                ),
                Expanded(
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.date,
                    initialDateTime: selectedDate.isBefore(DateTime.now())
                        ? DateTime.now()
                        : selectedDate,
                    minimumDate: DateTime(DateTime.now().year,
                        DateTime.now().month, DateTime.now().day),
                    maximumDate: DateTime(2100),
                    onDateTimeChanged: (DateTime newDateTime) {
                      setState(() {
                        selectedDate = newDateTime;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: widget.isSelected
                ? Colors.purple
                : Colors.grey.withOpacity(0.4),
            width: widget.isSelected ? 2.0 : 1.0,
          ),
          borderRadius: BorderRadius.circular(24),
          color: widget.isSelected
              ? Colors.purple.withOpacity(0.05)
              : Colors.transparent,
        ),
        child: TextButton(
          onPressed: () {
            if (Platform.isIOS) {
              _showCupertinoDatePicker(context);
            } else {
              _showMaterialDatePicker(context);
            }
          },
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                // 11/2/2025
                DateFormat('MM/dd/yyyy').format(selectedDate),
                style: TextStyle(
                  color: widget.isSelected ? Colors.purple : Colors.black,
                  fontWeight:
                      widget.isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              const Icon(
                IconlyLight.calendar,
                color: Colors.black54,
                size: 23,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
