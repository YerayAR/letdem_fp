import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconly/iconly.dart';
import 'package:iconsax/iconsax.dart';
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
import 'package:letdem/views/auth/views/forgot_password/verify_forgot_password_email.view.dart';

class RequestForgotPasswordView extends StatefulWidget {
  const RequestForgotPasswordView({super.key});

  @override
  State<RequestForgotPasswordView> createState() =>
      _RequestForgotPasswordViewState();
}

class _RequestForgotPasswordViewState extends State<RequestForgotPasswordView> {
  late TextEditingController _emailCTRL;
  late TextEditingController _passwordCTRL;

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
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
    return Scaffold(
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(Dimens.defaultMargin),
          child: PrimaryButton(
            isLoading: false,
            onTap: () {
              NavigatorHelper.to(VerifyForgotPasswordEmailView(
                email: _emailCTRL.text,
              ));
            },
            text: 'Proceed',
          ),
        ),
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is LoginError) {
            Toast.showError(state.error);
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
                        IconButton(
                          icon: Icon(IconlyLight.arrow_left),
                          color: Color(0xff445D6F),
                          onPressed: () {
                            NavigatorHelper.pop();
                          },
                        ),
                        DecoratedChip(
                          backgroundColor: AppColors.secondary50,
                          text: 'Get Help',
                          color: AppColors.secondary600,
                        ),
                      ],
                    ),
                    Dimens.space(3),
                    Text(
                      'Forgot Password',
                      style:
                          Typo.heading4.copyWith(color: AppColors.neutral600),
                    ),
                    Dimens.space(1),
                    Text("Enter your email address below to proceed with",
                        style: Typo.largeBody
                            .copyWith(color: AppColors.neutral500)),
                    Dimens.space(5),
                    TextInputField(
                      prefixIcon: Iconsax.sms,
                      controller: _emailCTRL,
                      inputType: TextFieldType.email,
                      label: 'Email Address',
                      placeHolder: 'Enter your email address',
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
