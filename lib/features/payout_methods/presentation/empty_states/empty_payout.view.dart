import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:letdem/core/constants/colors.dart';

class EmptyPayoutMethodView extends StatelessWidget {
  const EmptyPayoutMethodView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white,
            child: Icon(
              Iconsax
                  .card5, // You can use Iconsax.wallet or Iconsax.bank as well
              size: 40,
              color: AppColors.primary500,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'No Payout Methods Yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Your added payout methods will appear\nhere once you set them up in your profile',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.neutral400,
            ),
          ),
        ],
      ),
    );
  }
}
