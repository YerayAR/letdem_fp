import 'package:flutter/material.dart';
import 'package:letdem/constants/ui/dimens.dart';

class StyledBody extends StatelessWidget {
  final List<Widget> children;
  final bool isBottomPadding;
  final MainAxisAlignment? mainAxisAlignment;
  final CrossAxisAlignment? crossAxisAlignment;

  const StyledBody({
    super.key,
    required this.children,
    this.isBottomPadding = false,
    this.mainAxisAlignment,
    this.crossAxisAlignment,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: Dimens.defaultMargin,
        left: Dimens.defaultMargin,
        bottom: isBottomPadding ? Dimens.defaultMargin : 0,
        right: Dimens.defaultMargin,
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: crossAxisAlignment ?? CrossAxisAlignment.start,
          mainAxisAlignment: mainAxisAlignment ?? MainAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }
}
