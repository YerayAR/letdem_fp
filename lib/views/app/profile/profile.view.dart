import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:letdem/constants/ui/colors.dart';
import 'package:letdem/constants/ui/dimens.dart';
import 'package:letdem/constants/ui/typo.dart';
import 'package:letdem/global/widgets/appbar.dart';
import 'package:letdem/global/widgets/body.dart';
import 'package:letdem/global/widgets/chip.dart';
import 'package:letdem/views/app/profile/widgets/profile_section.widget.dart';
import 'package:letdem/views/app/profile/widgets/settings_container.widget.dart';
import 'package:letdem/views/app/profile/widgets/settings_row.widget.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xffF5F5F5),
      child: StyledBody(
        children: [
          const StyledAppBar(
            title: 'Profile',
            icon: Iconsax.notification5,
          ),
          Expanded(
            child: ListView(children: <Widget>[
              ProfileSection(
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
              ProfileSection(
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
              ProfileSection(
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
