import 'package:flutter/material.dart';
import 'package:letdem/constants/ui/colors.dart';
import 'package:letdem/constants/ui/dimens.dart';
import 'package:letdem/constants/ui/typo.dart';

class ProfileSection extends StatelessWidget {
  final List<Widget> child;
  final String? title;

  final void Function()? onCallToAction;

  final EdgeInsetsGeometry? padding;

  final String? callToAction;
  const ProfileSection({
    super.key,
    required this.child,
    this.title,
    this.callToAction,
    this.padding,
    this.onCallToAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null)
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title!,
                      style:
                          Typo.largeBody.copyWith(fontWeight: FontWeight.w700),
                    ),
                    if (callToAction != null)
                      GestureDetector(
                        onTap: onCallToAction,
                        child: Text(
                          callToAction!,
                          style: Typo.mediumBody.copyWith(
                            color: AppColors.primary400,
                            fontWeight: FontWeight.w500,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                  ],
                ),
                Dimens.space(2),
              ],
            ),
          ...child,
        ],
      ),
    );
  }
}
