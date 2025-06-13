import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:letdem/common/widgets/chip.dart';
import 'package:letdem/core/constants/colors.dart';
import 'package:letdem/core/constants/dimens.dart';
import 'package:letdem/core/constants/typo.dart';
import 'package:letdem/features/payout_methods/repository/payout.repository.dart';

class OptionItem extends StatelessWidget {
  final PayoutMethod method;
  final void Function()? onTap;

  final bool isSelectable;
  final bool? isSelected;

  const OptionItem({
    super.key,
    required this.method,
    this.isSelectable = false,
    this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (isSelectable) {
          onTap!();
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.primary50.withOpacity(0.5),
                    radius: 26,
                    child: Center(
                      child: Icon(
                        Iconsax.building,
                        color: AppColors.primary500,
                        size: 24,
                      ),
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      if (onTap != null) {
                        onTap!();
                      }
                    },
                    child: isSelectable
                        ? CircleAvatar(
                            backgroundColor: isSelected == true
                                ? AppColors.primary500
                                : AppColors.neutral50,
                            radius: 12,
                            child: Icon(
                              Icons.check,
                              color: isSelected == true
                                  ? Colors.white
                                  : AppColors.neutral200,
                              size: 16,
                            ),
                          )
                        : Icon(
                            Icons.more_horiz,
                            color: AppColors.neutral200,
                          ),
                  ),
                ],
              ),
              Dimens.space(2),
              SizedBox(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          method.accountNumber,
                          style: Typo.mediumBody.copyWith(
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                          ),
                        ),
                        const Spacer(),
                        if (method.isDefault)
                          DecoratedChip(
                            text: 'Default',
                            textSize: 10,
                            color: AppColors.secondary600,
                          )
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      method.accountHolderName,
                      style: Typo.smallBody
                          .copyWith(color: AppColors.neutral400, fontSize: 15),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
