import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:letdem/constants/ui/dimens.dart';
import 'package:letdem/features/users/user_bloc.dart';
import 'package:letdem/global/popups/popup.dart';
import 'package:letdem/global/widgets/appbar.dart';
import 'package:letdem/global/widgets/body.dart';
import 'package:letdem/global/widgets/button.dart';
import 'package:letdem/global/widgets/textfield.dart';
import 'package:letdem/services/res/navigator.dart';
import 'package:letdem/services/toast/toast.dart';
import 'package:letdem/views/auth/views/onboard/verify_account.view.dart';

class ChangePasswordView extends StatefulWidget {
  const ChangePasswordView({super.key});

  @override
  State<ChangePasswordView> createState() => _ChangePasswordViewState();
}

class _ChangePasswordViewState extends State<ChangePasswordView> {
  late TextEditingController _oldPasswordCTRL;
  late TextEditingController _newPasswordCTRL;
  late TextEditingController _confirmPasswordCTRL;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    _oldPasswordCTRL = TextEditingController();
    _newPasswordCTRL = TextEditingController();
    _confirmPasswordCTRL = TextEditingController();

    super.initState();
  }

  @override
  void dispose() {
    _oldPasswordCTRL.dispose();
    _newPasswordCTRL.dispose();
    _confirmPasswordCTRL.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UserBloc, UserState>(
      listener: (context, state) {
        if (state is UserInfoChanged) {
          AppPopup.showDialogSheet(
            context,
            SuccessDialog(
              title: 'Account password changed successfully',
              onProceed: () {
                context.read<UserBloc>().add(UserLoggedOutEvent());
                NavigatorHelper.pop();
              },
              subtext:
                  'Your password has been changed successfully, you can now to login with the new password',
              buttonText: 'Proceed to login',
            ),
          );
        }
        // TODO: implement listener
      },
      builder: (context, state) {
        return Scaffold(
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: EdgeInsets.all(Dimens.defaultMargin),
              child: PrimaryButton(
                isLoading: state is UserLoaded && state.isUpdateLoading,
                onTap: () {
                  if (_newPasswordCTRL.text != _confirmPasswordCTRL.text) {
                    Toast.showError("Passwords do not match");
                    return;
                  }
                  if (!_formKey.currentState!.validate()) {
                    return;
                  }
                  context.read<UserBloc>().add(
                        ChangePasswordEvent(
                          oldPassword: _oldPasswordCTRL.text,
                          newPassword: _newPasswordCTRL.text,
                        ),
                      );
                },
                text: 'Change Password',
              ),
            ),
          ),
          body: Form(
            key: _formKey,
            child: ListView(
              children: [
                StyledBody(
                  children: [
                    // custom app bar
                    StyledAppBar(
                      title: 'Change Password',
                      onTap: () {
                        NavigatorHelper.pop();
                      },
                      icon: Icons.close,
                    ),

                    Dimens.space(5),
                    TextInputField(
                      prefixIcon: Iconsax.sms,
                      controller: _oldPasswordCTRL,
                      inputType: TextFieldType.password,
                      label: 'Old Password',
                      placeHolder: 'Enter your old password',
                    ),
                    Dimens.space(1),
                    TextInputField(
                      prefixIcon: Iconsax.lock,
                      controller: _newPasswordCTRL,
                      label: 'New Password',
                      showPasswordStrengthIndicator: true,
                      inputType: TextFieldType.password,
                      placeHolder: 'Enter your new password',
                    ),
                    Dimens.space(1),
                    TextInputField(
                      prefixIcon: Iconsax.lock,
                      controller: _confirmPasswordCTRL,
                      showPasswordStrengthIndicator: true,
                      label: 'Confirm Password',
                      inputType: TextFieldType.password,
                      placeHolder: 'Confirm your new password',
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
