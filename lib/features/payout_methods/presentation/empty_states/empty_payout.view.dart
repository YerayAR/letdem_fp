import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:letdem/core/constants/assets.dart';
import 'package:letdem/core/constants/colors.dart';
import 'package:letdem/core/extensions/locale.dart';

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
            child: SvgPicture.asset(
              AppAssets.bank,
              width: 40,
              height: 40,
              color: AppColors.primary500,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            context.l10n.noPayoutMethodsYet,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            context.l10n.payoutMethodsDescription,
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
