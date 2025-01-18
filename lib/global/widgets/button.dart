import 'dart:math'; // Import for random number generation

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:letdem/constants/ui/colors.dart';
import 'package:letdem/constants/ui/dimens.dart';
import 'package:letdem/global/widgets/loader.dart';

class PrimaryButton extends StatelessWidget {
  final Color? color;
  final bool outline;
  final String text;
  final double? borderWidth;
  final VoidCallback? onTap;
  final bool isLoading;
  final bool isDisabled;

  final Color? borderColor;
  final Color? loadingIndicatorColor;
  final IconData? iconRight;
  final IconData? icon;
  final Widget? widgetImage;

  const PrimaryButton({
    super.key,
    this.color,
    this.borderWidth,
    this.outline = false,
    required this.text,
    this.onTap,
    this.iconRight,
    this.isLoading = false,
    this.isDisabled = false,
    this.borderColor,
    this.loadingIndicatorColor,
    this.icon,
    this.widgetImage,
  });

  @override
  Widget build(BuildContext context) {
    final List<String> loadingTexts = [
      'Loading...',
      'Please wait...',
      'Almost there...',
      'Hang tight...',
      'Processing...',
      'Getting things ready...',
      'Just a moment...',
      'We’re on it...',
      'Fetching data...',
      'Hold tight...',
      'Preparing things...',
      'Stay tuned...',
      'Working on it...',
      'We’ll be right with you...',
      'One moment please...',
      'Making magic happen...',
      'Crunching the numbers...',
      'Loading your experience...',
      'Putting the pieces together...',
      'Warming things up...',
      'Good things take time...',
      'Hang on, we’re close...',
      'Checking the details...',
      'Things are moving...',
      'Preparing the next step...',
      'Processing your request...',
      'Bringing everything together...',
      'Finalizing things...',
      'Getting your data ready...',
      'Almost done...',
    ];

    final randomLoadingText =
        loadingTexts[Random().nextInt(loadingTexts.length)];

    return InkWell(
      onTap: () {
        if (isLoading && onTap == null) {
          return;
        } else {
          if (isDisabled) {
            return;
          }
          HapticFeedback.heavyImpact();
          onTap!();
        }
      },
      child: Container(
        height: 55,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10000),
          color: outline ? Colors.transparent : color ?? AppColors.primary500,
          border: outline
              ? Border.all(
                  color: borderColor ?? AppColors.primary500,
                  width: borderWidth != null
                      ? borderWidth!
                      : icon == null
                          ? 2
                          : 1)
              : null,
        ),
        child: Center(
          child: isLoading
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    LoadingIndicator(
                      color: loadingIndicatorColor ?? Colors.white,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      randomLoadingText,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: widgetImage != null
                          ? [widgetImage!, Dimens.space(1)]
                          : icon != null
                              ? [
                                  Icon(
                                    icon,
                                    color: outline
                                        ? color ?? AppColors.primary500
                                        : Colors.white,
                                    size: 18,
                                  ),
                                  Dimens.space(1)
                                ]
                              : [],
                    ),
                    Text(
                      text,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight:
                            icon != null ? FontWeight.w700 : FontWeight.w500,
                        color: isDisabled
                            ? Colors.white.withOpacity(0.8)
                            : outline
                                ? color ?? AppColors.primary500
                                : Colors.white,
                      ),
                    ),
                    Row(
                      children: iconRight != null
                          ? [
                              Dimens.space(1),
                              Icon(
                                iconRight,
                                color: isDisabled
                                    ? Colors.white.withOpacity(0.8)
                                    : outline
                                        ? color ?? AppColors.primary500
                                        : Colors.white,
                                size: 18,
                              ),
                            ]
                          : [],
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
