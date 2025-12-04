import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:letdem/core/constants/colors.dart';

class MarketplaceCartIconButton extends StatelessWidget {
  final VoidCallback onTap;

  const MarketplaceCartIconButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: 21,
        backgroundColor: AppColors.neutral50,
        child: Icon(
          Iconsax.shopping_cart,
          color: AppColors.neutral500,
        ),
      ),
    );
  }
}
