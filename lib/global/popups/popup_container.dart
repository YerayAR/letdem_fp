import 'package:flutter/material.dart';
import 'package:letdem/constants/ui/dimens.dart';

class PopupContainer extends StatelessWidget {
  final Widget child;
  final bool bottomSheet;
  final bool smallPadding;

  const PopupContainer({
    super.key,
    required this.child,
    this.bottomSheet = false,
    this.smallPadding = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Wrap(
        children: [
          Padding(
            padding: bottomSheet
                ? const EdgeInsets.all(0)
                : EdgeInsets.all(smallPadding
                    ? Dimens.defaultMargin / 20
                    : Dimens.defaultMargin),
            child: Container(
              padding: bottomSheet
                  ? EdgeInsets.symmetric(
                      vertical: Dimens.defaultMargin,
                      horizontal: Dimens.defaultMargin / 2,
                    )
                  : EdgeInsets.all(Dimens.defaultMargin * 2),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(
                  Dimens.defaultRadius * 1.5,
                ),
              ),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}
