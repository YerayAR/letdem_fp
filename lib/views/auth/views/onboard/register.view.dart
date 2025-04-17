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

  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(Dimens.defaultMargin),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              PrimaryButton(
                isLoading: context.watch<AuthBloc>().state is RegisterLoading,
                onTap: () {
                  if (_formKey.currentState!.validate()) {
                    if (_passwordCTRL.text != _repeatPasswordCTRL.text) {
                      Toast.showError('Passwords do not match');
                      return;
                    }
                    if (_passwordCTRL.text.length < 8) {
                      Toast.showError('Password must be at least 8 characters');
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
                        email: _emailCTRL.text, password: _passwordCTRL.text));
                  }
                },
                isDisabled: !isChecked,
                text: 'Continue',
              ),
              Dimens.space(1),

              PrimaryButton(
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
              Dimens.space(1),

              //By continuing, I agree to LetDem Terms & Conditions
              Row(
                children: [
                  CustomCheckbox(
                    value: isChecked,
                    onChanged: (value) {
                      setState(() {
                        isChecked = value;
                      });
                    },
                    activeColor: AppColors.primary500,
                    size: 21.0,
                    borderRadius: 7.0,
                  ),
                  Dimens.space(1),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        children: [
                          const TextSpan(
                            text: 'By continuing, I agree to LetDem ',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 13,
                            ),
                          ),
                          TextSpan(
                            text: 'Terms & Conditions',
                            style: TextStyle(
                              color: AppColors.primary500,
                              fontSize: 13,
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                // handle tap here (e.g. open a web page or navigate to terms screen)
                              },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // Text.rich(
              //   TextSpan(

              // You can add more widgets here like:
              // SizedBox(height: 12),
              // PrimaryButton(...),
              // Text(...),
            ],
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
                    Dimens.space(1),
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
                    Text(
                      "Ensure to use at least 8 characters, with a number and a special character and uppercase letter",
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
    );
  }
}

class CustomCheckbox extends StatefulWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final Color activeColor;
  final Color inactiveColor;
  final Color checkColor;
  final double size;
  final double borderRadius;
  final double borderWidth;
  final Widget? label;
  final EdgeInsets padding;

  const CustomCheckbox({
    Key? key,
    required this.value,
    required this.onChanged,
    this.activeColor = Colors.blue,
    this.inactiveColor = Colors.transparent,
    this.checkColor = Colors.white,
    this.size = 24.0,
    this.borderRadius = 6.0,
    this.borderWidth = 2.0,
    this.label,
    this.padding = const EdgeInsets.symmetric(vertical: 8.0),
  }) : super(key: key);

  @override
  State<CustomCheckbox> createState() => _CustomCheckboxState();
}

class _CustomCheckboxState extends State<CustomCheckbox> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding,
      child: InkWell(
        onTap: () {
          if (widget.onChanged != null) {
            widget.onChanged!(!widget.value);
          }
        },
        onHover: (isHovered) {
          setState(() {
            _isHovered = isHovered;
          });
        },
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                color: widget.value ? widget.activeColor : widget.inactiveColor,
                borderRadius: BorderRadius.circular(widget.borderRadius),
                border: Border.all(
                  color: widget.value
                      ? widget.activeColor
                      : _isHovered
                          ? widget.activeColor.withOpacity(0.7)
                          : Colors.grey,
                  width: widget.borderWidth,
                ),
              ),
              child: widget.value
                  ? Center(
                      child: Icon(
                        Icons.check,
                        size: widget.size * 0.7,
                        color: widget.checkColor,
                      ),
                    )
                  : null,
            ),
            if (widget.label != null)
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: widget.label!,
              ),
          ],
        ),
      ),
    );
  }
}

// Example usage:
class CheckboxExample extends StatefulWidget {
  const CheckboxExample({Key? key}) : super(key: key);

  @override
  State<CheckboxExample> createState() => _CheckboxExampleState();
}

class _CheckboxExampleState extends State<CheckboxExample> {
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),

            // Checkbox with different style
            CustomCheckbox(
              value: isChecked,
              onChanged: (value) {
                setState(() {
                  isChecked = value;
                });
              },
              activeColor: Colors.purple,
              size: 28.0,
              borderRadius: 14.0, // Fully rounded
              borderWidth: 1.5,
              checkColor: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
