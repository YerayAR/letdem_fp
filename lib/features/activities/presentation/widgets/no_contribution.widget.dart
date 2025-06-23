import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:letdem/common/widgets/button.dart';
import 'package:letdem/core/constants/colors.dart';
import 'package:letdem/core/constants/dimens.dart';
import 'package:letdem/core/constants/typo.dart';
import 'package:letdem/core/extensions/locale.dart';
import 'package:letdem/features/activities/presentation/utils/publish_space_handler.dart';

class NoContributionsWidget extends StatelessWidget {
  const NoContributionsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Spacer(),
        Text(
          context.l10n.noContributions,
          style: Typo.largeBody.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        Dimens.space(2),
        Text(
          context.l10n.noContributionsDescription,
          style: Typo.mediumBody.copyWith(color: AppColors.neutral400),
          textAlign: TextAlign.center,
        ),
        Dimens.space(2),
        SizedBox(
          width: MediaQuery.of(context).size.width / 1.9,
          child: PrimaryButton(
            onTap: () async {
              PublishSpaceHandler.showSpaceOptions(context, () {});
            },
            icon: Iconsax.location5,
            text: context.l10n.publishSpace,
          ),
        ),
        Dimens.space(1),
        const Spacer(),
      ],
    );
  }
}
