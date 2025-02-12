import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:letdem/constants/ui/colors.dart';
import 'package:letdem/constants/ui/dimens.dart';
import 'package:letdem/constants/ui/typo.dart';
import 'package:letdem/features/users/user_bloc.dart';
import 'package:letdem/global/widgets/body.dart';
import 'package:letdem/global/widgets/button.dart';
import 'package:letdem/global/widgets/chip.dart';
import 'package:letdem/global/widgets/textfield.dart';
import 'package:letdem/services/res/navigator.dart';
import 'package:letdem/services/toast/toast.dart';
import 'package:letdem/views/auth/views/permissions/request_permission.view.dart';

class BasicInfoView extends StatefulWidget {
  const BasicInfoView({Key? key}) : super(key: key);

  @override
  State<BasicInfoView> createState() => _BasicInfoViewState();
}

class _BasicInfoViewState extends State<BasicInfoView> {
  late TextEditingController _firstNameCTRL;
  late TextEditingController _lastNameCTRL;

  @override
  void initState() {
    _firstNameCTRL = TextEditingController();
    _lastNameCTRL = TextEditingController();
    super.initState();
  }

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

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
            NavigatorHelper.to(const RequestPermissionView());
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
                    // custom app bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        DecoratedChip(
                          backgroundColor: AppColors.secondary50,
                          text: 'CREATE NEW ACCOUNT',
                          color: AppColors.secondary600,
                        ),
                        IconButton(
                          icon: const Icon(Iconsax.close_circle5),
                          color: AppColors.neutral100,
                          onPressed: () {
                            NavigatorHelper.pop();
                          },
                        ),
                      ],
                    ),
                    Dimens.space(3),
                    Text(
                      'Personal Information',
                      style:
                          Typo.heading4.copyWith(color: AppColors.neutral600),
                    ),
                    Dimens.space(1),

                    Text('Enter your full name to proceed',
                        style: Typo.largeBody.copyWith()),

                    Dimens.space(5),
                    TextInputField(
                      prefixIcon: Iconsax.user,
                      label: 'First Name',
                      controller: _firstNameCTRL,
                      placeHolder: 'Eg. John',
                    ),
                    Dimens.space(1),
                    TextInputField(
                      prefixIcon: Iconsax.user,
                      controller: _lastNameCTRL,
                      label: 'Last Name',
                      placeHolder: 'Eg. Doe',
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
                      text: 'Continue',
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
