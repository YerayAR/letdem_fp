import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:letdem/constants/ui/colors.dart';
import 'package:letdem/constants/ui/dimens.dart';
import 'package:letdem/constants/ui/typo.dart';
import 'package:letdem/features/auth/auth_bloc.dart';
import 'package:letdem/global/popups/popup.dart';
import 'package:letdem/global/widgets/body.dart';
import 'package:letdem/global/widgets/button.dart';
import 'package:letdem/services/res/navigator.dart';
import 'package:letdem/services/toast/toast.dart';
import 'package:letdem/views/auth/views/onboard/basic_info.view.dart';
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
      backgroundColor: Colors.white,
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
                        enabledBorderColor: Colors.black,
                        borderColor: Colors.black,
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
                    // AppPopup.showDialogSheet(
                    //   context,
                    //   Column(
                    //     children: <Widget>[
                    //       CircleAvatar(
                    //         radius: 45,
                    //         backgroundColor: AppColors.green50,
                    //         child: Icon(
                    //           Icons.done,
                    //           size: 45,
                    //           color: AppColors.green600,
                    //         ),
                    //       ),
                    //       Dimens.space(3),
                    //       Text(
                    //         "Verification Success",
                    //         textAlign: TextAlign.center,
                    //         style: Typo.heading4
                    //             .copyWith(color: AppColors.neutral600),
                    //       ),
                    //       Text(
                    //         "Your account email has been verified successfully you can proceed to the app.",
                    //         textAlign: TextAlign.center,
                    //         style: Typo.mediumBody
                    //             .copyWith(color: AppColors.neutral400),
                    //       ),
                    //       Dimens.space(5),
                    //       PrimaryButton(
                    //         isLoading: state is OTPVerificationLoading,
                    //         onTap: () {
                    //           context.read<AuthBloc>().add(VerifyEmailEvent(
                    //               email: widget.email, code: otp!));
                    //         },
                    //         text: 'Proceed',
                    //       ),
                    //     ],
                    //   ),
                    // );

                    // NavigatorHelper.to(VerifyAccountView());
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

class SuccessDialog extends StatelessWidget {
  final String title;
  final String subtext;
  final VoidCallback? onProceed;
  final bool isLoading;

  final String? buttonText;

  final IconData? icon;

  const SuccessDialog({
    super.key,
    required this.title,
    this.buttonText,
    required this.subtext,
    this.onProceed,
    this.isLoading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        CircleAvatar(
          radius: 45,
          backgroundColor: AppColors.green50,
          child: Icon(
            icon ?? Icons.done,
            size: 45,
            color: AppColors.green600,
          ),
        ),
        Dimens.space(3),
        Text(
          title,
          textAlign: TextAlign.center,
          style: Typo.heading4.copyWith(color: AppColors.neutral600),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            subtext,
            textAlign: TextAlign.center,
            style: Typo.mediumBody.copyWith(color: AppColors.neutral400),
          ),
        ),
        Dimens.space(5),
        PrimaryButton(
          isLoading: isLoading,
          onTap: onProceed,
          text: buttonText ?? 'Proceed',
        ),
      ],
    );
  }
}
