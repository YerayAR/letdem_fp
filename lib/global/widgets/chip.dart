import 'package:flutter/material.dart';
import 'package:letdem/constants/ui/dimens.dart';
import 'package:letdem/constants/ui/typo.dart';

class DecoratedChip extends StatelessWidget {
  final String text;
  final Color color;

  final Color? backgroundColor;

  final double? textSize;
  final IconData? icon;

  final TextStyle? textStyle;

  final VoidCallback? onTap;

  final EdgeInsetsGeometry? padding;

  const DecoratedChip({
    super.key,
    required this.text,
    this.padding,
    this.onTap,
    required this.color,
    this.backgroundColor,
    this.textSize,
    this.icon,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: FittedBox(
        child: Container(
          padding: padding ??
              EdgeInsets.symmetric(
                horizontal: Dimens.baseSize * 2,
                vertical: Dimens.baseSize,
              ),
          decoration: BoxDecoration(
            color: backgroundColor ??
                color.withOpacity(0.1), // Adjust the opacity as needed
            borderRadius: BorderRadius.circular(1000),
          ),
          child: Center(
            child: Row(
              children: [
                SizedBox(
                  child: icon == null
                      ? null
                      : Row(
                          children: [
                            Icon(
                              icon,
                              size: 14,
                              color: color,
                            ),
                            Dimens.space(1)
                          ],
                        ),
                ),
                Text(
                  text,
                  style: textStyle ??
                      Typo.smallBody.copyWith(
                        color: color,
                        fontSize: textSize ?? 12,
                        fontWeight: FontWeight.w700,
                      ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.clip,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ChipWidget extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  const ChipWidget({super.key, required this.child, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: Dimens.defaultMargin / 1.5,
          vertical: Dimens.defaultMargin / 2,
        ),
        decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  offset: const Offset(1, 1),
                  spreadRadius: 10,
                  blurRadius: 20)
            ],
            color: Colors.white,
            borderRadius: const BorderRadius.all(
              Radius.circular(40),
            )),
        child: child,
      ),
    );
  }
}
