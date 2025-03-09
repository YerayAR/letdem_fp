import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:letdem/constants/ui/colors.dart';
import 'package:letdem/constants/ui/dimens.dart';
import 'package:letdem/global/widgets/appbar.dart';
import 'package:letdem/global/widgets/body.dart';
import 'package:letdem/services/res/navigator.dart';
import 'package:letdem/views/app/activities/screens/view_all.view.dart';

enum NotificationType {
  all,
  unread,
}

extension NotificationTypeExtension on NotificationType {
  String get name {
    switch (this) {
      case NotificationType.all:
        return 'All';
      case NotificationType.unread:
        return 'Unread';
    }
  }
}

class NotificationsView extends StatefulWidget {
  const NotificationsView({super.key});

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> {
  var viewAllType = NotificationType.all;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldColor,
      body: StyledBody(
        children: [
          StyledAppBar(
            title: 'Notifications',
            onTap: () {
              NavigatorHelper.pop();
            },
            icon: Icons.close,
          ),
          Dimens.space(3),
          FilterTabs<NotificationType>(
            isExapnded: true,
            values: NotificationType.values,
            getName: (type) => type.name,
            initialValue: viewAllType,
            onSelected: (type) {
              setState(() {
                viewAllType = type;
              });
              // Perform filtering logic here
            },
            selectedColor: AppColors.primary400,
            unselectedTextColor: AppColors.neutral500,
          ),
          Expanded(
            child: EmptyNotificationView(),
          ),
        ],
      ),
    );
  }
}

class EmptyNotificationView extends StatelessWidget {
  const EmptyNotificationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white,
            child: Icon(
              Iconsax.notification5,
              size: 40,
              color: AppColors.primary500,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'No Notifications Yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Your app notifications will appear here\nwhenever there is a new activity',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.neutral400,
            ),
          ),
        ],
      ),
    );
  }
}
