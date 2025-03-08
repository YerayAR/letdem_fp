import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:letdem/constants/ui/colors.dart';
import 'package:letdem/constants/ui/dimens.dart';
import 'package:letdem/constants/ui/typo.dart';
import 'package:letdem/global/widgets/appbar.dart';
import 'package:letdem/global/widgets/body.dart';
import 'package:letdem/global/widgets/chip.dart';
import 'package:letdem/services/res/navigator.dart';
import 'package:letdem/views/app/notifications/views/notification.view.dart';

class ScheduledNotificationsView extends StatelessWidget {
  const ScheduledNotificationsView({super.key});

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
        Expanded(
          child: false
              ? const EmptyNotificationView()
              : ListView(children: const <Widget>[
                  ScheduleNotificationItem(),
                  ScheduleNotificationItem(),
                  ScheduleNotificationItem(),
                ]),
        )
      ]),
    );
  }
}

class ScheduleNotificationItem extends StatelessWidget {
  const ScheduleNotificationItem({super.key});

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
                    child: Icon(
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
                    Icon(
                      CupertinoIcons.ellipsis,
                      color: AppColors.neutral300,
                      size: 17,
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
                        text: "Street39, Avenida de Niceto",
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
                      'From 12:00 PM to 2:00 PM', // Fixed typo 'T' to 'to'
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
