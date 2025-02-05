import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:letdem/constants/ui/assets.dart';
import 'package:letdem/constants/ui/colors.dart';
import 'package:letdem/constants/ui/dimens.dart';
import 'package:letdem/constants/ui/typo.dart';
import 'package:letdem/global/widgets/chip.dart';

class RegisteredCarWidget extends StatelessWidget {
  const RegisteredCarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: 0,
        horizontal: 0,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary400,
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
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Dimens.space(1),
                //   Mercedes Benz E350
                Text(
                  "Mercedes Benz E350",
                  style: Typo.largeBody.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 19),
                ),
                Dimens.space(1),

                Row(
                  spacing: 8,
                  children: <Widget>[
                    Text("Year: 2024",
                        style: Typo.largeBody.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        )),
                    CircleAvatar(
                      radius: 3,
                      backgroundColor: AppColors.primary200,
                    ),
                    Text("Tag: Eco",
                        style: Typo.largeBody.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        )),
                  ],
                ),
                Dimens.space(2),

                DecoratedChip(
                  backgroundColor: AppColors.primary600,
                  text: 'Edit Details',
                  padding: const EdgeInsets.symmetric(
                    vertical: 5,
                    horizontal: 10,
                  ),
                  textSize: 14,
                  color: Colors.white,
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
              width: 160,
              height: 160,
            ),
          ),
        ],
      ),
    );
  }
}
