import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:letdem/common/widgets/button.dart';
import 'package:letdem/core/constants/colors.dart';
import 'package:letdem/core/constants/dimens.dart';
import 'package:letdem/core/constants/typo.dart';
import 'package:letdem/core/extensions/locale.dart';

class NoMapPermissionSection extends StatelessWidget {
  const NoMapPermissionSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              context.l10n.locationPermissionRequired,
              style: Typo.largeBody
                  .copyWith(fontWeight: FontWeight.w700, fontSize: 25),
              textAlign: TextAlign.center,
            ),
            Text(
              context.l10n.locationPermissionDescription,
              style: Typo.mediumBody.copyWith(
                color: AppColors.neutral400,
              ),
              textAlign: TextAlign.center,
            ),
            Dimens.space(4),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.6,
              child: PrimaryButton(
                onTap: () async {
                  await Geolocator.openLocationSettings();
                },
                text: context.l10n.openSystemSettings,
              ),
            ),
          ],
        ),
      ),
    );
  }
}