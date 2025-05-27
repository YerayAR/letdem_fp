import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:letdem/common/widgets/appbar.dart';
import 'package:letdem/core/constants/dimens.dart';
import 'package:letdem/features/notifications/presentation/views/notification.view.dart';
import 'package:letdem/features/scheduled_notifications/presentation/widgets/schedule_notification_item.widget.dart';
import 'package:letdem/features/scheduled_notifications/schedule_notifications_bloc.dart';
import 'package:letdem/infrastructure/services/res/navigator.dart';

import '../../../../common/widgets/body.dart';

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
