import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:iconsax/iconsax.dart';
import 'package:letdem/constants/ui/assets.dart';
import 'package:letdem/constants/ui/colors.dart';
import 'package:letdem/constants/ui/dimens.dart';
import 'package:letdem/constants/ui/typo.dart';
import 'package:letdem/features/auth/auth_bloc.dart';
import 'package:letdem/global/widgets/body.dart';
import 'package:letdem/global/widgets/button.dart';
import 'package:letdem/global/widgets/chip.dart';
import 'package:letdem/global/widgets/textfield.dart';
import 'package:letdem/services/res/navigator.dart';
import 'package:letdem/services/toast/toast.dart';
import 'package:letdem/views/auth/views/login.view.dart';
import 'package:letdem/views/auth/views/onboard/basic_info.view.dart';
import 'package:letdem/views/auth/views/onboard/verify_account.view.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
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
    return Scaffold(
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(Dimens.defaultMargin),
          child: PrimaryButton(
            outline: true,
            onTap: () {
              context.read<AuthBloc>().add(const GoogleRegisterEvent());
            },
            color: Colors.white,
            widgetImage: SvgPicture.asset(AppAssets.google),
            textColor: const Color(0xFF344054),
            borderColor: AppColors.neutral50,
            text: 'Sign up with Google',
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
            if (state is OTPVerificationSuccess) {
              NavigatorHelper.to(const BasicInfoView());
              return;
            }
            if (state is ResendVerificationCodeError) {
              Toast.showError("Unable to resend verification code");
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
                    // custom app bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        DecoratedChip(
                          backgroundColor: AppColors.secondary50,
                          text: 'CREATE NEW ACCOUNT',
                          color: AppColors.secondary600,
                        ),
                        SizedBox(
                          // check if a screen behind is exist

                          child: Navigator.canPop(context)
                              ? IconButton(
                                  icon: const Icon(Iconsax.close_circle5),
                                  color: AppColors.neutral100,
                                  onPressed: () {
                                    NavigatorHelper.pop();
                                  },
                                )
                              : null,
                        ),
                      ],
                    ),
                    Dimens.space(3),
                    Text(
                      'Get Started',
                      style:
                          Typo.heading4.copyWith(color: AppColors.neutral600),
                    ),
                    Dimens.space(1),
                    Text.rich(
                      TextSpan(
                        text: 'Already have an account? ',
                        // Default style for this text
                        style: Typo.largeBody.copyWith(),
                        children: [
                          TextSpan(
                            text: 'Login here',
                            style: Typo.largeBody.copyWith(
                              color: AppColors.primary400,
                              decoration: TextDecoration.underline,
                              decorationColor: AppColors.primary400,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                NavigatorHelper.replaceAll(const LoginView());
                                // NavigatorHelper.to(RegisterView());
                              },
                          ),
                        ],
                      ),
                    ),
                    Dimens.space(5),
                    TextInputField(
                      prefixIcon: Iconsax.sms,
                      label: 'Email Address',
                      placeHolder: 'Enter your email address',
                      controller: _emailCTRL,
                    ),
                    Dimens.space(1),
                    TextInputField(
                      prefixIcon: Iconsax.lock,
                      label: 'Password',
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
                    Dimens.space(2),
                    PrimaryButton(
                      isLoading: state is RegisterLoading,
                      onTap: () {
                        if (_formKey.currentState!.validate()) {
                          if (_passwordCTRL.text != _repeatPasswordCTRL.text) {
                            Toast.showError('Passwords do not match');
                            return;
                          }
                          if (_passwordCTRL.text.length < 8) {
                            Toast.showError(
                                'Password must be at least 8 characters');
                            return;
                          }
                          print(_repeatPasswordCTRL.text);
                          if (!RegExp(r'[!@#<>?":_`~;[\]\\|=+)(*&^%]')
                              .hasMatch(_repeatPasswordCTRL.text)) {
                            Toast.showError(
                                'Password must contain at least one special character');
                            return;
                          }

                          context.read<AuthBloc>().add(RegisterEvent(
                              email: _emailCTRL.text,
                              password: _passwordCTRL.text));
                        }
                      },
                      text: 'Register',
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
