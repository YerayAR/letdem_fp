import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:letdem/constants/ui/colors.dart';
import 'package:letdem/constants/ui/dimens.dart';
import 'package:letdem/constants/ui/typo.dart';
import 'package:letdem/extenstions/user.dart';
import 'package:letdem/features/users/user_bloc.dart';
import 'package:letdem/global/popups/popup.dart';
import 'package:letdem/global/widgets/appbar.dart';
import 'package:letdem/global/widgets/body.dart';
import 'package:letdem/global/widgets/button.dart';
import 'package:letdem/services/res/navigator.dart';
import 'package:letdem/views/app/profile/screens/security/change_password.view.dart';
import 'package:letdem/views/app/profile/widgets/profile_section.widget.dart';
import 'package:letdem/views/app/profile/widgets/settings_container.widget.dart';
import 'package:letdem/views/app/profile/widgets/settings_row.widget.dart';

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
            title: 'Security Settings',
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
                              text: 'Change Password',
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
                    text: 'Delete Account',
                    textColor: AppColors.red500,
                    onTap: () {
                      AppPopup.showDialogSheet(
                          context,
                          Column(children: <Widget>[
                            Text(
                              'Delete Account',
                              style: Typo.heading1.copyWith(
                                fontSize: 24,
                              ),
                            ),
                            Text(
                              'Are you sure you want to delete your account? This action cannot be undone.',
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
                                    text: 'Cancel',
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
                                    text: 'Delete',
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
