import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:letdem/constants/ui/colors.dart';
import 'package:letdem/constants/ui/dimens.dart';
import 'package:letdem/constants/ui/typo.dart';
import 'package:letdem/global/widgets/body.dart';
import 'package:letdem/global/widgets/chip.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xffF5F5F5),
      child: StyledBody(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Profile',
                style: Typo.heading4,
              ),
              CircleAvatar(
                radius: 23,
                backgroundColor: AppColors.neutral50,
                child: Icon(
                  Iconsax.notification5,
                  color: AppColors.neutral500,
                ),
              ),
            ],
          ),
          Expanded(
            child: ListView(children: <Widget>[
              AccountSection(
                child: [
                  SettingsContainer(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Abubakar Sadeeq Ismail",
                                style: Typo.largeBody.copyWith(
                                  fontWeight: FontWeight.w700,
                                )),
                            Text(
                              "mistallogik@gmail.com",
                              style: Typo.mediumBody.copyWith(
                                color: AppColors.neutral400,
                              ),
                            )
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Stack(
                            alignment: Alignment.center,
                            clipBehavior: Clip.none,
                            children: [
                              CircleAvatar(
                                radius: 27,
                                backgroundColor: AppColors.secondary50,
                                child: Icon(
                                  Iconsax.cup5,
                                  color: AppColors.secondary500,
                                  size: 27,
                                ),
                              ),
                              Positioned(
                                bottom: -13,
                                child: DecoratedChip(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  textStyle: Typo.smallBody.copyWith(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                  ),
                                  text: '2.8k Points',
                                  color: Colors.white,
                                  backgroundColor: AppColors.secondary600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
              AccountSection(
                title: "Account Settings",
                child: [
                  SettingsContainer(
                      child: Column(
                    children: [
                      SettingsRow(
                        text: 'Basic Information',
                        onTap: () {},
                      ),
                      SettingsRow(
                        text: 'Change Password',
                        onTap: () {},
                      ),
                      SettingsRow(
                        showDivider: false,
                        text: 'Contributions',
                        onTap: () {},
                      ),
                    ],
                  ))
                ],
              ),
              AccountSection(
                title: "Other Settings",
                child: [
                  SettingsContainer(
                    child: Column(
                      children: [
                        SettingsRow(
                          text: 'Notifications',
                          onTap: () {},
                        ),
                        SettingsRow(
                          text: 'Preferences',
                          onTap: () {},
                        ),
                        SettingsRow(
                          text: 'About us',
                          onTap: () {},
                        ),
                        SettingsRow(
                          text: 'Privacy Policy',
                          onTap: () {},
                        ),
                        SettingsRow(
                          text: 'Terms of use',
                          onTap: () {},
                        ),
                        SettingsRow(
                          showDivider: false,
                          text: 'Help',
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Iconsax.logout_1,
                        color: AppColors.red500,
                      ),
                      Dimens.space(1),
                      Text(
                        'Log out',
                        style: Typo.largeBody.copyWith(
                          color: AppColors.red500,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}

class AccountSection extends StatelessWidget {
  final List<SettingsContainer> child;
  final String? title;
  const AccountSection({super.key, required this.child, this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null)
            Column(
              children: [
                Text(
                  title!,
                  style: Typo.largeBody.copyWith(fontWeight: FontWeight.w700),
                ),
                Dimens.space(2),
              ],
            ),
          ...child,
        ],
      ),
    );
  }
}

class SettingsContainer extends StatelessWidget {
  final Widget child;
  const SettingsContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: 25,
        horizontal: 25,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: child,
    );
  }
}

class SettingsRow extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final bool showDivider;
  const SettingsRow(
      {super.key, required this.text, this.onTap, this.showDivider = true});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  text,
                  style: Typo.mediumBody.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.neutral600,
                  ),
                ),
                Icon(
                  Iconsax.arrow_right_3,
                  color: AppColors.neutral300,
                ),
              ],
            ),
          ),
        ),
        if (showDivider)
          Container(
            height: 1,
            color: AppColors.neutral50,
          ),
      ],
    );
  }
}
