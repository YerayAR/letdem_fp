import 'package:flutter/material.dart';
import 'package:letdem/constants/ui/colors.dart';
import 'package:letdem/constants/ui/dimens.dart';
import 'package:letdem/constants/ui/typo.dart';
import 'package:letdem/views/app/profile/widgets/settings_container.widget.dart';

class NoCarRegisteredWidget extends StatelessWidget {
  const NoCarRegisteredWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsContainer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "No Car Registered",
                style: Typo.largeBody.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              Dimens.space(2),
              Text(
                "Register your car with the car details\nfor safety and accessibility",
                style: Typo.mediumBody.copyWith(color: AppColors.neutral400),
                textAlign: TextAlign.center,
              ),
              Dimens.space(2),
              Center(
                  child: Text(
                "Tap to Register Car",
                style: Typo.mediumBody.copyWith(
                  color: AppColors.primary400,
                  fontWeight: FontWeight.w500,
                  decoration: TextDecoration.underline,
                ),
              ))
            ],
          ),
        ],
      ),
    );
  }
}
