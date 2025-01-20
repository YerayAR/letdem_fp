import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:letdem/constants/ui/colors.dart';
import 'package:letdem/constants/ui/dimens.dart';
import 'package:letdem/constants/ui/typo.dart';
import 'package:letdem/global/widgets/body.dart';
import 'package:letdem/global/widgets/button.dart';

class VerifyAccountView extends StatelessWidget {
  const VerifyAccountView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: StyledBody(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Spacer(),
            Column(
              children: <Widget>[
                Text(
                  "We sent you an email",
                  textAlign: TextAlign.center,
                  style: Typo.heading4.copyWith(color: AppColors.neutral600),
                ),
                Text(
                  "Kindly check the email you provided for an OTP to verify your email and enter it below",
                  textAlign: TextAlign.center,
                  style: Typo.mediumBody.copyWith(color: AppColors.neutral400),
                ),
                Dimens.space(3),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.tetiary5000,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.symmetric(
                    vertical: Dimens.defaultMargin / 2,
                    horizontal: Dimens.defaultMargin,
                  ),
                  child: Column(
                    children: [
                      Center(
                        child: Text.rich(
                          TextSpan(
                            text:
                                'Mail is sent to: ', // Default style for this text
                            style: Typo.smallBody.copyWith(),
                            children: [
                              TextSpan(
                                text:
                                    'mistalogik@outlook.com', // Styled differently
                                style: Typo.smallBody.copyWith(
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
                      Dimens.space(0.5),
                      Center(
                        child: Text.rich(
                          TextSpan(
                            text: 'Not you? ', // Default style for this text
                            style: Typo.smallBody.copyWith(),
                            children: [
                              TextSpan(
                                text: 'Change email', // Styled differently
                                style: Typo.smallBody.copyWith(
                                  color: AppColors.primary400,
                                  fontWeight: FontWeight.w600,
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
                ),
              ],
            ),
            Spacer(),
            PrimaryButton(
              onTap: () {
                // NavigatorHelper.to(VerifyAccountView());
              },
              text: 'Proceed',
            ),
            Dimens.space(1),
            Center(
              child: Text.rich(
                TextSpan(
                  text: 'Didn’t get OTP? ', // Default style for this text
                  style: Typo.mediumBody.copyWith(),
                  children: [
                    TextSpan(
                      text: ' Resend in 00:23', // Styled differently
                      style: Typo.mediumBody.copyWith(
                        color: AppColors.primary400,
                        fontWeight: FontWeight.w600,
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
            Dimens.space(3),
          ],
        ),
      ),
    );
  }
}
