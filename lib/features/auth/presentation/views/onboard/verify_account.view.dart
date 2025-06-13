import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:letdem/common/popups/popup.dart';
import 'package:letdem/common/popups/success_dialog.dart';
import 'package:letdem/common/widgets/appbar.dart';
import 'package:letdem/common/widgets/body.dart';
import 'package:letdem/common/widgets/button.dart';
import 'package:letdem/core/constants/colors.dart';
import 'package:letdem/core/constants/dimens.dart';
import 'package:letdem/core/constants/typo.dart';
import 'package:letdem/features/auth/auth_bloc.dart';
import 'package:letdem/features/auth/presentation/views/onboard/basic_info.view.dart';
import 'package:letdem/infrastructure/services/res/navigator.dart';
import 'package:letdem/infrastructure/toast/toast/toast.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/otp_field_style.dart';
import 'package:otp_text_field/style.dart';

class VerifyAccountView extends StatefulWidget {
  final String email;
  const VerifyAccountView({super.key, required this.email});

  @override
  State<VerifyAccountView> createState() => _VerifyAccountViewState();
}

class _VerifyAccountViewState extends State<VerifyAccountView> {
  OtpFieldController otpbox = OtpFieldController();
  String? otp;
  Timer? _timer;
  int _secondsRemaining = 30;
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
      _secondsRemaining = 30;
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
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is RegisterError) {
            Toast.showError(state.error);
          }
          if (state is OTPVerificationSuccess) {
            AppPopup.showDialogSheet(
              context,
              SuccessDialog(
                title: "Verification Success",
                subtext:
                    "Your account email has been verified successfully. You can proceed to the app.",
                isLoading: state is OTPVerificationLoading,
                onProceed: () {
                  NavigatorHelper.replaceAll(const BasicInfoView());
                },
              ),
            );
          }

          // TODO: implement listener
        },
        builder: (context, state) {
          return Center(
            child: StyledBody(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                StyledAppBar(
                  onTap: () => NavigatorHelper.pop(),
                  title: 'Verify Account',
                  icon: Icons.close,
                ),
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
                      style:
                          Typo.heading4.copyWith(color: AppColors.neutral600),
                    ),
                    Text(
                      "Kindly check the email you provided for an OTP to verify your email and enter it below",
                      textAlign: TextAlign.center,
                      style:
                          Typo.mediumBody.copyWith(color: AppColors.neutral400),
                    ),
                    Dimens.space(3),
                    OTPTextField(
                      length: 6,
                      width: MediaQuery.of(context).size.width,
                      otpFieldStyle: OtpFieldStyle(
                        enabledBorderColor: AppColors.neutral200,
                        borderColor: Colors.black.withOpacity(0.2),
                      ),
                      fieldWidth: 50,
                      controller: otpbox,
                      style: const TextStyle(fontSize: 17),
                      spaceBetween: 5,
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
                                text:
                                    'Not you? ', // Default style for this text
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
                                        NavigatorHelper.pop();
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
                    context
                        .read<AuthBloc>()
                        .add(VerifyEmailEvent(email: widget.email, code: otp!));
                  },
                  isLoading: state is OTPVerificationLoading,
                  text: 'Proceed',
                ),
                Dimens.space(2),
                Center(
                  child: state is ResendVerificationCodeLoading
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Resending",
                                style: Typo.mediumBody
                                    .copyWith(color: AppColors.primary400)),
                            Dimens.space(1),
                            CupertinoActivityIndicator(
                              color: AppColors.primary400,
                            ),
                          ],
                        )
                      : Text.rich(
                          TextSpan(
                            text:
                                'Didn’t get OTP? ', // Default style for this text
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
                                    context.read<AuthBloc>().add(
                                        ResendVerificationCodeEvent(
                                            email: widget.email));
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
          );
        },
      ),
    );
  }
}
