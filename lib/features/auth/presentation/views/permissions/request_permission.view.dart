import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:iconsax/iconsax.dart';
import 'package:letdem/common/widgets/body.dart';
import 'package:letdem/common/widgets/button.dart';
import 'package:letdem/constants/ui/colors.dart';
import 'package:letdem/constants/ui/dimens.dart';
import 'package:letdem/constants/ui/typo.dart';
import 'package:letdem/infrastructure/services/res/navigator.dart';
import 'package:letdem/views/app/base.dart';

class RequestPermissionView extends StatefulWidget {
  const RequestPermissionView({super.key});

  @override
  State<RequestPermissionView> createState() => _RequestPermissionViewState();
}

class _RequestPermissionViewState extends State<RequestPermissionView> {
  bool _isDeniedForever = false;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    var status = await Geolocator.checkPermission();
    if (status == LocationPermission.always ||
        status == LocationPermission.whileInUse) {
      NavigatorHelper.replaceAll(const BaseView());
      return;
    } else if (status == LocationPermission.deniedForever) {
      setState(() => _isDeniedForever = true);
    }
  }

  Future<void> _requestPermission() async {
    var status = await Geolocator.requestPermission();
    if (status == LocationPermission.always ||
        status == LocationPermission.whileInUse) {
      NavigatorHelper.replaceAll(const BaseView());
    } else if (status == LocationPermission.deniedForever) {
      setState(() => _isDeniedForever = true);
    }
  }

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
            "Kindly enable geolocation to allow the app to track your location automatically. This process must be completed to use the app.",
            textAlign: TextAlign.center,
            style: Typo.mediumBody.copyWith(color: AppColors.neutral400),
          ),
          Dimens.space(15),
          PrimaryButton(
            onTap: _isDeniedForever
                ? () => Geolocator.openLocationSettings()
                : _requestPermission,
            text: _isDeniedForever ? 'Open Settings' : 'Enable Geolocation',
          ),
          Dimens.space(1),
          PrimaryButton(
            onTap: () {
              NavigatorHelper.popAll();
              NavigatorHelper.replaceAll(const BaseView());
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
