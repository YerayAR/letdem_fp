import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:iconsax/iconsax.dart';
import 'package:letdem/constants/ui/assets.dart';
import 'package:letdem/constants/ui/colors.dart';
import 'package:letdem/constants/ui/dimens.dart';
import 'package:letdem/constants/ui/typo.dart';
import 'package:letdem/global/widgets/body.dart';
import 'package:letdem/global/widgets/button.dart';
import 'package:letdem/global/widgets/chip.dart';
import 'package:letdem/global/widgets/textfield.dart';
import 'package:letdem/services/res/navigator.dart';
import 'package:letdem/views/auth/views/register.view.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(Dimens.defaultMargin),
          child: PrimaryButton(
            outline: true,
            onTap: () {},
            color: Colors.white,
            widgetImage: SvgPicture.asset(AppAssets.google),
            textColor: Color(0xFF344054),
            borderColor: AppColors.neutral50,
            text: 'Sign in with Google',
          ),
        ),
      ),
      body: ListView(
        children: [
          StyledBody(
            children: [
              // custom app bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  DecoratedChip(
                    backgroundColor: AppColors.secondary50,
                    text: 'LOGIN TO YOUR ACCOUNT',
                    color: AppColors.secondary600,
                  ),
                  IconButton(
                    icon: Icon(Iconsax.close_circle5),
                    color: AppColors.neutral100,
                    onPressed: () {
                      NavigatorHelper.pop();
                    },
                  ),
                ],
              ),
              Dimens.space(3),
              Text(
                'Welcome Back!',
                style: Typo.heading4.copyWith(color: AppColors.neutral600),
              ),
              Dimens.space(1),
              Text.rich(
                TextSpan(
                  text:
                      'Don\'t have an account? ', // Default style for this text
                  style: Typo.largeBody.copyWith(),
                  children: [
                    TextSpan(
                      text: 'Sign Up here',
                      style: Typo.largeBody.copyWith(
                        color: AppColors.primary400,
                        decoration: TextDecoration.underline,
                        decorationColor: AppColors.primary400,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          NavigatorHelper.pop();
                          NavigatorHelper.to(RegisterView());
                        },
                    ),
                  ],
                ),
              ),
              Dimens.space(5),
              const TextInputField(
                prefixIcon: Iconsax.sms,
                label: 'Email Address',
                placeHolder: 'Enter your email address',
              ),
              Dimens.space(1),
              const TextInputField(
                prefixIcon: Iconsax.lock,
                label: 'Password',
                inputType: TextFieldType.password,
                placeHolder: 'Enter your password',
              ),
              Dimens.space(2),
              PrimaryButton(
                onTap: () {},
                text: 'Login',
              ),
              Dimens.space(2),
              Center(
                child: Text.rich(
                  TextSpan(
                    text: 'Forgot Password? ', // Default style for this text
                    style: Typo.largeBody.copyWith(),
                    children: [
                      TextSpan(
                        text: ' Reset here', // Styled differently
                        style: Typo.largeBody.copyWith(
                          color: AppColors.primary400,
                          decoration: TextDecoration.underline,
                          decorationColor: AppColors.primary400,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            // NavigatorHelper.to(LoginView());
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
  }
}
