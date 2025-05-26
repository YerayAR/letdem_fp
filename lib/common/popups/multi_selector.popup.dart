import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:letdem/core/constants/colors.dart';
import 'package:letdem/core/constants/dimens.dart';
import 'package:letdem/core/constants/typo.dart';

class MultiSelectItem extends StatelessWidget {
  final Color backgroundColor;
  final IconData icon;
  final Color iconColor;
  final String text;
  final VoidCallback onTap;

  const MultiSelectItem({
    super.key,
    required this.backgroundColor,
    required this.icon,
    required this.iconColor,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          CircleAvatar(
            radius: 17,
            backgroundColor: backgroundColor,
            child: Icon(
              icon,
              color: iconColor,
              size: 17,
            ),
          ),
          Dimens.space(1),
          Text(
            text,
            style: Typo.largeBody.copyWith(
              fontSize: 17,
              fontWeight: FontWeight.w500,
              color: AppColors.neutral600,
            ),
          ),
        ],
      ),
    );
  }
}

class MultiSelectPopup extends StatelessWidget {
  final String title;
  final List<Widget> items;
  final bool isLoading;

  const MultiSelectPopup({
    super.key,
    required this.title,
    required this.items,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(Dimens.defaultMargin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: [
              Text(
                title,
                style: Typo.largeBody
                    .copyWith(fontWeight: FontWeight.w700, fontSize: 18),
              ),
              Dimens.space(1),
              if (isLoading) const CupertinoActivityIndicator(),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(
                  Iconsax.close_circle5,
                  color: AppColors.neutral100,
                ),
              ),
            ],
          ),
          Dimens.space(3),
          ...items.expand((item) => [item, Dimens.space(2)]),
        ],
      ),
    );
  }
}
