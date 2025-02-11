import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:letdem/constants/ui/colors.dart';
import 'package:letdem/constants/ui/dimens.dart';
import 'package:letdem/constants/ui/typo.dart';
import 'package:letdem/features/auth/auth_bloc.dart';
import 'package:letdem/global/widgets/body.dart';
import 'package:letdem/global/widgets/button.dart';
import 'package:letdem/global/widgets/textfield.dart';
import 'package:letdem/services/res/navigator.dart';
import 'package:letdem/services/toast/toast.dart';
import 'package:letdem/views/auth/views/onboard/verify_account.view.dart';

class ResetPasswordView extends StatefulWidget {
  const ResetPasswordView({super.key});

  @override
  State<ResetPasswordView> createState() => _ResetPasswordViewState();
}

class _ResetPasswordViewState extends State<ResetPasswordView> {
  late TextEditingController _emailCTRL;
  late TextEditingController _passwordCTRL;
  late TextEditingController _repeatPasswordCTRL;

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    _emailCTRL = TextEditingController();
    _passwordCTRL = TextEditingController();
    _repeatPasswordCTRL = TextEditingController();

    super.initState();
  }

  @override
  void dispose() {
    _emailCTRL.dispose();
    _passwordCTRL.dispose();
    _repeatPasswordCTRL.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(Dimens.defaultMargin),
          child: PrimaryButton(
            onTap: () {},
            text: 'Reset Password',
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is RegisterError) {
              Toast.showError(state.error);
              return;
            }
            if (state is RegisterSuccess) {
              NavigatorHelper.to(VerifyAccountView(
                email: _emailCTRL.text,
              ));
            }
            // TODO: implement listener
          },
          builder: (context, state) {
            return ListView(
              children: [
                StyledBody(
                  children: [
                    Dimens.space(3),
                    Text(
                      'Set a New Password',
                      style:
                          Typo.heading4.copyWith(color: AppColors.neutral600),
                    ),
                    Dimens.space(1),
                    Text('Create a strong password for your account',
                        style: Typo.mediumBody
                            .copyWith(color: AppColors.neutral500)),
                    Dimens.space(5),
                    TextInputField(
                      prefixIcon: Iconsax.lock,
                      label: 'New Password',
                      controller: _passwordCTRL,
                      inputType: TextFieldType.password,
                      showPasswordStrengthIndicator: true,
                      placeHolder: 'Enter your password',
                    ),
                    Dimens.space(1),
                    TextInputField(
                      prefixIcon: Iconsax.lock,
                      controller: _repeatPasswordCTRL,
                      label: 'Repeat Password',
                      showPasswordStrengthIndicator: true,
                      inputType: TextFieldType.password,
                      placeHolder: 'Enter your password',
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
