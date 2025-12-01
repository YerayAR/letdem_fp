import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconly/iconly.dart';
import 'package:iconsax/iconsax.dart';
import 'package:letdem/common/popups/popup.dart';
import 'package:letdem/common/widgets/body.dart';
import 'package:letdem/common/widgets/button.dart';
import 'package:letdem/common/widgets/chip.dart';
import 'package:letdem/core/constants/colors.dart';
import 'package:letdem/core/constants/dimens.dart';
import 'package:letdem/core/constants/typo.dart';
import 'package:letdem/core/enums/EarningStatus.dart';
import 'package:letdem/core/extensions/locale.dart';
import 'package:letdem/features/activities/presentation/views/view_all.view.dart';
import 'package:letdem/features/auth/presentation/views/login.view.dart';
import 'package:letdem/features/car/car_bloc.dart';
import 'package:letdem/features/notifications/presentation/views/notification.view.dart';
import 'package:letdem/features/payment_methods/presentation/views/payment_methods.view.dart';
import 'package:letdem/features/track_location/mock/mock_data.dart';
import 'package:letdem/features/users/models/user.model.dart';
import 'package:letdem/features/users/presentation/views/edit/edit_basic_info.view.dart';
import 'package:letdem/features/users/presentation/views/help/help.view.dart';
import 'package:letdem/features/users/presentation/views/language/change_language.view.dart';
import 'package:letdem/features/users/presentation/views/preferences/preferences.view.dart';
import 'package:letdem/features/users/presentation/widgets/profile_menu_item.widget.dart';
import 'package:letdem/features/users/user_bloc.dart';
import 'package:letdem/features/wallet/presentation/views/wallet.view.dart';
import 'package:letdem/infrastructure/services/earnings/eranings.service.dart';
import 'package:letdem/infrastructure/services/res/navigator.dart';
import 'package:letdem/models/earnings_account/earning_account.model.dart';

import '../../../../common/widgets/appbar.dart';
import '../../../marketplace/presentation/pages/start/marketplace_start.page.dart';
import '../../../scheduled_notifications/presentation/views/scheduled_notifications.view.dart';
import '../../../track_location/view/track_location_view.dart';
import 'reservations/reservation_list.view.dart';
import 'security/security.view.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xffF5F5F5),
      child: RefreshIndicator(
        onRefresh: () async {
          context.read<UserBloc>().add(FetchUserInfoEvent());
          context.read<CarBloc>().add(const GetCarEvent());
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
                      padding: const EdgeInsets.only(bottom: 20),
                      children: [
                        _ProfileHeader(user: state.user),
                        const SizedBox(height: 8),
                        _MenuGridSection(user: state.user),
                        const SizedBox(height: 16),
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
    return StyledAppBar(
      onTap: () => NavigatorHelper.to(const NotificationsView()),
      title: context.l10n.profile,
      suffix:
          context.watch<UserBloc>().state is! UserLoaded
              ? null
              : context.watch<UserBloc>().state is UserLoaded &&
                  (context.watch<UserBloc>().state as UserLoaded)
                          .unreadNotificationsCount ==
                      0
              ? null
              : CircleAvatar(
                radius: 8,
                backgroundColor: AppColors.red500,
                child: Text(
                  '${(context.watch<UserBloc>().state as UserLoaded).unreadNotificationsCount}',
                  style: Typo.smallBody.copyWith(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.neutral200.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: _buildUserInfo(user, fullName, context)),
            _buildUserPoints(user, context),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfo(
    LetDemUser user,
    String fullName,
    BuildContext context,
  ) {
    return GestureDetector(
      onTap:
          kDebugMode
              ? () {
                NavigatorHelper.to(
                  TrackLocationView(
                    payload: MockTrackLocationData.createDummyPayload(),
                    spaceId: '2',
                  ),
                );
              }
              : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            fullName.isEmpty ? context.l10n.nameNotProvided : fullName,
            style: Typo.largeBody.copyWith(fontWeight: FontWeight.w700),
          ),
          Text(
            user.email,
            style: Typo.mediumBody.copyWith(color: AppColors.neutral400),
          ),
        ],
      ),
    );
  }

  Widget _buildUserPoints(LetDemUser user, BuildContext context) {
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
              text: '${user.totalPoints}\n${context.l10n.letdemPoints}',
              backgroundColor: AppColors.secondary600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuGridSection extends StatelessWidget {
  final LetDemUser user;

  const _MenuGridSection({required this.user});

  @override
  Widget build(BuildContext context) {
    final earningAccount = user.earningAccount;
    final status = earningAccount?.status;
    final isAccepted = status == EarningStatus.accepted;

    final menuItems = [
      _MenuItem(
        icon: IconlyLight.star,
        text: context.l10n.contributions,
        color: AppColors.secondary500,
        onTap: () => NavigatorHelper.to(const ViewAllView()),
      ),
      _MenuItem(
        icon: IconlyLight.bag_2,
        text: 'Marketplace',
        color: AppColors.primary500,
        onTap: () => NavigatorHelper.to(const MarketplaceStartView()),
      ),
      _MenuItem(
        icon: IconlyLight.time_circle,
        text: context.l10n.scheduledNotifications,
        color: AppColors.purple600,
        onTap: () => NavigatorHelper.to(const ScheduledNotificationsView()),
      ),
      _MenuItem(
        icon: Iconsax.card,
        text: context.l10n.paymentMethods,
        color: AppColors.green600,
        onTap: () => NavigatorHelper.to(const PaymentMethodsScreen()),
      ),
      _MenuItem(
        icon: IconlyLight.shield_done,
        text: context.l10n.reservations,
        color: AppColors.red500,
        onTap: () => NavigatorHelper.to(ReservationHistory()),
      ),
      _MenuItem(
        icon: IconlyLight.wallet,
        text: context.l10n.earnings,
        color: AppColors.secondary600,
        badge: isAccepted ? null : _buildEarningsBadge(context, earningAccount),
        onTap: () {
          EarningAccountService.handleEarningAccountTap(
            context: context,
            earningAccount: earningAccount,
            onSuccess: () => NavigatorHelper.to(const WalletScreen()),
          );
        },
      ),
      _MenuItem(
        icon: IconlyLight.user,
        text: context.l10n.basicInformation,
        color: AppColors.neutral600,
        onTap: () => NavigatorHelper.to(const EditBasicInfoView()),
      ),
      _MenuItem(
        icon: IconlyLight.filter,
        text: context.l10n.preferences,
        color: AppColors.primary400,
        onTap: () => NavigatorHelper.to(const PreferencesView()),
      ),
      _MenuItem(
        icon: Iconsax.global,
        text: context.l10n.language,
        color: AppColors.green500,
        onTap: () => NavigatorHelper.to(const ChangeLanguageView()),
      ),
      _MenuItem(
        icon: IconlyLight.lock,
        text: context.l10n.security,
        color: AppColors.red600,
        onTap: () => NavigatorHelper.to(const SecurityView()),
      ),
      _MenuItem(
        icon: IconlyLight.info_circle,
        text: context.l10n.help,
        color: AppColors.neutral500,
        onTap: () => NavigatorHelper.to(const HelpScreenView()),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 1.1,
        ),
        itemCount: menuItems.length,
        itemBuilder: (context, index) {
          final item = menuItems[index];
          return ProfileMenuItem(
            icon: item.icon,
            text: item.text,
            onTap: item.onTap,
            iconColor: item.color,
            badge: item.badge,
            index: index,
          );
        },
      ),
    );
  }

  Widget? _buildEarningsBadge(BuildContext context, EarningAccount? account) {
    final color = account == null
        ? AppColors.green600
        : account.status == EarningStatus.missingInfo
            ? Colors.red
            : AppColors.red500;

    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 1.5),
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String text;
  final Color color;
  final VoidCallback onTap;
  final Widget? badge;

  _MenuItem({
    required this.icon,
    required this.text,
    required this.color,
    required this.onTap,
    this.badge,
  });
}

class _LogoutButton extends StatelessWidget {
  const _LogoutButton();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        AppPopup.showDialogSheet(
          context,
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                context.l10n.logout,
                style: Typo.largeBody.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 23,
                ),
                textAlign: TextAlign.center,
              ),
              Dimens.space(1),
              Text(
                context.l10n.logoutConfirmation,
                style: Typo.mediumBody,
                textAlign: TextAlign.center,
              ),
              Dimens.space(3),
              Row(
                children: [
                  Flexible(
                    child: PrimaryButton(
                      color: AppColors.red500,
                      onTap: () {
                        BlocProvider.of<CarBloc>(
                          context,
                        ).add(const ClearCarEvent());
                        BlocProvider.of<UserBloc>(
                          context,
                        ).add(UserLoggedOutEvent());
                      },
                      text: context.l10n.yes,
                    ),
                  ),
                  Dimens.space(1),
                  Flexible(
                    child: PrimaryButton(
                      outline: true,
                      onTap: () {
                        NavigatorHelper.pop();
                      },
                      text: context.l10n.cancel,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(CupertinoIcons.power, color: AppColors.primary500, size: 23),
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
