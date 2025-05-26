import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:letdem/common/widgets/button.dart';
import 'package:letdem/core/constants/assets.dart';
import 'package:letdem/core/constants/colors.dart';
import 'package:letdem/core/constants/dimens.dart';
import 'package:letdem/core/constants/typo.dart';
import 'package:letdem/features/auth/presentation/views/login.view.dart';
import 'package:letdem/infrastructure/services/res/navigator.dart';

import '../../../features/auth/presentation/views/onboard/register.view.dart';

class WelcomeView extends StatelessWidget {
  const WelcomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AppAssets.welcome),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(Dimens.defaultMargin * 2),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'Find & Share Parking Spaces near you',
                textAlign: TextAlign.center,
                style: Typo.heading3.copyWith(
                  color: Colors.white,
                ),
              ),
              Dimens.space(1),
              Text(
                'Get access to wide range of parking spaces within your location and beyond',
                textAlign: TextAlign.center,
                style: Typo.largeBody.copyWith(
                  color: AppColors.neutral300,
                ),
              ),
              Dimens.space(3),
              PrimaryButton(
                onTap: () {
                  NavigatorHelper.to(const RegisterView());
                },
                iconRight: Icons.arrow_forward,
                text: 'Get Started',
              ),
              Dimens.space(2),
              Text.rich(
                TextSpan(
                  text: 'Already a user? ', // Default style for this text
                  style: Typo.largeBody.copyWith(
                    color: AppColors.neutral300,
                  ),
                  children: [
                    TextSpan(
                      text: 'Login here', // Styled differently
                      style: Typo.largeBody.copyWith(
                        color: AppColors.primary400,
                        decoration: TextDecoration.underline,
                        decorationColor: AppColors.primary400,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          NavigatorHelper.to(const LoginView());
                        },
                    ),
                  ],
                ),
              ),
              Dimens.space(4),
            ],
          ),
        ),
      ),
    );
  }
}
