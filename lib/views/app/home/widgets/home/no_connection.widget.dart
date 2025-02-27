import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:letdem/constants/ui/colors.dart';
import 'package:letdem/constants/ui/dimens.dart';
import 'package:letdem/constants/ui/typo.dart';
import 'package:letdem/global/widgets/button.dart';

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
              "Location Permission\nRequired",
              style: Typo.largeBody
                  .copyWith(fontWeight: FontWeight.w700, fontSize: 25),
              textAlign: TextAlign.center,
            ),
            Text(
              "We need to get access to your location services to perform any action in the app",
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
                text: 'Open System Settings',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
