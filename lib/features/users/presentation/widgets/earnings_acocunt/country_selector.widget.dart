import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:letdem/core/constants/colors.dart';
import 'package:letdem/core/constants/typo.dart';
import 'package:letdem/features/users/presentation/views/connect_account/connect_account.view.dart';

class CountrySelectionPage extends StatelessWidget {
  final VoidCallback onNext;

  const CountrySelectionPage({
    super.key,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select Country',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          Text(
            'Select your country of residence to continue',
            style: TextStyle(fontSize: 14, color: AppColors.neutral600),
          ),
          const SizedBox(height: 30),
          Text(
            'Select Country',
            style: TextStyle(fontSize: 16, color: AppColors.neutral600),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColors.neutral100,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(30),
            ),
            child: ListTile(
              leading: const Icon(Iconsax.location),
              title: Text(
                'Spain',
                style: Typo.mediumBody.copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppColors.neutral600,
                ),
              ),
              trailing: const Icon(Icons.keyboard_arrow_down),
            ),
          ),
          const Spacer(),
          buildNextButton(context, onNext),
        ],
      ),
    );
  }
}
