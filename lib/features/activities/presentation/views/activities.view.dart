import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:letdem/constants/ui/colors.dart';
import 'package:letdem/constants/ui/dimens.dart';
import 'package:letdem/constants/ui/typo.dart';
import 'package:letdem/extenstions/user.dart';
import 'package:letdem/features/activities/activities_bloc.dart';
import 'package:letdem/features/activities/activities_state.dart';
import 'package:letdem/features/activities/presentation/views/active_reservation.view.dart';
import 'package:letdem/features/activities/presentation/widgets/contribution_item.widget.dart';
import 'package:letdem/features/activities/presentation/widgets/no_contribution.widget.dart';
import 'package:letdem/features/activities/presentation/widgets/registered_car.widget.dart';
import 'package:letdem/features/car/car_bloc.dart';
import 'package:letdem/features/users/presentation/widgets/profile_section.widget.dart';
import 'package:letdem/global/widgets/appbar.dart';
import 'package:letdem/global/widgets/body.dart';
import 'package:letdem/services/res/navigator.dart';
import 'package:letdem/views/app/notifications/views/notification.view.dart';

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
  initState() {
    super.initState();
    context.read<ActivitiesBloc>().add(GetActivitiesEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<ActivitiesBloc, ActivitiesState>(
        listener: (context, state) {},
        builder: (context, state) {
          return StyledBody(
            isBottomPadding: false,
            children: [
              const NotificationAppBar(),
              const CarSection(),
              const ActiveReservationSection(),
              Dimens.space(2),
              Expanded(
                child: state is ActivitiesLoaded
                    ? const ContributionsSection()
                    : Center(
                        child: CircularProgressIndicator(),
                      ),
              )
            ],
          );
        },
      ),
    );
  }
}

class NotificationAppBar extends StatelessWidget {
  const NotificationAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return StyledAppBar(
      suffix: context.userProfile!.notificationsCount == 0
          ? null
          : CircleAvatar(
              radius: 8,
              backgroundColor: AppColors.red500,
              child: Text(
                context.userProfile!.notificationsCount.toString(),
                style: Typo.smallBody.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
      title: 'Activities',
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
    final contributions =
        (context.read<ActivitiesBloc>().state as ActivitiesLoaded).activities;
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
          : Column(
              children: contributions.map((activity) {
                return ContributionItem(
                  showDivider: contributions.last != activity,
                  type: activity.type.toLowerCase() == "space"
                      ? ContributionType.space
                      : ContributionType.event,
                  activity: activity,
                );
              }).toList(),
            ),
    );
  }
}
