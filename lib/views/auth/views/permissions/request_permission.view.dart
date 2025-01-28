import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:iconsax/iconsax.dart';
import 'package:letdem/constants/ui/colors.dart';
import 'package:letdem/constants/ui/dimens.dart';
import 'package:letdem/constants/ui/typo.dart';
import 'package:letdem/global/widgets/body.dart';
import 'package:letdem/global/widgets/button.dart';
import 'package:letdem/services/res/navigator.dart';
import 'package:letdem/views/app/home/base.dart';

class RequestPermissionView extends StatelessWidget {
  const RequestPermissionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StyledBody(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 70,
            backgroundColor: AppColors.secondary50,
            child: Icon(
              Iconsax.location5,
              size: 45,
              color: AppColors.secondary600,
            ),
          ),
          Dimens.space(8),
          Text(
            "Geolocation Permission",
            textAlign: TextAlign.center,
            style: Typo.heading4.copyWith(color: AppColors.neutral600),
          ),
          Dimens.space(1),
          Text(
            "Kindly enable geolocation to enable the app to automatically track your location, this process must be completed to be able use the app.",
            textAlign: TextAlign.center,
            style: Typo.mediumBody.copyWith(color: AppColors.neutral400),
          ),
          Dimens.space(15),
          PrimaryButton(
            onTap: () {
              Geolocator.requestPermission();
              NavigatorHelper.popAll();
              NavigatorHelper.replaceAll(const BaseView());
            },
            text: 'Enable Geolocation',
          ),
          Dimens.space(1),
          PrimaryButton(
            onTap: () {
              Navigator.pop(context);
            },
            borderColor: Colors.transparent,
            textColor: Colors.black,
            outline: true,
            text: 'Not now',
          ),
        ],
      ),
    );
  }
}
