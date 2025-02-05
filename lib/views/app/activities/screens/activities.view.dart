import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:letdem/global/widgets/body.dart'; // Ensure these imports are correct
import 'package:letdem/views/app/activities/widgets/contribution_item.widget.dart';
import 'package:letdem/views/app/activities/widgets/no_contribution.widget.dart';
import 'package:letdem/views/app/activities/widgets/registered_car.widget.dart';
import 'package:letdem/views/app/profile/profile.view.dart';

enum ContributionType {
  space,
  event,
}

class ActivitiesView extends StatelessWidget {
  const ActivitiesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xffF5F5F5),
      child: StyledBody(
        isBottomPadding: false,
        children: [
          const StyledAppBar(
            title: 'Activities',
            icon: Iconsax.notification5,
          ),

          const AccountSection(
            child: [
              RegisteredCarWidget(),
            ],
          ),
          // AccountSection(
          //   child: [
          Expanded(
            child: AccountSection(
              title: "Contributions",
              callToAction: "See all",
              child: [
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.only(
                      top: 25,
                      bottom: 25,
                      left: 25,
                      right: 25,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: false
                          ? NoContributionsWidget()
                          : ListView(
                              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              // crossAxisAlignment: CrossAxisAlignment.center,
                              children: true
                                  ? [
                                      const ContributionItem(
                                          type: ContributionType.space),
                                      const ContributionItem(
                                          type: ContributionType.space),
                                      const ContributionItem(
                                          type: ContributionType.event),
                                      const ContributionItem(
                                          type: ContributionType.event),
                                      const ContributionItem(
                                          type: ContributionType.event),
                                      const ContributionItem(
                                        type: ContributionType.space,
                                        showDivider: false,
                                      ),

                                      // ContributionItem(),
                                      // ContributionItem(),
                                      // ContributionItem(),
                                      // ContributionItem(),
                                      // ContributionItem(),
                                    ]
                                  : [
                                      // NoContributionsWidget()
                                    ],
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        // ),
        // ],
      ),
    );
  }
}
