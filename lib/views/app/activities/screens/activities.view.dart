import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:iconly/iconly.dart';
import 'package:iconsax/iconsax.dart';
import 'package:letdem/constants/ui/assets.dart';
import 'package:letdem/constants/ui/colors.dart';
import 'package:letdem/constants/ui/dimens.dart';
import 'package:letdem/constants/ui/typo.dart';
import 'package:letdem/global/widgets/body.dart'; // Ensure these imports are correct
import 'package:letdem/global/widgets/button.dart';
import 'package:letdem/global/widgets/chip.dart';
import 'package:letdem/views/app/profile/profile.view.dart';

class RegisteredCarWidget extends StatelessWidget {
  const RegisteredCarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: 0,
        horizontal: 0,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary400,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Padding(
            padding: const EdgeInsets.all(25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Your Car Details
                Text(
                  "Your Car Details",
                  style: Typo.smallBody.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Dimens.space(1),
                //   Mercedes Benz E350
                Text(
                  "Mercedes Benz E350",
                  style: Typo.largeBody.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 19),
                ),
                Dimens.space(1),

                Row(
                  spacing: 8,
                  children: <Widget>[
                    Text("Year: 2024",
                        style: Typo.largeBody.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        )),
                    CircleAvatar(
                      radius: 3,
                      backgroundColor: AppColors.primary200,
                    ),
                    Text("Tag: Eco",
                        style: Typo.largeBody.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        )),
                  ],
                ),
                Dimens.space(2),

                DecoratedChip(
                  backgroundColor: AppColors.primary600,
                  text: 'Edit Details',
                  padding: const EdgeInsets.symmetric(
                    vertical: 5,
                    horizontal: 10,
                  ),
                  textSize: 14,
                  color: Colors.white,
                ),
              ],
            ),
          ),
          Positioned(
            right: 0,
            child: SvgPicture.asset(
              AppAssets.eclipse,
              width: 130,
              height: 130,
            ),
          ),
          Positioned(
            right: 0,
            top: 10,
            child: SvgPicture.asset(
              AppAssets.car,
              width: 160,
              height: 160,
            ),
          ),
        ],
      ),
    );
  }
}

enum ContributionType {
  space,
  event,
}

class ContributionItem extends StatelessWidget {
  final ContributionType type;

  final bool showDivider;
  const ContributionItem(
      {super.key, required this.type, this.showDivider = true});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: <Widget>[
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: type == ContributionType.space
                        ? AppColors.primary50.withOpacity(0.5)
                        : AppColors.green50,
                    child: Icon(
                      type == ContributionType.space
                          ? Iconsax.location5
                          : IconlyBold.star,
                      color: type == ContributionType.space
                          ? AppColors.primary400
                          : AppColors.green600,
                    ),
                  ),
                  Dimens.space(2),
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Space Published",
                          style: Typo.largeBody.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Dimens.space(1),
                        Row(
                          spacing: 5,
                          children: [
                            Text(
                              "12 Jan. 2025",
                              style: Typo.mediumBody.copyWith(
                                color: AppColors.neutral400,
                              ),
                            ),
                            CircleAvatar(
                              radius: 3,
                              backgroundColor: AppColors.neutral200,
                            ),
                            Text(
                              "12:00 PM",
                              style: Typo.mediumBody.copyWith(
                                color: AppColors.neutral400,
                              ),
                            ),
                          ],
                        ),
                      ]),
                ],
              ),
              DecoratedChip(
                backgroundColor: AppColors.secondary50,
                text: '+2 Pts',
                icon: Iconsax.cup5,
                color: AppColors.secondary600,
              ),
            ],
          ),
          Column(
            children: !showDivider
                ? []
                : [
                    Dimens.space(1),
                    Divider(
                      color: AppColors.neutral50,
                      thickness: 1,
                    ),
                  ],
          ),
        ],
      ),
    );
  }
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
              // SettingsContainer(
              //   child: Column(
              //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //     children: [
              //       Column(
              //         crossAxisAlignment: CrossAxisAlignment.center,
              //         children: [
              //           Text(
              //             "No Car Registered",
              //             style: Typo.largeBody.copyWith(
              //               fontWeight: FontWeight.w700,
              //             ),
              //           ),
              //           Dimens.space(2),
              //           Text(
              //             "Register your car with the car details\nfor safety and accessibility",
              //             style: Typo.mediumBody
              //                 .copyWith(color: AppColors.neutral400),
              //             textAlign: TextAlign.center,
              //           ),
              //           Dimens.space(2),
              //           Center(
              //               child: Text(
              //             "Tap to Register Car",
              //             style: Typo.mediumBody.copyWith(
              //               color: AppColors.primary400,
              //               fontWeight: FontWeight.w500,
              //               decoration: TextDecoration.underline,
              //             ),
              //           ))
              //         ],
              //       ),
              //     ],
              //   ),
              // ),
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
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Spacer(),
                                Text(
                                  "No Contributions Yet",
                                  style: Typo.largeBody.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Dimens.space(2),
                                Text(
                                  "Your Contributions history will appear\nhere, Publish to see them",
                                  style: Typo.mediumBody
                                      .copyWith(color: AppColors.neutral400),
                                  textAlign: TextAlign.center,
                                ),
                                Dimens.space(2),
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width / 1.9,
                                  child: PrimaryButton(
                                    onTap: () {},
                                    icon: Iconsax.location5,
                                    text: 'Publish Space',
                                  ),
                                ),
                                Dimens.space(1),
                                Center(
                                    child: Text(
                                  "Publish an event",
                                  style: Typo.mediumBody.copyWith(
                                    color: AppColors.primary400,
                                    fontWeight: FontWeight.w500,
                                    decoration: TextDecoration.underline,
                                  ),
                                )),
                                const Spacer(),
                              ],
                            )
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
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            "No Contributions Yet",
                                            style: Typo.largeBody.copyWith(
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          Dimens.space(2),
                                          Text(
                                            "Your Contributions history will appear\nhere, Publish to see them",
                                            style: Typo.mediumBody.copyWith(
                                                color: AppColors.neutral400),
                                            textAlign: TextAlign.center,
                                          ),
                                          Dimens.space(2),
                                          SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                1.9,
                                            child: PrimaryButton(
                                              onTap: () {},
                                              icon: Iconsax.location5,
                                              text: 'Publish Space',
                                            ),
                                          ),
                                          Dimens.space(1),
                                          Center(
                                              child: Text(
                                            "Publish an event",
                                            style: Typo.mediumBody.copyWith(
                                              color: AppColors.primary400,
                                              fontWeight: FontWeight.w500,
                                              decoration:
                                                  TextDecoration.underline,
                                            ),
                                          ))
                                        ],
                                      ),
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
