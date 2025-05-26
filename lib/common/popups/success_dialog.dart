import 'package:flutter/material.dart';
import 'package:letdem/common/widgets/button.dart';
import 'package:letdem/constants/ui/colors.dart';
import 'package:letdem/constants/ui/dimens.dart';
import 'package:letdem/constants/ui/typo.dart';

class SuccessDialog extends StatelessWidget {
  final String title;
  final String subtext;
  final VoidCallback? onProceed;
  final bool isLoading;

  final String? buttonText;

  final IconData? icon;

  const SuccessDialog({
    super.key,
    required this.title,
    this.buttonText,
    required this.subtext,
    this.onProceed,
    this.isLoading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        CircleAvatar(
          radius: 45,
          backgroundColor: AppColors.green50,
          child: Icon(
            icon ?? Icons.done,
            size: 45,
            color: AppColors.green600,
          ),
        ),
        Dimens.space(3),
        Text(
          title,
          textAlign: TextAlign.center,
          style: Typo.heading4.copyWith(color: AppColors.neutral600),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            subtext,
            textAlign: TextAlign.center,
            style: Typo.mediumBody.copyWith(color: AppColors.neutral400),
          ),
        ),
        Dimens.space(5),
        PrimaryButton(
          isLoading: isLoading,
          onTap: onProceed,
          text: buttonText ?? 'Proceed',
        ),
      ],
    );
  }
}
