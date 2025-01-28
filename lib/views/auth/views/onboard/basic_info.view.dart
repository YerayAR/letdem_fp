import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:letdem/constants/ui/colors.dart';
import 'package:letdem/constants/ui/dimens.dart';
import 'package:letdem/constants/ui/typo.dart';
import 'package:letdem/global/widgets/body.dart';
import 'package:letdem/global/widgets/button.dart';
import 'package:letdem/global/widgets/chip.dart';
import 'package:letdem/global/widgets/textfield.dart';
import 'package:letdem/services/res/navigator.dart';
import 'package:letdem/views/auth/views/permissions/request_permission.view.dart';

class BasicInfoView extends StatelessWidget {
  const BasicInfoView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
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
                style: Typo.heading4.copyWith(color: AppColors.neutral600),
              ),
              Dimens.space(1),

              Text('Enter your full name to proceed',
                  style: Typo.largeBody.copyWith()),

              Dimens.space(5),
              const TextInputField(
                prefixIcon: Iconsax.user,
                label: 'First Name',
                placeHolder: 'Eg. John',
              ),
              Dimens.space(1),
              const TextInputField(
                prefixIcon: Iconsax.user,
                label: 'Last Name',
                placeHolder: 'Eg. Doe',
              ),

              Dimens.space(2),
              PrimaryButton(
                onTap: () {
                  NavigatorHelper.to(const RequestPermissionView());
                },
                text: 'Continue',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
