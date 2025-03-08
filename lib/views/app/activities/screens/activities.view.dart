import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:letdem/extenstions/user.dart';
import 'package:letdem/features/activities/activities_bloc.dart';
import 'package:letdem/features/car/car_bloc.dart';
import 'package:letdem/global/widgets/appbar.dart';
import 'package:letdem/global/widgets/body.dart'; // Ensure these imports are correct
import 'package:letdem/services/res/navigator.dart';
import 'package:letdem/views/app/activities/screens/view_all.view.dart';
import 'package:letdem/views/app/activities/widgets/contribution_item.widget.dart';
import 'package:letdem/views/app/activities/widgets/no_car_registered.widget.dart';
import 'package:letdem/views/app/activities/widgets/no_contribution.widget.dart';
import 'package:letdem/views/app/activities/widgets/registered_car.widget.dart';
import 'package:letdem/views/app/notifications/views/notification.view.dart';
import 'package:letdem/views/app/profile/widgets/profile_section.widget.dart';

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

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xffF5F5F5),
      child: BlocConsumer<ActivitiesBloc, ActivitiesState>(
        listener: (context, state) {
          // TODO: implement listener
        },
        builder: (context, state) {
          return StyledBody(
            isBottomPadding: false,
            children: [
              StyledAppBar(
                title: 'Activities',
                onTap: () {
                  NavigatorHelper.to(NotificationsView());
                },
                icon: Iconsax.notification5,
              ),

              BlocConsumer<CarBloc, CarState>(
                listener: (context, state) {
                  // TODO: implement listener
                },
                builder: (context, state) {
                  if (state is CarLoaded) {
                    return ProfileSection(
                      child: [
                        state.car != null
                            ? RegisteredCarWidget(
                                car: state.car!,
                              )
                            : const NoCarRegisteredWidget(),
                      ],
                    );
                  }
                  return const ProfileSection(
                    child: [
                      NoCarRegisteredWidget(),
                    ],
                  );
                },
              ),
              // AccountSection(
              //   child: [
              Expanded(
                child: ProfileSection(
                  onCallToAction: () {
                    NavigatorHelper.to(ViewAllView());
                  },
                  padding:
                      state is ActivitiesLoaded && state.activities.isNotEmpty
                          ? const EdgeInsets.only(top: 20)
                          : const EdgeInsets.symmetric(vertical: 20),
                  title: "Contributions",
                  callToAction: "See all",
                  child: [
                    Expanded(
                      child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.only(
                            top: 25,
                            bottom: state is ActivitiesLoaded &&
                                    state.activities.isNotEmpty
                                ? 0
                                : 25,
                            left: 25,
                            right: 25,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: state is ActivitiesLoaded &&
                                    state.activities.isNotEmpty
                                ? const BorderRadius.only(
                                    topLeft: Radius.circular(20),
                                    topRight: Radius.circular(20),
                                  )
                                : const BorderRadius.only(
                                    topLeft: Radius.circular(20),
                                    topRight: Radius.circular(20),
                                    bottomLeft: Radius.circular(20),
                                    bottomRight: Radius.circular(20),
                                  ),
                          ),
                          child: Center(
                            child: context.userProfile != null &&
                                    context.userProfile!.contributions.isEmpty
                                ? const NoContributionsWidget()
                                : ListView(
                                    // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    // crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      for (var activity in context
                                              .userProfile?.contributions ??
                                          [])
                                        ContributionItem(
                                          showDivider: context
                                                  .userProfile!.contributions
                                                  .indexOf(activity) !=
                                              context.userProfile!.contributions
                                                      .length -
                                                  1,
                                          type: activity.type.toLowerCase() ==
                                                  "space"
                                              ? ContributionType.space
                                              : ContributionType.event,
                                          activity: activity,
                                        ),
                                    ],
                                  ),
                          )),
                    ),
                  ],
                ),
              ),
            ],

            // ),
            // ],
          );
        },
      ),
    );
  }
}
