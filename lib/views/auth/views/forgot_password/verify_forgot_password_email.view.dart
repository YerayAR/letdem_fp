import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:letdem/constants/ui/colors.dart';
import 'package:letdem/constants/ui/dimens.dart';
import 'package:letdem/constants/ui/typo.dart';
import 'package:letdem/global/widgets/body.dart';
import 'package:letdem/global/widgets/button.dart';
import 'package:letdem/services/res/navigator.dart';
import 'package:letdem/views/auth/views/forgot_password/reset_password.view.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/otp_field_style.dart';
import 'package:otp_text_field/style.dart';

class VerifyForgotPasswordEmailView extends StatefulWidget {
  final String email;
  const VerifyForgotPasswordEmailView({super.key, required this.email});

  @override
  State<VerifyForgotPasswordEmailView> createState() =>
      _VerifyForgotPasswordEmailViewState();
}

class _VerifyForgotPasswordEmailViewState
    extends State<VerifyForgotPasswordEmailView> {
  OtpFieldController otpbox = OtpFieldController();
  String? otp;
  Timer? _timer;
  int _secondsRemaining = 60;
  bool _isResendEnabled = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    setState(() {
      _secondsRemaining = 60;
      _isResendEnabled = false;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        timer.cancel();
        setState(() {
          _isResendEnabled = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: StyledBody(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            Column(
              children: <Widget>[
                CircleAvatar(
                  radius: 50,
                  backgroundColor: AppColors.secondary50,
                  child: Icon(
                    Iconsax.sms5,
                    size: 40,
                    color: AppColors.secondary600,
                  ),
                ),
                Dimens.space(3),
                Text(
                  "We sent you an email",
                  textAlign: TextAlign.center,
                  style: Typo.heading4.copyWith(color: AppColors.neutral600),
                ),
                Text(
                  "We've sent an OTP to your email. Enter it below to reset your password.",
                  textAlign: TextAlign.center,
                  style: Typo.mediumBody.copyWith(color: AppColors.neutral400),
                ),
                Dimens.space(3),
                OTPTextField(
                  length: 6,
                  width: MediaQuery.of(context).size.width,
                  otpFieldStyle: OtpFieldStyle(
                    enabledBorderColor: AppColors.neutral50,
                    borderColor: AppColors.neutral50.withOpacity(0.5),
                  ),
                  fieldWidth: 50,
                  controller: otpbox,
                  style: const TextStyle(fontSize: 17),
                  spaceBetween: 15,
                  textFieldAlignment: MainAxisAlignment.center,
                  fieldStyle: FieldStyle.box,
                  onChanged: (value) {
                    setState(() {
                      otp = value;
                    });
                  },
                  onCompleted: (pin) {
                    setState(() {
                      otp = pin;
                    });
                  },
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
                            text: 'Mail is sent to: ',
                            style: Typo.smallBody.copyWith(),
                            children: [
                              TextSpan(
                                text: widget.email,
                                style: Typo.smallBody.copyWith(
                                  decorationColor: AppColors.primary400,
                                  fontWeight: FontWeight.w600,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {},
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
            const Spacer(),
            PrimaryButton(
              onTap: () {
                NavigatorHelper.to(const ResetPasswordView());
              },
              text: 'Proceed',
            ),
            Dimens.space(2),
            Center(
              child: Text.rich(
                TextSpan(
                  text: 'Didn’t get OTP? ', // Default style for this text
                  style: Typo.mediumBody.copyWith(),
                  children: [
                    TextSpan(
                      text: _isResendEnabled
                          ? "Tap to resend."
                          : ' Resend in 00:$_secondsRemaining',
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
