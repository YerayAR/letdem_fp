import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:letdem/constants/ui/colors.dart';
import 'package:letdem/constants/ui/dimens.dart';
import 'package:letdem/constants/ui/typo.dart';
import 'package:letdem/global/widgets/button.dart';

class NoContributionsWidget extends StatelessWidget {
  const NoContributionsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Spacer(),
        Text(
          "No Contributions Yet",
          style: Typo.largeBody.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        Dimens.space(2),
        Text(
          "Your Contributions history will appear\nhere, Publish to see them",
          style: Typo.mediumBody.copyWith(color: AppColors.neutral400),
          textAlign: TextAlign.center,
        ),
        Dimens.space(2),
        SizedBox(
          width: MediaQuery.of(context).size.width / 1.9,
          child: PrimaryButton(
            onTap: () {},
            icon: Iconsax.location5,
            text: 'Publish Space',
          ),
        ),
        Dimens.space(1),
        Center(
            child: Text(
          "Publish an event",
          style: Typo.mediumBody.copyWith(
            color: AppColors.primary400,
            fontWeight: FontWeight.w500,
            decoration: TextDecoration.underline,
          ),
        )),
        const Spacer(),
      ],
    );
  }
}
