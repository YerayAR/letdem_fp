import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:letdem/common/popups/popup.dart';
import 'package:letdem/common/popups/success_dialog.dart';
import 'package:letdem/common/widgets/appbar.dart';
import 'package:letdem/common/widgets/body.dart';
import 'package:letdem/common/widgets/button.dart';
import 'package:letdem/common/widgets/textfield.dart';
import 'package:letdem/core/constants/dimens.dart';
import 'package:letdem/core/extensions/user.dart';
import 'package:letdem/features/users/user_bloc.dart';
import 'package:letdem/infrastructure/services/res/navigator.dart';
import 'package:letdem/infrastructure/toast/toast/toast.dart';

class EditBasicInfoView extends StatefulWidget {
  const EditBasicInfoView({super.key});

  @override
  State<EditBasicInfoView> createState() => _EditBasicInfoViewState();
}

class _EditBasicInfoViewState extends State<EditBasicInfoView> {
  late TextEditingController _firstNameCTRL;
  late TextEditingController _lastNameCTRL;

  @override
  void initState() {
    _firstNameCTRL = TextEditingController();
    _lastNameCTRL = TextEditingController();

    // add post frame callback to get the user data

    WidgetsBinding.instance.addPostFrameCallback((_) {
      var user = context.userProfile;

      if (user != null) {
        _firstNameCTRL.text = user.firstName;
        _lastNameCTRL.text = user.lastName;
      }
    });
    super.initState();
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _firstNameCTRL.dispose();
    _lastNameCTRL.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<UserBloc, UserState>(
        listener: (context, state) {
          if (state is UserError) {
            Toast.showError(state.error);
          }
          if (state is UserLoaded) {
            AppPopup.showDialogSheet(
              context,
              SuccessDialog(
                title: 'Account information changed successfully',
                onProceed: () {
                  NavigatorHelper.pop();
                },
                subtext:
                    'Your account information has been changed successfully,',
                buttonText: "Go Back",
              ),
            );
          }
          // TODO: implement listener
        },
        builder: (context, state) {
          return ListView(
            children: [
              Form(
                key: _formKey,
                child: StyledBody(
                  children: [
                    StyledAppBar(
                      title: 'Personal Information',
                      onTap: () {
                        NavigatorHelper.pop();
                      },
                      icon: Icons.close,
                    ),
                    // custom app bar

                    Dimens.space(3),
                    TextInputField(
                      prefixIcon: Iconsax.user,
                      label: 'First Name',
                      controller: _firstNameCTRL,
                      placeHolder: 'Enter your first name',
                    ),
                    Dimens.space(1),
                    TextInputField(
                      prefixIcon: Iconsax.user,
                      controller: _lastNameCTRL,
                      label: 'Last Name',
                      placeHolder: 'Enter your last name',
                    ),

                    Dimens.space(2),

                    PrimaryButton(
                      isLoading: state is UserLoading,
                      onTap: () {
                        if (!_formKey.currentState!.validate()) {
                          return;
                        }
                        context.read<UserBloc>().add(
                              EditBasicInfoEvent(
                                firstName: _firstNameCTRL.text,
                                lastName: _lastNameCTRL.text,
                              ),
                            );
                      },
                      text: 'Save',
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
