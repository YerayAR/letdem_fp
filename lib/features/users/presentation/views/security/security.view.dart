import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:letdem/common/popups/popup.dart';
import 'package:letdem/common/widgets/appbar.dart';
import 'package:letdem/common/widgets/body.dart';
import 'package:letdem/common/widgets/button.dart';
import 'package:letdem/core/constants/colors.dart';
import 'package:letdem/core/constants/dimens.dart';
import 'package:letdem/core/constants/typo.dart';
import 'package:letdem/core/extensions/locale.dart';
import 'package:letdem/core/extensions/user.dart';
import 'package:letdem/features/users/presentation/views/security/change_password.view.dart';
import 'package:letdem/features/users/presentation/widgets/profile_section.widget.dart';
import 'package:letdem/features/users/presentation/widgets/settings_container.widget.dart';
import 'package:letdem/features/users/presentation/widgets/settings_row.widget.dart';
import 'package:letdem/features/users/user_bloc.dart';
import 'package:letdem/infrastructure/services/res/navigator.dart';

class SecurityView extends StatelessWidget {
  const SecurityView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StyledBody(
        children: [
          StyledAppBar(
            onTap: () {
              NavigatorHelper.pop();
            },
            title: context.l10n.securitySettings,
            icon: Icons.close,
          ),
          ProfileSection(
            child: [
              SizedBox(
                child: context.userProfile!.isSocial
                    ? null
                    : SettingsContainer(
                        child: Column(
                          children: [
                            SettingsRow(
                              text: context.l10n.changePassword,
                              onTap: () {
                                NavigatorHelper.to(const ChangePasswordView());
                              },
                              showDivider: false,
                            ),
                          ],
                        ),
                      ),
              ),
              Dimens.space(2),
              BlocConsumer<UserBloc, UserState>(
                listener: (context, state) {
                  // TODO: implement listener
                },
                builder: (context, state) {
                  return PrimaryButton(
                    color: AppColors.red50,
                    text: context.l10n.deleteAccount,
                    textColor: AppColors.red500,
                    onTap: () {
                      AppPopup.showDialogSheet(
                          context,
                          Column(children: <Widget>[
                            Text(
                              context.l10n.deleteAccount,
                              style: Typo.heading1.copyWith(
                                fontSize: 24,
                              ),
                            ),
                            Text(
                              context.l10n.deleteAccountConfirmation,
                              style: Typo.mediumBody
                                  .copyWith(color: AppColors.neutral400),
                              textAlign: TextAlign.center,
                            ),
                            Dimens.space(2),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: PrimaryButton(
                                    text: context.l10n.cancel,
                                    color: AppColors.red500,
                                    borderColor: AppColors.red500,
                                    outline: true,
                                    onTap: () {
                                      NavigatorHelper.pop();
                                    },
                                  ),
                                ),
                                Dimens.space(1),
                                Flexible(
                                  child: PrimaryButton(
                                    text: context.l10n.delete,
                                    isLoading: state is UserLoading,
                                    color: AppColors.red500,
                                    onTap: () {
                                      context
                                          .read<UserBloc>()
                                          .add(DeleteAccountEvent());
                                      // Perform delete account logic here
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ]));

                      // Perform logout logic here
                    },
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
