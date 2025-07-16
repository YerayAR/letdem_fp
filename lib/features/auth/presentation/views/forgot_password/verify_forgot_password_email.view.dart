import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:letdem/common/widgets/body.dart';
import 'package:letdem/common/widgets/button.dart';
import 'package:letdem/core/constants/colors.dart';
import 'package:letdem/core/constants/dimens.dart';
import 'package:letdem/core/constants/typo.dart';
import 'package:letdem/core/extensions/locale.dart';
import 'package:letdem/features/auth/auth_bloc.dart';
import 'package:letdem/infrastructure/services/res/navigator.dart';
import 'package:letdem/infrastructure/toast/toast/toast.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/otp_field_style.dart';
import 'package:otp_text_field/style.dart';

import 'reset_password.view.dart';

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
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        body: Center(
          child: BlocConsumer<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is ValidateResetPasswordSuccess) {
                NavigatorHelper.to(ResetPasswordView(
                  email: widget.email,
                ));
              }
              if (state is ValidateResetPasswordError) {
                Toast.showError(state.error);
              }
              // TODO: implement listener
            },
            builder: (context, state) {
              return StyledBody(
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
                        context.l10n.emailSentTitle,
                        textAlign: TextAlign.center,
                        style:
                            Typo.heading4.copyWith(color: AppColors.neutral600),
                      ),
                      Text(
                        context.l10n.emailSentDescription,
                        textAlign: TextAlign.center,
                        style: Typo.mediumBody
                            .copyWith(color: AppColors.neutral400),
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
                                  text: context.l10n.mailSentTo,
                                  style: Typo.smallBody.copyWith(),
                                  children: [
                                    TextSpan(
                                      text: widget.email,
                                      style: Typo.smallBody.copyWith(
                                        decorationColor: AppColors.primary400,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Dimens.space(0.5),
                            Center(
                              child: Text.rich(
                                TextSpan(
                                  text: context.l10n.notYou,
                                  style: Typo.smallBody.copyWith(),
                                  children: [
                                    TextSpan(
                                      text: context.l10n.changeEmail,
                                      style: Typo.smallBody.copyWith(
                                        color: AppColors.primary400,
                                        fontWeight: FontWeight.w600,
                                        decoration: TextDecoration.underline,
                                        decorationColor: AppColors.primary400,
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () => NavigatorHelper.pop(),
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
                      if (otp == null || otp!.length < 6) return;
                      context.read<AuthBloc>().add(ValidateResetPasswordEvent(
                            email: widget.email,
                            code: otp!,
                          ));
                    },
                    isLoading: state is ValidateResetPasswordLoading,
                    text: context.l10n.proceed,
                  ),
                  Dimens.space(2),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (state is ResendVerificationCodeLoading)
                          CircularProgressIndicator(
                            color: AppColors.primary500,
                          ),
                        Text.rich(
                          TextSpan(
                            text: context.l10n.didntGetOtp,
                            style: Typo.mediumBody.copyWith(),
                            children: [
                              TextSpan(
                                text: _isResendEnabled
                                    ? context.l10n.tapToResend
                                    : context.l10n
                                        .resendIn(_secondsRemaining.toString()),
                                style: Typo.mediumBody.copyWith(
                                  color: AppColors.primary400,
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.underline,
                                  decorationColor: AppColors.primary400,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    if (_isResendEnabled) {
                                      context.read<AuthBloc>().add(
                                          ResendForgotPasswordVerificationCodeEvent(
                                              email: widget.email));
                                      _startTimer();
                                    }
                                  },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Dimens.space(3),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
