import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:letdem/common/widgets/appbar.dart';
import 'package:letdem/common/widgets/body.dart';
import 'package:letdem/core/constants/colors.dart';
import 'package:letdem/core/constants/dimens.dart';
import 'package:letdem/core/constants/typo.dart';
import 'package:letdem/core/extensions/locale.dart';
import 'package:letdem/core/extensions/user.dart';
import 'package:letdem/features/activities/activities_bloc.dart';
import 'package:letdem/features/activities/activities_state.dart';
import 'package:letdem/features/activities/presentation/views/active_reservation.view.dart';
import 'package:letdem/features/activities/presentation/views/view_all.view.dart';
import 'package:letdem/features/activities/presentation/widgets/contribution_item.widget.dart';
import 'package:letdem/features/activities/presentation/widgets/no_contribution.widget.dart';
import 'package:letdem/features/activities/presentation/widgets/registered_car.widget.dart';
import 'package:letdem/features/car/car_bloc.dart';
import 'package:letdem/features/notifications/presentation/views/notification.view.dart';
import 'package:letdem/features/users/presentation/widgets/profile_section.widget.dart';
import 'package:letdem/infrastructure/services/res/navigator.dart';

import '../widgets/no_car_registered.widget.dart';

enum ContributionType {
  space,
  event,
}

class ActivitiesView extends StatefulWidget {
  const ActivitiesView({super.key});

  @override
  State<ActivitiesView> createState() => _ActivitiesViewState();
}

class _ActivitiesViewState extends State<ActivitiesView> {
  @override
  void initState() {
    super.initState();
    // context.read<ActivitiesBloc>().add(GetActivitiesEvent());
  }

  Widget _buildFooter(ActivitiesState state) {
    bool isActiveReservation = context.userProfile?.activeReservation != null;

    Widget item = ContributionsSection();

    print("isActiveReservation: $isActiveReservation");

    return item;
  }

  Widget _buidShowAllButton(ActivitiesState state) {
    print("state: $state");

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          context.l10n.contributions,
          style: Typo.mediumBody.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        if (state is ActivitiesLoaded && state.activities.isNotEmpty)
          TextButton(
            onPressed: () {
              NavigatorHelper.to(const ViewAllView());
            },
            child: Text(
              context.l10n.showAll,
              style: Typo.smallBody.copyWith(
                color: AppColors.primary500,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<ActivitiesBloc, ActivitiesState>(
        listener: (context, state) {},
        builder: (context, state) {
          var w = StyledBody(
            isBottomPadding: false,
            children: context.userProfile?.activeReservation != null
                ? [
                    Expanded(
                      child: ListView(
                        children: [
                          const NotificationAppBar(),
                          const CarSection(),
                          const ActiveReservationSection(),
                          _buidShowAllButton(state),
                          _buildFooter(state),
                        ],
                      ),
                    ),
                  ]
                : [
                    const NotificationAppBar(),
                    const CarSection(),
                    const ActiveReservationSection(),
                    _buidShowAllButton(state),
                    Expanded(child: _buildFooter(state)),
                  ],
          );

          return w;
        },
      ),
    );
  }
}

class NotificationAppBar extends StatelessWidget {
  const NotificationAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    // Fix: Add null safety check for userProfile
    final userProfile = context.userProfile;
    final notificationCount = userProfile?.notificationsCount ?? 0;

    return StyledAppBar(
      suffix: notificationCount == 0
          ? null
          : CircleAvatar(
              radius: 8,
              backgroundColor: AppColors.red500,
              child: Text(
                notificationCount.toString(),
                style: Typo.smallBody.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
      title: context.l10n.activities,
      onTap: () => NavigatorHelper.to(const NotificationsView()),
      icon: Iconsax.notification5,
    );
  }
}

class CarSection extends StatelessWidget {
  const CarSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CarBloc, CarState>(
      listener: (context, state) {},
      builder: (context, state) {
        if (state is CarLoaded && state.car != null) {
          return ProfileSection(
            child: [
              RegisteredCarWidget(car: state.car!),
              Dimens.space(1),
              LastParkedWidget(lastParked: state.car!.lastParkingLocation),
            ],
          );
        }
        return const ProfileSection(
          child: [
            NoCarRegisteredWidget(),
          ],
        );
      },
    );
  }
}

class ActiveReservationSection extends StatelessWidget {
  const ActiveReservationSection({super.key});

  @override
  Widget build(BuildContext context) {
    final activeReservation = context.userProfile?.activeReservation;
    if (activeReservation == null) return const SizedBox();

    return ActiveReservationView(payload: activeReservation);
  }
}

class ContributionsSection extends StatelessWidget {
  const ContributionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ActivitiesBloc, ActivitiesState>(
      builder: (context, state) {
        // Fix: Better state handling and null safety
        // if (state is! ActivitiesLoaded) {
        //   return const Center(child: CircularProgressIndicator());
        // }

        final contributions = context.userProfile!.contributions;
        final isEmpty = contributions.isEmpty;

        return Container(
          height: context.userProfile?.activeReservation != null ? 400 : null,
          width: double.infinity,
          // Fix: Add constraints to prevent unbounded height issues
          constraints: const BoxConstraints(
            minHeight: 200,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 25),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(Dimens.defaultRadius),
              topRight: Radius.circular(Dimens.defaultRadius),
            ),
          ),
          child: isEmpty
              ? const NoContributionsWidget()
              : Column(
                  // Fix: Prevent overflow in column
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Fix: Use Flexible or shrinkWrap for ListView if many items
                    ...contributions.map((activity) {
                      return ContributionItem(
                        showDivider: contributions.last != activity,
                        type: activity.type.toLowerCase() == "space"
                            ? ContributionType.space
                            : ContributionType.event,
                        activity: activity,
                      );
                    }).toList(),
                  ],
                ),
        );
      },
    );
  }
}

// Alternative ContributionsSection if you have many contribution items
class ContributionsSectionWithListView extends StatelessWidget {
  const ContributionsSectionWithListView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ActivitiesBloc, ActivitiesState>(
      builder: (context, state) {
        if (state is! ActivitiesLoaded) {
          return const Center(child: CircularProgressIndicator());
        }

        final contributions = state.activities;
        final isEmpty = contributions.isEmpty;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 25),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(Dimens.defaultRadius),
              topRight: Radius.circular(Dimens.defaultRadius),
            ),
          ),
          child: isEmpty
              ? const NoContributionsWidget()
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: contributions.length,
                  itemBuilder: (context, index) {
                    final activity = contributions[index];
                    return ContributionItem(
                      showDivider: index < contributions.length - 1,
                      type: activity.type.toLowerCase() == "space"
                          ? ContributionType.space
                          : ContributionType.event,
                      activity: activity,
                    );
                  },
                ),
        );
      },
    );
  }
}
