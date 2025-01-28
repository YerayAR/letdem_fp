import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:letdem/constants/ui/colors.dart';
import 'package:letdem/constants/ui/dimens.dart';
import 'package:letdem/constants/ui/typo.dart';
import 'package:letdem/global/widgets/body.dart'; // Ensure these imports are correct
import 'package:letdem/global/widgets/button.dart';
import 'package:letdem/views/app/profile/profile.view.dart';

class ActivitiesView extends StatelessWidget {
  const ActivitiesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xffF5F5F5),
      child: StyledBody(
        isBottomPadding: true,
        children: [
          StyledAppBar(
            title: 'Activities',
            icon: Iconsax.notification5,
          ),

          AccountSection(
            child: [
              SettingsContainer(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "No Car Registered",
                          style: Typo.largeBody.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Dimens.space(2),
                        Text(
                          "Register your car with the car details\nfor safety and accessibility",
                          style: Typo.mediumBody
                              .copyWith(color: AppColors.neutral400),
                          textAlign: TextAlign.center,
                        ),
                        Dimens.space(2),
                        Center(
                            child: Text(
                          "Tap to Register Car",
                          style: Typo.mediumBody.copyWith(
                            color: AppColors.primary400,
                            fontWeight: FontWeight.w500,
                            decoration: TextDecoration.underline,
                          ),
                        ))
                      ],
                    ),
                  ],
                ),
              ),
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
                    padding: const EdgeInsets.symmetric(
                      vertical: 25,
                      horizontal: 25,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Spacer(),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
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
                                style: Typo.mediumBody
                                    .copyWith(color: AppColors.neutral400),
                                textAlign: TextAlign.center,
                              ),
                              Dimens.space(2),
                              SizedBox(
                                width: MediaQuery.of(context).size.width / 1.9,
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
                              ))
                            ],
                          ),
                          Spacer(),
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
