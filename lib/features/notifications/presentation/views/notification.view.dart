import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconly/iconly.dart';
import 'package:iconsax/iconsax.dart';
import 'package:letdem/common/widgets/appbar.dart';
import 'package:letdem/common/widgets/body.dart';
import 'package:letdem/common/widgets/chip.dart';
import 'package:letdem/core/constants/colors.dart';
import 'package:letdem/core/constants/dimens.dart';
import 'package:letdem/core/extensions/locale.dart';
import 'package:letdem/features/commons/presentations/widgets/date_time_display.widget.dart';
import 'package:letdem/features/map/presentation/views/route.view.dart';
import 'package:letdem/features/notifications/models/notification.model.dart';
import 'package:letdem/features/notifications/notifications_bloc.dart';
import 'package:letdem/features/users/user_bloc.dart';
import 'package:letdem/infrastructure/services/res/navigator.dart';
import 'package:shimmer/shimmer.dart';

enum NotificationType {
  all,
  unread,
}

extension NotificationTypeExtension on NotificationType {
  String name(BuildContext context) {
    switch (this) {
      case NotificationType.all:
        return context.l10n.all;
      case NotificationType.unread:
        return context.l10n.unread;
    }
  }
}

class NotificationsView extends StatefulWidget {
  const NotificationsView({super.key});

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> {
  // var viewAllType = NotificationType.all;

  @override
  initState() {
    super.initState();
    context.read<NotificationsBloc>().add(const LoadNotificationsEvent());
  }

  RichText getDynamicTextFromType(NotificationPayloadType type,
      NotificationObject notificationObject, String? distance) {
    switch (type) {
      // Your space located at Gran Vía 46, Madrid, Spain Received positive feedback
      case NotificationPayloadType.spaceOccupied:
        return RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: context.l10n.yourSpaceLocatedAt,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                ),
              ),
              TextSpan(
                text: notificationObject.location.streetName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.black,
                ),
              ),
              TextSpan(
                text: context.l10n.hasBeenOccupied,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        );
      // return 'Your space located at ${notificationObject.location.streetName} Received positive feedback';

      // Your space located at Gran Vía 46, Madrid, Spain Received negative feedback
      case NotificationPayloadType.spaceNearby:
        // A new space has been published within 12 meters around Gran Vía 46, Madrid, Spain
        return RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: context.l10n.aNewSpaceHasBeenPublished,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                ),
              ),
              TextSpan(
                text: '$distance ',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 14,
                ),
              ),
              TextSpan(
                text: context.l10n.around,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                ),
              ),
              TextSpan(
                text: notificationObject.location.streetName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        );
      // return "A new space has been published within ${0} meters around ${notificationObject.location.streetName}";
      case NotificationPayloadType.spaceReserved:
        return RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: context.l10n.yourSpaceLocatedAt,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                ),
              ),
              TextSpan(
                text: notificationObject.location.streetName,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              TextSpan(
                text: context.l10n.hasBeenReserved,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        );
      // return 'Your space located at ${notificationObject.location.streetName} has been reserved';

      default:
        return RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: context.l10n.yourSpaceLocatedAt,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                ),
              ),
              TextSpan(
                text: notificationObject.location.streetName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 14,
                ),
              ),
              TextSpan(
                text: context.l10n.receivedPositiveFeedback,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldColor,
      body: StyledBody(
        children: [
          StyledAppBar(
            title: context.l10n.notifications,
            onTap: () {
              NavigatorHelper.pop();
            },
            icon: Icons.close,
          ),
          Dimens.space(3),
          // FilterTabs<NotificationType>(
          //   isExapnded: true,
          //   values: NotificationType.values,
          //   getName: (type) => type.name(context),
          //   initialValue: viewAllType,
          //   onSelected: (type) {
          //     setState(() {
          //       viewAllType = type;
          //     });
          //     // Perform filtering logic here
          //   },
          //   selectedColor: AppColors.primary400,
          //   unselectedTextColor: AppColors.neutral500,
          // ),
          // Dimens.space(2),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: context.watch<NotificationsBloc>().state
                        is NotificationsLoaded &&
                    (context.read<NotificationsBloc>().state
                            as NotificationsLoaded)
                        .unreadNotifications
                        .results
                        .isNotEmpty
                ? [
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        context
                            .read<NotificationsBloc>()
                            .add(ClearNotificationsEvent());
                        context.read<UserBloc>().add(FetchUserInfoEvent());
                      },
                      child: Text(
                        context.l10n.clearAll,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                          color: AppColors.primary400,
                        ),
                      ),
                    ),
                  ]
                : [],
          ),
          Dimens.space(2),
          BlocConsumer<NotificationsBloc, NotificationsState>(
            listener: (context, state) {
              if (state is NotificationsLoaded) {
                context.read<UserBloc>().add(UpdateUserNotificationsEvent(
                      unreadNotificationsCount: state.unreadNotifications.count,
                    ));
              }
              // TODO: implement listener
            },
            builder: (context, state) {
              if (state is NotificationsLoading) {
                return Expanded(
                  child: ListView.builder(
                    itemCount: 5,
                    itemBuilder: (context, index) {
                      return const NotificationShimmer();
                    },
                  ),
                );
              }

              if (state is NotificationsLoaded &&
                  state.unreadNotifications.count == 0) {
                return const Expanded(
                  child: EmptyNotificationView(),
                );
              }

              if (state is NotificationsLoaded) {
                return Expanded(
                  child: ListView.builder(
                    itemCount: state.unreadNotifications.results.length,
                    itemBuilder: (context, index) {
                      var notification =
                          state.unreadNotifications.results[index];
                      return NotificationItem(
                        type: notification.type,
                        notificationObject: notification.notificationObject,
                        title: formatedNotificationType(
                            notification.type, context),
                        message: getDynamicTextFromType(
                            notification.type,
                            notification.notificationObject,
                            notification.distance),
                        timestamp: notification.notificationObject.created,
                        actionLabel: '',
                        amount: null,
                        iconColor: Colors.purple,
                        isRecent: false,
                        onActionPressed: () {
                          // Perform action here
                        },
                        onRead: (String id) {
                          context.read<NotificationsBloc>().add(
                                MarkNotificationAsReadEvent(
                                    id: notification.id),
                              );
                        },
                      );
                    },
                  ),
                );
              }
              if (state is NotificationsError) {
                return Expanded(
                  child: Center(
                    child: Text(state.error),
                  ),
                );
              }

              return const Expanded(
                child: EmptyNotificationView(),
              );
            },
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
            context.l10n.noNotificationsYet,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            context.l10n.notificationsWillAppear,
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

class EmptyScheduleNotificationView extends StatelessWidget {
  const EmptyScheduleNotificationView({super.key});

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
            context.l10n.noScheduledNotificationsYet,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            context.l10n.scheduledNotificationsWillAppear,
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

class NotificationShimmer extends StatelessWidget {
  const NotificationShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: SizedBox(
          height: 130.0,
          child: Shimmer.fromColors(
            baseColor: Colors.white.withOpacity(0.5),
            highlightColor: Colors.grey[100]!,
            child: Container(
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class NotificationItem extends StatelessWidget {
  final String title;
  final RichText message;
  final DateTime timestamp;

  final NotificationPayloadType type;
  final String? actionLabel;
  final String? amount;
  final Color iconColor;
  final bool isRecent;
  final VoidCallback? onActionPressed;
  final Function(String id) onRead;

  final NotificationObject notificationObject;

  const NotificationItem({
    super.key,
    required this.title,
    required this.message,
    required this.notificationObject,
    required this.timestamp,
    required this.type,
    required this.onRead,
    this.actionLabel,
    this.amount,
    this.iconColor = Colors.purple,
    this.isRecent = false,
    this.onActionPressed,
  });

  Widget getSubIcon(NotificationPayloadType type) {
    switch (type) {
      case NotificationPayloadType.spaceOccupied:
        return CircleAvatar(
          radius: 8,
          backgroundColor: AppColors.primary500,
          child: const Icon(
            IconlyBold.location,
            color: Colors.white,
            size: 11,
          ),
        );
      case NotificationPayloadType.spaceNearby:
        return CircleAvatar(
          radius: 8,
          backgroundColor: AppColors.primary500,
          child: const Icon(
            IconlyBold.time_circle,
            color: Colors.white,
            size: 11,
          ),
        );
      case NotificationPayloadType.spaceReserved:
        return CircleAvatar(
          radius: 8,
          backgroundColor: AppColors.green500,
          child: const Icon(
            IconlyBold.location,
            color: Colors.white,
            size: 11,
          ),
        );
      default:
        return CircleAvatar(
          radius: 20,
          backgroundColor: Colors.grey.shade200,
          child: const Icon(
            Iconsax.star,
            color: Colors.amber,
            size: 20,
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 5,
        bottom: 5,
      ),
      child: Dismissible(
        key: Key(notificationObject.id),
        background: Container(
          color: Colors.blue,
          child: const Icon(
            Icons.done_all_rounded,
            color: Colors.white,
          ),
        ),
        onDismissed: (direction) {
          // Remove the item from the data source.
          onRead(notificationObject.id);
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon container
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          IconlyBold.notification,
                          color: AppColors.neutral400,
                          size: 20,
                        ),
                      ),
                    ),
                    Positioned(
                      right: -3,
                      bottom: -3,
                      child: getSubIcon(type),
                    ),
                  ],
                ),

                Dimens.space(2),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Message
                      message,
                      const SizedBox(height: 8),

                      // Time and action row
                      Row(
                        children: [
                          // Timestamp
                          DateTimeDisplay(date: timestamp),
                          // Amount if available
                          if (amount != null) ...[
                            const Spacer(),
                            Text(
                              amount!,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.amber,
                                fontSize: 14,
                              ),
                            ),
                          ],

                          // Push content to each side
                          if (actionLabel != null) const Spacer(),

                          // Action button if available
                        ],
                      ),
                      if (type == NotificationPayloadType.spaceNearby)
                        Column(
                          children: [
                            Dimens.space(2),
                            DecoratedChip(
                              onTap: () {
                                NavigatorHelper.to(NavigationMapScreen(
                                  googlePlaceID: null,
                                  latitude:
                                      notificationObject.location.point.lat,
                                  longitude:
                                      notificationObject.location.point.lng,
                                  hideToggle: false,
                                  destinationStreetName:
                                      notificationObject.location.streetName,
                                ));
                              },
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 7,
                              ),
                              text: context.l10n.viewSpace,
                              backgroundColor: AppColors.primary300,
                              color: Colors.white,
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
