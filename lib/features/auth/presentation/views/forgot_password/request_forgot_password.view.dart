import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconly/iconly.dart';
import 'package:iconsax/iconsax.dart';
import 'package:letdem/common/widgets/body.dart';
import 'package:letdem/common/widgets/button.dart';
import 'package:letdem/common/widgets/chip.dart';
import 'package:letdem/common/widgets/textfield.dart';
import 'package:letdem/constants/ui/colors.dart';
import 'package:letdem/constants/ui/dimens.dart';
import 'package:letdem/constants/ui/typo.dart';
import 'package:letdem/features/auth/auth_bloc.dart';
import 'package:letdem/infrastructure/toast/toast/toast.dart';

import '../../../../../infrastructure/services/res/navigator.dart';
import 'verify_forgot_password_email.view.dart';

class RequestForgotPasswordView extends StatefulWidget {
  const RequestForgotPasswordView({super.key});

  @override
  State<RequestForgotPasswordView> createState() =>
      _RequestForgotPasswordViewState();
}

class _RequestForgotPasswordViewState extends State<RequestForgotPasswordView> {
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
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        // TODO: implement listener
        if (state is FindForgotPasswordAccountSuccess) {
          NavigatorHelper.to(VerifyForgotPasswordEmailView(
            email: _emailCTRL.text,
          ));
        }
        if (state is FindForgotPasswordAccountError) {
          Toast.showError(state.error);
        }
      },
      builder: (context, state) {
        return Scaffold(
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: EdgeInsets.all(Dimens.defaultMargin),
              child: PrimaryButton(
                isLoading: state is FindForgotPasswordAccountLoading,
                onTap: () {
                  if (!_formKey.currentState!.validate()) {
                    return;
                  }
                  context.read<AuthBloc>().add(FindForgotPasswordAccountEvent(
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
                              icon: const Icon(IconlyLight.arrow_left),
                              color: const Color(0xff445D6F),
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
                          style: Typo.heading4
                              .copyWith(color: AppColors.neutral600),
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
      },
    );
  }
}
