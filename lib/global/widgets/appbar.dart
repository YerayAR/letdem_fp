import 'package:flutter/material.dart';
import 'package:letdem/constants/ui/colors.dart';
import 'package:letdem/constants/ui/typo.dart';

class StyledAppBar extends StatelessWidget {
  final String title;
  final IconData icon;

  const StyledAppBar({super.key, required this.title, required this.icon});

  Widget build(BuildContext context) {
    return SafeArea(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Typo.heading4,
          ),
          CircleAvatar(
            radius: 23,
            backgroundColor: AppColors.neutral50,
            child: Icon(
              icon,
              color: AppColors.neutral500,
            ),
          ),
        ],
      ),
    );
  }
}
