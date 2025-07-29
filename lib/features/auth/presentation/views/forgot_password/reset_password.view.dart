import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:letdem/common/widgets/body.dart';
import 'package:letdem/common/widgets/button.dart';
import 'package:letdem/common/widgets/textfield.dart';
import 'package:letdem/core/constants/colors.dart';
import 'package:letdem/core/constants/dimens.dart';
import 'package:letdem/core/constants/typo.dart';
import 'package:letdem/core/extensions/locale.dart';
import 'package:letdem/features/auth/auth_bloc.dart';
import 'package:letdem/features/auth/presentation/views/login.view.dart';
import 'package:letdem/infrastructure/services/res/navigator.dart';
import 'package:letdem/infrastructure/toast/toast/toast.dart';

class ResetPasswordView extends StatefulWidget {
  final String email;
  const ResetPasswordView({super.key, required this.email});

  @override
  State<ResetPasswordView> createState() => _ResetPasswordViewState();
}

class _ResetPasswordViewState extends State<ResetPasswordView> {
  late TextEditingController _emailCTRL;
  late TextEditingController _passwordCTRL;
  late TextEditingController _repeatPasswordCTRL;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

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
    return BlocConsumer<AuthBloc, AuthState>(listener: (context, state) {
      if (state is ResetPasswordError) {
        Toast.showError(state.error);
        return;
      }
      if (state is ResetPasswordSuccess) {
        NavigatorHelper.popAll();
        // NavigatorHelper.replaceAll(const LoginView());
      }
    }, builder: (context, snapshot) {
      return GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        behavior: HitTestBehavior.opaque,
        child: Scaffold(
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: EdgeInsets.all(Dimens.defaultMargin),
              child: PrimaryButton(
                isLoading: snapshot is ResetPasswordLoading,
                onTap: () {
                  if (_formKey.currentState!.validate()) {
                    if (_passwordCTRL.text != _repeatPasswordCTRL.text) {
                      Toast.showError(context.l10n.passwordsDoNotMatch);
                      return;
                    }

                    context.read<AuthBloc>().add(ResetPasswordEvent(
                        email: widget.email, password: _passwordCTRL.text));
                  }
                },
                text: context.l10n.resetPassword,
              ),
            ),
          ),
          body: Form(
            key: _formKey,
            child: BlocConsumer<AuthBloc, AuthState>(
              listener: (context, state) {
                if (state is ResetPasswordError) {
                  Toast.showError(state.error);
                  return;
                }
                if (state is ResetPasswordSuccess) {
                  NavigatorHelper.popAll();
                  NavigatorHelper.replaceAll(const LoginView());
                }
              },
              builder: (context, state) {
                return ListView(
                  children: [
                    StyledBody(
                      children: [
                        Dimens.space(3),
                        Text(
                          context.l10n.setNewPassword,
                          style: Typo.heading4
                              .copyWith(color: AppColors.neutral600),
                        ),
                        Dimens.space(1),
                        Text(
                          context.l10n.createStrongPassword,
                          style: Typo.mediumBody
                              .copyWith(color: AppColors.neutral500),
                        ),
                        Dimens.space(5),
                        TextInputField(
                          prefixIcon: Iconsax.lock,
                          label: context.l10n.newPassword,
                          controller: _passwordCTRL,
                          inputType: TextFieldType.password,
                          showPasswordStrengthIndicator: true,
                          placeHolder: context.l10n.enterPassword,
                        ),
                        Dimens.space(1),
                        TextInputField(
                          prefixIcon: Iconsax.lock,
                          controller: _repeatPasswordCTRL,
                          label: context.l10n.repeatPassword,
                          showPasswordStrengthIndicator: true,
                          inputType: TextFieldType.password,
                          placeHolder: context.l10n.enterPassword,
                        ),
                        Dimens.space(2),
                        Text(
                          context.l10n.passwordRequirements,
                          style: Typo.smallBody.copyWith(
                            color: AppColors.neutral400,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );
    });
  }
}
