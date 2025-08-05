import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconly/iconly.dart';
import 'package:letdem/common/popups/date_time_picker.widget.dart';
import 'package:letdem/common/widgets/button.dart';
import 'package:letdem/core/constants/dimens.dart';
import 'package:letdem/core/constants/typo.dart';
import 'package:letdem/core/extensions/locale.dart';
import 'package:letdem/core/utils/dates.dart';
import 'package:letdem/features/scheduled_notifications/schedule_notifications_bloc.dart';
import 'package:letdem/infrastructure/services/res/navigator.dart';
import 'package:letdem/infrastructure/toast/toast/toast.dart';


class RescheduleNotificationCard extends StatefulWidget {
  final ScheduledNotification notification;
  const RescheduleNotificationCard({super.key, required this.notification});

  @override
  State<RescheduleNotificationCard> createState() =>
      _RescheduleNotificationCardState();
}

class _RescheduleNotificationCardState
    extends State<RescheduleNotificationCard> {
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

  void getDistance() async {
    setState(() {
      isLocationAvailable = true;
    });

    setState(() {
      isLocationAvailable = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ScheduleNotificationsBloc, ScheduleNotificationsState>(
      listener: (context, state) {
        if (state is ScheduleNotificationCreated) {
          Toast.show(context.l10n.notificationRescheduledSuccessfully);
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
                    Text(context.l10n.rescheduleNotification,
                        style: Typo.heading1.copyWith(
                          fontSize: 20,
                        )),

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

                    const SizedBox(height: 16),
                    Divider(color: Colors.grey.withOpacity(0.2)),
                    const SizedBox(height: 16),

                    Text(
                      context.l10n.dateAndTime,
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
                        Text(
                          context.l10n.notificationRadius,
                          style: const TextStyle(
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
                        divisions: 89, // (9000 - 100) / 100 = 89 divisions
                        onChanged: (value) {
                          final roundedValue = (value / 100).round() * 100;
                          setState(() => radius = roundedValue.toDouble());
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

                        if (!validateDateTime(context, start, end)) {
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
                      text: context.l10n.reschedule,
                    ),
                    Dimens.space(2)
                  ],
          ),
        );
      },
    );
  }
}
