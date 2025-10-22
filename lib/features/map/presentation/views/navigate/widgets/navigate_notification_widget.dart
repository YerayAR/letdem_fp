import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:letdem/core/extensions/locale.dart';

import '../../../../../../common/widgets/button.dart';
import '../../../../../../core/constants/colors.dart';
import '../../../../../../core/constants/dimens.dart';
import '../../../../../../core/constants/typo.dart';

class NavigateNotificationWidget extends StatelessWidget {
  final VoidCallback? onClose;

  const NavigateNotificationWidget({super.key, this.onClose});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        CircleAvatar(
          radius: 45,
          backgroundColor: AppColors.green50,
          child: Icon(Iconsax.location5, size: 45, color: AppColors.green600),
        ),
        Dimens.space(3),
        Text(
          context.l10n.arrivalTitle,
          textAlign: TextAlign.center,
          style: Typo.heading4.copyWith(color: AppColors.neutral600),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            context.l10n.arrivalSubtitle,
            textAlign: TextAlign.center,
            style: Typo.mediumBody.copyWith(color: AppColors.neutral400),
          ),
        ),
        Dimens.space(5),
        PrimaryButton(
          onTap: () {
            if (onClose != null) {
              onClose!();
            } else {
              Navigator.pop(context);
            }
          },
          text: context.l10n.proceed,
        ),
      ],
    );
  }
}
