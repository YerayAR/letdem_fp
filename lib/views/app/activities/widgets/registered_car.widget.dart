import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:letdem/constants/ui/assets.dart';
import 'package:letdem/constants/ui/colors.dart';
import 'package:letdem/constants/ui/dimens.dart';
import 'package:letdem/constants/ui/typo.dart';
import 'package:letdem/features/car/repository/car.repository.dart';
import 'package:letdem/global/widgets/chip.dart';
import 'package:letdem/services/res/navigator.dart';
import 'package:letdem/views/app/activities/widgets/no_car_registered.widget.dart';

class RegisteredCarWidget extends StatelessWidget {
  final Car car;
  const RegisteredCarWidget({super.key, required this.car});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: 0,
        horizontal: 0,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Padding(
            padding: const EdgeInsets.all(25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Your Car Details
                Text(
                  "Your Car Details",
                  style: Typo.smallBody.copyWith(
                    color: AppColors.neutral500,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Dimens.space(1),
                //   Mercedes Benz E350
                Text(
                  car.brand,
                  style: Typo.largeBody.copyWith(
                      // color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 19),
                ),
                Dimens.space(1),

                Row(
                  spacing: 8,
                  children: <Widget>[
                    Text("Plate Number: ${car.registrationNumber}",
                        style: Typo.largeBody.copyWith(
                          color: AppColors.neutral500,
                          fontWeight: FontWeight.w500,
                        )),
                    CircleAvatar(
                      radius: 3,
                      backgroundColor: AppColors.neutral500,
                    ),
                    SvgPicture.asset(
                      geTagTypeIcon(car.tagType),
                      width: 20,
                    )
                  ],
                ),
                Dimens.space(2),

                GestureDetector(
                  onTap: () {
                    NavigatorHelper.to(RegisterCarView(car: car));
                  },
                  child: DecoratedChip(
                    backgroundColor: AppColors.primary50,
                    text: 'Edit Details',
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 14,
                    ),
                    textStyle: Typo.smallBody.copyWith(
                      color: AppColors.primary500,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                    textSize: 11,
                    color: AppColors.primary500,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: 0,
            child: SvgPicture.asset(
              AppAssets.eclipse,
              width: 130,
              height: 130,
            ),
          ),
          Positioned(
            right: 0,
            top: 10,
            child: SvgPicture.asset(
              AppAssets.car,
              width: MediaQuery.of(context).size.width * 0.3,
              height: MediaQuery.of(context).size.width * 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class LastParkedWidget extends StatelessWidget {
  const LastParkedWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: 0,
        horizontal: 0,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary500,
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}
