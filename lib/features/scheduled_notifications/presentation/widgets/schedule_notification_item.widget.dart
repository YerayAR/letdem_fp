import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconly/iconly.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:letdem/common/popups/popup.dart';
import 'package:letdem/common/widgets/chip.dart';
import 'package:letdem/core/constants/colors.dart';
import 'package:letdem/core/constants/dimens.dart';
import 'package:letdem/core/constants/typo.dart';
import 'package:letdem/features/scheduled_notifications/presentation/widgets/reschedule_notification.widget.dart';
import 'package:letdem/features/scheduled_notifications/schedule_notifications_bloc.dart';
import 'package:letdem/infrastructure/services/res/navigator.dart';

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
