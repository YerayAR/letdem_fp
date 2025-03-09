import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconly/iconly.dart';
import 'package:iconsax/iconsax.dart';
import 'package:letdem/constants/ui/colors.dart';
import 'package:letdem/constants/ui/dimens.dart';
import 'package:letdem/constants/ui/typo.dart';
import 'package:letdem/features/users/user_bloc.dart';
import 'package:letdem/global/widgets/appbar.dart';
import 'package:letdem/global/widgets/body.dart';
import 'package:letdem/global/widgets/chip.dart';
import 'package:letdem/services/res/navigator.dart';
import 'package:letdem/views/app/activities/screens/view_all.view.dart';
import 'package:letdem/views/app/notifications/views/notification.view.dart';
import 'package:letdem/views/app/profile/screens/security/security.view.dart';
import 'package:letdem/views/app/profile/widgets/profile_section.widget.dart';
import 'package:letdem/views/app/profile/widgets/settings_container.widget.dart';
import 'package:letdem/views/app/profile/widgets/settings_row.widget.dart';
import 'package:letdem/views/auth/views/login.view.dart';

import 'screens/preferences/preferences.view.dart';
import 'screens/scheduled_notifications/scheduled_notifications.view.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xffF5F5F5),
      child: StyledBody(
        children: [
          StyledAppBar(
            onTap: () {
              NavigatorHelper.to(NotificationsView());
            },
            title: 'Profile',
            icon: Iconsax.notification5,
          ),
          BlocConsumer<UserBloc, UserState>(
            listener: (context, state) {
              if (state is UserLoggedOutState) {
                NavigatorHelper.popAll();
                NavigatorHelper.replaceAll(const LoginView());
              }
              if (state is UserInfoChanged) {
                context.read<UserBloc>().add(FetchUserInfoEvent());
              }
              // TODO: implement listener
            },
            builder: (context, state) {
              if (state is UserLoaded) {
                return Expanded(
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
                                  Text(
                                      state.user.firstName.isEmpty &&
                                              state.user.lastName.isEmpty
                                          ? ""
                                              "Name not provided"
                                          : "${state.user.firstName} ${state.user.lastName}",
                                      style: Typo.largeBody.copyWith(
                                        fontWeight: FontWeight.w700,
                                      )),
                                  Text(
                                    state.user.email,
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
                                        text:
                                            '${state.user.totalPoints} Points',
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
                      child: [
                        SettingsContainer(
                            child: Column(
                          children: [
                            SettingsRow(
                              icon: IconlyLight.star,
                              text: 'Contributions',
                              onTap: () {
                                NavigatorHelper.to(ViewAllView());
                              },
                            ),
                            SettingsRow(
                              icon: IconlyLight.time_circle,
                              text: 'Scheduled Notifications',
                              onTap: () {
                                NavigatorHelper.to(
                                    ScheduledNotificationsView());
                              },
                            ),
                            SettingsRow(
                              icon: Iconsax.card,
                              text: 'Payment methods',
                              onTap: () {},
                            ),
                            SettingsRow(
                              icon: IconlyLight.wallet,
                              text: 'Wallet',
                              showDivider: false,
                              onTap: () {},
                            ),
                          ],
                        ))
                      ],
                    ),
                    ProfileSection(
                      child: [
                        SettingsContainer(
                          child: Column(
                            children: [
                              SettingsRow(
                                icon: IconlyLight.user,
                                text: 'Basic Information',
                                onTap: () {},
                              ),
                              SettingsRow(
                                icon: IconlyLight.filter,
                                text: 'Preferences',
                                onTap: () {
                                  NavigatorHelper.to(PreferencesView());
                                },
                              ),
                              SettingsRow(
                                icon: IconlyLight.lock,
                                text: 'Security',
                                showDivider: false,
                                onTap: () {
                                  NavigatorHelper.to(SecurityView());
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    InkWell(
                      onTap: () {
                        BlocProvider.of<UserBloc>(context)
                            .add(UserLoggedOutEvent());
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              CupertinoIcons.power,
                              color: AppColors.primary500,
                              size: 23,
                            ),
                            Dimens.space(1),
                            Text(
                              'Log out',
                              style: Typo.largeBody.copyWith(
                                color: AppColors.primary500,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ]),
                );
              }
              return const Center(
                child: CircularProgressIndicator(),
              );
            },
          ),
        ],
      ),
    );
  }
}
