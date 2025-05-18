import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconly/iconly.dart';
import 'package:iconsax/iconsax.dart';
import 'package:letdem/constants/ui/colors.dart';
import 'package:letdem/constants/ui/dimens.dart';
import 'package:letdem/constants/ui/typo.dart';
import 'package:letdem/extenstions/locale.dart';
import 'package:letdem/extenstions/user.dart';
import 'package:letdem/features/users/repository/user.repository.dart';
import 'package:letdem/features/users/user_bloc.dart';
import 'package:letdem/global/popups/popup.dart';
import 'package:letdem/global/widgets/appbar.dart';
import 'package:letdem/global/widgets/body.dart';
import 'package:letdem/global/widgets/chip.dart';
import 'package:letdem/services/res/navigator.dart';
import 'package:letdem/views/app/activities/screens/view_all.view.dart';
import 'package:letdem/views/app/notifications/views/notification.view.dart';
import 'package:letdem/views/app/payment_method/screens/payment_methods.view.dart';
import 'package:letdem/views/app/profile/popups/connect_account/money_laundry.popup.dart';
import 'package:letdem/views/app/profile/screens/connect_account/connect_account.view.dart';
import 'package:letdem/views/app/profile/screens/edit/edit_basic_info.view.dart';
import 'package:letdem/views/app/profile/screens/language/change_language.view.dart';
import 'package:letdem/views/app/profile/screens/security/security.view.dart';
import 'package:letdem/views/app/profile/widgets/profile_section.widget.dart';
import 'package:letdem/views/app/profile/widgets/settings_container.widget.dart';
import 'package:letdem/views/app/profile/widgets/settings_row.widget.dart';
import 'package:letdem/views/app/wallet/screens/wallet.view.dart';
import 'package:letdem/views/auth/views/login.view.dart';

import 'screens/preferences/preferences.view.dart';
import 'screens/scheduled_notifications/scheduled_notifications.view.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xffF5F5F5),
      child: RefreshIndicator(
        onRefresh: () async {
          context.read<UserBloc>().add(FetchUserInfoEvent());
        },
        child: StyledBody(
          isBottomPadding: false,
          children: [
            StyledAppBar(
              onTap: () {
                NavigatorHelper.to(const NotificationsView());
              },
              title: context.l10n.profile,
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
                      )),
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
                                        bottom: -17,
                                        child: DecoratedChip(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 4,
                                          ),
                                          textStyle: Typo.smallBody.copyWith(
                                            color: Colors.white,
                                            fontSize: 8,
                                            fontWeight: FontWeight.w800,
                                          ),
                                          text:
                                              '${state.user.totalPoints}\nLetDem Points',
                                          color: Colors.white,
                                          backgroundColor:
                                              AppColors.secondary600,
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
                                text: context.l10n.contributions,
                                onTap: () {
                                  NavigatorHelper.to(const ViewAllView());
                                },
                              ),
                              SettingsRow(
                                icon: IconlyLight.time_circle,
                                text: context.l10n.scheduledNotifications,
                                onTap: () {
                                  NavigatorHelper.to(
                                      const ScheduledNotificationsView());
                                },
                              ),
                              SettingsRow(
                                icon: Iconsax.card,
                                text: context.l10n.paymentMethods,
                                onTap: () {
                                  NavigatorHelper.to(PaymentMethodsScreen());
                                },
                              ),
                              SettingsRow(
                                leading: context.userProfile!.earningAccount !=
                                            null &&
                                        context.userProfile!.earningAccount!
                                                .status ==
                                            EarningStatus.accepted
                                    ? null
                                    : DecoratedChip(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 4,
                                        ),
                                        backgroundColor: context.userProfile!
                                                    .earningAccount ==
                                                null
                                            ? AppColors.green600
                                            : context
                                                        .userProfile!
                                                        .earningAccount!
                                                        .status ==
                                                    EarningStatus.missingInfo
                                                ? Colors.red
                                                : AppColors.red500,
                                        textStyle: Typo.smallBody.copyWith(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w800,
                                        ),
                                        text: context.userProfile!
                                                    .earningAccount ==
                                                null
                                            ? context.l10n.connectAccount
                                            : getStatusString(context
                                                .userProfile!
                                                .earningAccount!
                                                .status),
                                        color: context.userProfile!
                                                    .earningAccount ==
                                                null
                                            ? AppColors.green600
                                            : context
                                                        .userProfile!
                                                        .earningAccount!
                                                        .status ==
                                                    EarningStatus.missingInfo
                                                ? Colors.red
                                                : AppColors.red500,
                                      ),
                                icon: IconlyLight.wallet,
                                text: context.l10n.earnings,
                                showDivider: false,
                                onTap: () {
                                  if (context.userProfile!.earningAccount !=
                                          null &&
                                      context.userProfile!.earningAccount!
                                              .status ==
                                          EarningStatus.accepted) {
                                    NavigatorHelper.to(const WalletScreen());
                                    return;
                                  }

                                  if (context.userProfile!.earningAccount ==
                                      null) {
                                    AppPopup.showBottomSheet(context,
                                        MoneyLaundryPopup(
                                      onContinue: () {
                                        NavigatorHelper.to(ProfileOnboardingApp(
                                          remainingStep: context.userProfile!
                                              .earningAccount?.step,
                                          status: context.userProfile!
                                              .earningAccount?.status,
                                        ));
                                      },
                                    ));
                                  } else {
                                    NavigatorHelper.to(ProfileOnboardingApp(
                                      remainingStep: context
                                          .userProfile!.earningAccount!.step,
                                      status: context
                                          .userProfile!.earningAccount!.status,
                                    ));
                                  }
                                },
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
                                  text: context.l10n.basicInformation,
                                  onTap: () {
                                    NavigatorHelper.to(EditBasicInfoView());
                                  },
                                ),
                                SettingsRow(
                                  icon: IconlyLight.filter,
                                  text: context.l10n.preferences,
                                  onTap: () {
                                    NavigatorHelper.to(const PreferencesView());
                                  },
                                ),
                                // language
                                SettingsRow(
                                  icon: Iconsax.global,
                                  text: "Language",
                                  onTap: () {
                                    NavigatorHelper.to(ChangeLanguageView());
                                  },
                                ),
                                SettingsRow(
                                  icon: IconlyLight.lock,
                                  text: context.l10n.security,
                                  showDivider: false,
                                  onTap: () {
                                    NavigatorHelper.to(const SecurityView());
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
                                context.l10n.logout,
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
      ),
    );
  }
}
