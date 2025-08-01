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
import 'package:letdem/features/users/user_bloc.dart';
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
  }

  Widget _buildFooter(ActivitiesState state, bool isAllRouted) {
    Widget item = ContributionsSection(
      isAllRouted: isAllRouted,
    );

    return item;
  }

  Widget _buidShowAllButton(ActivitiesState state) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
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
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<ActivitiesBloc, ActivitiesState>(
        listener: (context, state) {},
        builder: (context, state) {
          // loading state
          if (state is ActivitiesLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (context.watch<UserBloc>().state is UserLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (context.watch<CarBloc>().state is CarLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          var w = StyledBody(
            isBottomPadding: false,
            children: context.watch<UserBloc>().state is UserLoaded &&
                    (context.watch<UserBloc>().state as UserLoaded)
                            .user
                            .activeReservation !=
                        null
                ? [
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () async {
                          context.read<ActivitiesBloc>().add(
                                GetActivitiesEvent(),
                              );
                          context.read<UserBloc>().add(FetchUserInfoEvent());
                          context.read<CarBloc>().add(const GetCarEvent());
                        },
                        child: ListView(
                          children: [
                            const NotificationAppBar(),
                            const CarSection(),
                            const ActiveReservationSection(),
                            _buidShowAllButton(state),
                            _buildFooter(state, true),
                          ],
                        ),
                      ),
                    ),
                  ]
                : [
                    const NotificationAppBar(),
                    const CarSection(),
                    const ActiveReservationSection(),
                    _buidShowAllButton(state),
                    Expanded(child: _buildFooter(state, false)),
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

    return StyledAppBar(
      suffix: context.watch<UserBloc>().state is! UserLoaded
          ? null
          : context.watch<UserBloc>().state is UserLoaded &&
                  (context.watch<UserBloc>().state as UserLoaded)
                          .unreadNotificationsCount ==
                      0
              ? null
              : CircleAvatar(
                  radius: 8,
                  backgroundColor: AppColors.red500,
                  child: Text(
                    '${(context.watch<UserBloc>().state as UserLoaded).unreadNotificationsCount}',
                    style: Typo.smallBody.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  )),
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
      listener: (context, state) {
        //   load user if car loaded
        // if (state is CarLoaded && state.car != null) {
        //   // context.read<ActivitiesBloc>().add(
        //   //       GetActivitiesEvent(),
        //   //     );
        //   context.read<UserBloc>().add(FetchUserInfoEvent());
        // }
      },
      builder: (context, state) {
        if (state is CarLoaded && state.car != null) {
          return ProfileSection(
            child: [
              RegisteredCarWidget(car: state.car!),
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
    return context.watch<UserBloc>().state is UserLoaded &&
            (context.watch<UserBloc>().state as UserLoaded)
                    .user
                    .activeReservation !=
                null
        ? ActiveReservationView(
            payload: (context.watch<UserBloc>().state as UserLoaded)
                .user
                .activeReservation!)
        : const SizedBox.shrink();
  }
}

class ContributionsSection extends StatelessWidget {
  final bool isAllRouted;
  const ContributionsSection({super.key, required this.isAllRouted});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ActivitiesBloc, ActivitiesState>(
      builder: (context, state) {
        final contributions = context.userProfile == null
            ? []
            : context.userProfile!.contributions;
        final isEmpty = contributions.isEmpty;

        return Container(
          margin: const EdgeInsets.only(top: 5),
          // height: context.userProfile?.activeReservation != null ? 400 : null,
          height: context.watch<UserBloc>().state is UserLoaded &&
                  (context.watch<UserBloc>().state as UserLoaded)
                          .user
                          .activeReservation !=
                      null
              ? 400
              : null,
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
              bottomLeft: isAllRouted
                  ? Radius.circular(Dimens.defaultRadius)
                  : Radius.zero,
              bottomRight: isAllRouted
                  ? Radius.circular(Dimens.defaultRadius)
                  : Radius.zero,
            ),
          ),
          child: isEmpty
              ? const NoContributionsWidget()
              : ListView(
                  // Fix: Prevent overflow in column
                  // mainAxisSize: MainAxisSize.min,
                  children: [
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
