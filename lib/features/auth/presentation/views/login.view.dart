import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:iconsax/iconsax.dart';
import 'package:letdem/common/widgets/body.dart';
import 'package:letdem/common/widgets/button.dart';
import 'package:letdem/common/widgets/chip.dart';
import 'package:letdem/common/widgets/textfield.dart';
import 'package:letdem/core/constants/assets.dart';
import 'package:letdem/core/constants/colors.dart';
import 'package:letdem/core/constants/dimens.dart';
import 'package:letdem/core/constants/typo.dart';
import 'package:letdem/core/extensions/locale.dart';
import 'package:letdem/features/auth/auth_bloc.dart';
import 'package:letdem/features/auth/presentation/views/forgot_password/request_forgot_password.view.dart';
import 'package:letdem/features/auth/presentation/views/onboard/register.view.dart';
import 'package:letdem/features/auth/presentation/views/onboard/splash.view.dart';
import 'package:letdem/infrastructure/services/res/navigator.dart';
import 'package:letdem/infrastructure/toast/toast/toast.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late TextEditingController _emailCTRL;
  late TextEditingController _passwordCTRL;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    _emailCTRL = TextEditingController();
    _passwordCTRL = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _emailCTRL.dispose();
    _passwordCTRL.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              outline: true,
              onTap: () {
                context.read<AuthBloc>().add(const GoogleLoginEvent());
              },
              color: Colors.white,
              widgetImage: SvgPicture.asset(AppAssets.google),
              textColor: const Color(0xFF344054),
              borderColor: AppColors.neutral50,
              text: context.l10n.singInWithGoogle,
            ),
          ),
        ),
        body: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is LoginError) {
              Toast.showError(state.error);
            }
            if (state is LoginSuccess) {
              NavigatorHelper.popAll();
            NavigatorHelper.replaceAll(const SplashView());
            }
            // TODO: implement listener
          },
          builder: (context, state) {
            return Form(
              key: _formKey,
              child: ListView(
                children: [
                  StyledBody(
                    children: [
                      // custom app bar
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          DecoratedChip(
                            backgroundColor: AppColors.secondary50,
                            text: context.l10n.loginToAccount,
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
                        context.l10n.welcomeBack,
                        style:
                            Typo.heading4.copyWith(color: AppColors.neutral600),
                      ),
                      Dimens.space(1),
                      Text.rich(
                        TextSpan(
                          text: context.l10n.dontHaveAccount,
                          style: Typo.largeBody.copyWith(),
                          children: [
                            TextSpan(
                              text: context.l10n.signUpHere,
                              style: Typo.largeBody.copyWith(
                                color: AppColors.primary400,
                                decoration: TextDecoration.underline,
                                decorationColor: AppColors.primary400,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  NavigatorHelper.replaceAll(
                                      const RegisterView());
                                },
                            ),
                          ],
                        ),
                      ),
                      Dimens.space(5),
                      TextInputField(
                        prefixIcon: Iconsax.sms,
                        controller: _emailCTRL,
                        inputType: TextFieldType.email,
                        label: context.l10n.emailAddress,
                        placeHolder: context.l10n.enterEmailAddress,
                      ),
                      Dimens.space(1),
                      TextInputField(
                        prefixIcon: Iconsax.lock,
                        controller: _passwordCTRL,
                        label: context.l10n.password,
                        inputType: TextFieldType.password,
                        placeHolder: context.l10n.enterPassword,
                      ),
                      Dimens.space(2),
                      PrimaryButton(
                        isLoading: state is LoginLoading,
                        onTap: () {
                          if (_formKey.currentState!.validate()) {
                            context.read<AuthBloc>().add(LoginEvent(
                                email: _emailCTRL.text,
                                password: _passwordCTRL.text));
                          }
                        },
                        text: context.l10n.login,
                      ),
                      Dimens.space(2),
                      Center(
                        child: Text.rich(
                          TextSpan(
                            text: context.l10n.forgotPasswordQuestion,
                            // Default style for this text
                            style: Typo.largeBody.copyWith(),
                            children: [
                              TextSpan(
                                text: context.l10n.resetHere,
                                style: Typo.largeBody.copyWith(
                                  color: AppColors.primary400,
                                  decoration: TextDecoration.underline,
                                  decorationColor: AppColors.primary400,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    NavigatorHelper.to(
                                        const RequestForgotPasswordView());
                                  },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
