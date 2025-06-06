import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:letdem/common/widgets/body.dart';
import 'package:letdem/common/widgets/button.dart';
import 'package:letdem/common/widgets/chip.dart';
import 'package:letdem/common/widgets/textfield.dart';
import 'package:letdem/core/constants/colors.dart';
import 'package:letdem/core/constants/dimens.dart';
import 'package:letdem/core/constants/typo.dart';
import 'package:letdem/core/extensions/locale.dart';
import 'package:letdem/features/auth/presentation/views/permissions/request_permission.view.dart';
import 'package:letdem/features/users/user_bloc.dart';
import 'package:letdem/infrastructure/services/res/navigator.dart';
import 'package:letdem/infrastructure/toast/toast/toast.dart';

class BasicInfoView extends StatefulWidget {
  const BasicInfoView({super.key});

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
                          text: context.l10n.createNewAccount,
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
                      context.l10n.personalInformation,
                      style:
                          Typo.heading4.copyWith(color: AppColors.neutral600),
                    ),
                    Dimens.space(1),

                    Text(context.l10n.enterFullName,
                        style: Typo.largeBody.copyWith()),

                    Dimens.space(5),
                    TextInputField(
                      prefixIcon: Iconsax.user,
                      label: context.l10n.firstName,
                      controller: _firstNameCTRL,
                      placeHolder: context.l10n.enterFirstName,
                    ),
                    Dimens.space(1),
                    TextInputField(
                      prefixIcon: Iconsax.user,
                      controller: _lastNameCTRL,
                      label: context.l10n.lastName,
                      placeHolder: context.l10n.enterLastName,
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
                      text: context.l10n.continuee,
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
