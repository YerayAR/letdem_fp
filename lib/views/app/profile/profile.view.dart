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
            _ProfileAppBar(),
            BlocConsumer<UserBloc, UserState>(
              listener: _userBlocListener,
              builder: (context, state) {
                if (state is UserLoaded) {
                  return Expanded(
                    child: ListView(
                      children: [
                        _ProfileHeader(user: state.user),
                        _MainActionsSection(user: state.user),
                        _AccountSettingsSection(),
                        const _LogoutButton(),
                      ],
                    ),
                  );
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ],
        ),
      ),
    );
  }

  void _userBlocListener(BuildContext context, UserState state) {
    if (state is UserLoggedOutState) {
      NavigatorHelper.popAll();
      NavigatorHelper.replaceAll(const LoginView());
    }
    if (state is UserInfoChanged) {
      context.read<UserBloc>().add(FetchUserInfoEvent());
    }
  }
}

class _ProfileAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final notificationCount = context.userProfile?.notificationsCount ?? 0;
    return StyledAppBar(
      onTap: () => NavigatorHelper.to(const NotificationsView()),
      title: context.l10n.profile,
      suffix: notificationCount == 0
          ? null
          : CircleAvatar(
              radius: 8,
              backgroundColor: AppColors.red500,
              child: Text(
                '$notificationCount',
                style: Typo.smallBody.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              )),
      icon: Iconsax.notification5,
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final LetDemUser user;

  const _ProfileHeader({required this.user});

  @override
  Widget build(BuildContext context) {
    final fullName = '${user.firstName} ${user.lastName}'.trim();
    return ProfileSection(
      child: [
        SettingsContainer(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildUserInfo(user, fullName),
              _buildUserPoints(user),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUserInfo(LetDemUser user, String fullName) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          fullName.isEmpty ? "Name not provided" : fullName,
          style: Typo.largeBody.copyWith(fontWeight: FontWeight.w700),
        ),
        Text(
          user.email,
          style: Typo.mediumBody.copyWith(color: AppColors.neutral400),
        ),
      ],
    );
  }

  Widget _buildUserPoints(LetDemUser user) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          CircleAvatar(
            radius: 27,
            backgroundColor: AppColors.secondary50,
            child: Icon(Iconsax.cup5, color: AppColors.secondary500, size: 27),
          ),
          Positioned(
            bottom: -17,
            child: DecoratedChip(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              textStyle: Typo.smallBody.copyWith(
                color: Colors.white,
                fontSize: 8,
                fontWeight: FontWeight.w800,
              ),
              text: '${user.totalPoints}\nLetDem Points',
              backgroundColor: AppColors.secondary600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _MainActionsSection extends StatelessWidget {
  final LetDemUser user;

  const _MainActionsSection({required this.user});

  @override
  Widget build(BuildContext context) {
    return ProfileSection(
      child: [
        SettingsContainer(
          child: Column(
            children: [
              _settingsRow(context.l10n.contributions, IconlyLight.star, () {
                NavigatorHelper.to(const ViewAllView());
              }),
              _settingsRow(
                  context.l10n.scheduledNotifications, IconlyLight.time_circle,
                  () {
                NavigatorHelper.to(const ScheduledNotificationsView());
              }),
              _settingsRow(context.l10n.paymentMethods, Iconsax.card, () {
                NavigatorHelper.to(const PaymentMethodsScreen());
              }),
              _buildEarningsRow(context, user),
            ],
          ),
        )
      ],
    );
  }

  Widget _settingsRow(String text, IconData icon, VoidCallback onTap) {
    return SettingsRow(icon: icon, text: text, onTap: onTap);
  }

  Widget _buildEarningsRow(BuildContext context, LetDemUser user) {
    final earningAccount = user.earningAccount;
    final status = earningAccount?.status;
    final isAccepted = status == EarningStatus.accepted;

    return SettingsRow(
      icon: IconlyLight.wallet,
      text: context.l10n.earnings,
      showDivider: false,
      leading: isAccepted ? null : _statusChip(context, earningAccount),
      onTap: () {
        if (isAccepted) {
          NavigatorHelper.to(const WalletScreen());
        } else {
          AppPopup.showBottomSheet(
            context,
            MoneyLaundryPopup(onContinue: () {
              NavigatorHelper.to(ProfileOnboardingApp(
                remainingStep: earningAccount?.step,
                status: status,
              ));
            }),
          );
        }
      },
    );
  }

  Widget _statusChip(BuildContext context, EarningAccount? account) {
    final color = account == null
        ? AppColors.green600
        : account.status == EarningStatus.missingInfo
            ? Colors.red
            : AppColors.red500;
    final text = account == null
        ? context.l10n.connectAccount
        : getStatusString(account.status);
    return DecoratedChip(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      backgroundColor: color,
      textStyle: Typo.smallBody.copyWith(
        color: Colors.white,
        fontSize: 11,
        fontWeight: FontWeight.w800,
      ),
      text: text,
      color: color,
    );
  }
}

class _AccountSettingsSection extends StatelessWidget {
  const _AccountSettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ProfileSection(
      child: [
        SettingsContainer(
          child: Column(
            children: [
              SettingsRow(
                icon: IconlyLight.user,
                text: context.l10n.basicInformation,
                onTap: () {
                  NavigatorHelper.to(const EditBasicInfoView());
                },
              ),
              SettingsRow(
                icon: IconlyLight.filter,
                text: context.l10n.preferences,
                onTap: () {
                  NavigatorHelper.to(const PreferencesView());
                },
              ),
              SettingsRow(
                icon: Iconsax.global,
                text: "Language", // Or: context.l10n.language if localized
                onTap: () {
                  NavigatorHelper.to(const ChangeLanguageView());
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
    );
  }
}

class _LogoutButton extends StatelessWidget {
  const _LogoutButton({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        BlocProvider.of<UserBloc>(context).add(UserLoggedOutEvent());
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
    );
  }
}
