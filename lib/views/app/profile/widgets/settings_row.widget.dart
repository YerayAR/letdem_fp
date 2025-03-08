import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:letdem/constants/ui/colors.dart';
import 'package:letdem/constants/ui/dimens.dart';
import 'package:letdem/constants/ui/typo.dart';

class SettingsRow extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final bool showDivider;

  final IconData? icon;
  const SettingsRow(
      {super.key,
      required this.text,
      this.onTap,
      this.showDivider = true,
      this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  spacing: 12,
                  children: [
                    if (icon != null)
                      Icon(
                        icon,
                        color: AppColors.neutral600,
                      ),
                    Text(
                      text,
                      style: Typo.mediumBody.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.neutral600,
                      ),
                    ),
                  ],
                ),
                Icon(
                  Iconsax.arrow_right_3,
                  color: AppColors.neutral300,
                ),
              ],
            ),
          ),
        ),
        if (showDivider)
          Column(
            children: [
              Dimens.space(1),
              Container(
                height: 1,
                color: AppColors.neutral50,
              ),
            ],
          ),
      ],
    );
  }
}
