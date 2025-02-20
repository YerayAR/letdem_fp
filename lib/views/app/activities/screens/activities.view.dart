import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:letdem/constants/ui/dimens.dart';
import 'package:letdem/features/activities/activities_bloc.dart';
import 'package:letdem/features/car/car_bloc.dart';
import 'package:letdem/global/widgets/appbar.dart';
import 'package:letdem/global/widgets/body.dart'; // Ensure these imports are correct
import 'package:letdem/views/app/activities/widgets/contribution_item.widget.dart';
import 'package:letdem/views/app/activities/widgets/no_car_registered.widget.dart';
import 'package:letdem/views/app/activities/widgets/no_contribution.widget.dart';
import 'package:letdem/views/app/activities/widgets/registered_car.widget.dart';
import 'package:letdem/views/app/profile/widgets/profile_section.widget.dart';
import 'package:shimmer/shimmer.dart';

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
              const StyledAppBar(
                title: 'Activities',
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
                  padding:
                      state is ActivitiesLoaded && state.activities.isNotEmpty
                          ? const EdgeInsets.only(top: 20)
                          : const EdgeInsets.symmetric(vertical: 20),
                  title: "Contributions",
                  callToAction:
                      state is ActivitiesLoaded && state.activities.isNotEmpty
                          ? "See all"
                          : null,
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
                          child: state is ActivitiesLoaded
                              ? Center(
                                  child: state.activities.isEmpty
                                      ? const NoContributionsWidget()
                                      : ListView(
                                          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          // crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            for (var activity
                                                in state.activities)
                                              ContributionItem(
                                                showDivider: state.activities
                                                        .indexOf(activity) !=
                                                    state.activities.length - 1,
                                                type: activity.type
                                                            .toLowerCase() ==
                                                        "space"
                                                    ? ContributionType.space
                                                    : ContributionType.event,
                                                activity: activity,
                                              ),
                                          ],
                                        ),
                                )
                              : ListView(
                                  // spacing: 20,
                                  children: List.generate(
                                      7,
                                      (index) => Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 7),
                                            child: Row(
                                              children: [
                                                // circle avatar shimmer
                                                ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          1500),
                                                  child: SizedBox(
                                                    height: 50.0,
                                                    width: 50.0,
                                                    child: Shimmer.fromColors(
                                                      baseColor: Colors
                                                          .grey[200]!
                                                          .withOpacity(0.2),
                                                      highlightColor:
                                                          Colors.grey[50]!,
                                                      child: Container(
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Dimens.space(1),
                                                Expanded(
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15),
                                                    child: SizedBox(
                                                      height: 50.0,
                                                      child: Shimmer.fromColors(
                                                        baseColor: Colors
                                                            .grey[200]!
                                                            .withOpacity(0.2),
                                                        highlightColor:
                                                            Colors.grey[50]!,
                                                        child: Container(
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )))),
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
