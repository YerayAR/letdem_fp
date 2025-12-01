import 'package:flutter/material.dart';
import 'package:letdem/core/constants/colors.dart';
import 'package:letdem/core/constants/typo.dart';

class StyledAppBar extends StatelessWidget {
  final String title;
  final IconData icon;

  final VoidCallback? onTap;

  final Widget? suffix;

  const StyledAppBar(
      {super.key,
      required this.title,
      required this.icon,
      this.onTap,
      this.suffix});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Typo.heading4,
          ),
          Stack(
            children: [
              GestureDetector(
                onTap: onTap,
                child: CircleAvatar(
                  radius: 21,
                  backgroundColor: AppColors.neutral50,
                  child: Icon(
                    icon,
                    color: AppColors.neutral500,
                  ),
                ),
              ),
              if (suffix != null)
                Positioned(
                  right: 0,
                  top: 0,
                  child: suffix!,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
