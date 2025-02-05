import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:iconsax/iconsax.dart';
import 'package:letdem/constants/ui/colors.dart';
import 'package:letdem/constants/ui/dimens.dart';
import 'package:letdem/constants/ui/typo.dart';
import 'package:letdem/global/widgets/chip.dart';
import 'package:letdem/views/app/activities/screens/activities.view.dart';

class ContributionItem extends StatelessWidget {
  final ContributionType type;

  final bool showDivider;
  const ContributionItem(
      {super.key, required this.type, this.showDivider = true});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: <Widget>[
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: type == ContributionType.space
                        ? AppColors.primary50.withOpacity(0.5)
                        : AppColors.green50,
                    child: Icon(
                      type == ContributionType.space
                          ? Iconsax.location5
                          : IconlyBold.star,
                      color: type == ContributionType.space
                          ? AppColors.primary400
                          : AppColors.green600,
                    ),
                  ),
                  Dimens.space(2),
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Space Published",
                          style: Typo.largeBody.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Dimens.space(1),
                        Row(
                          spacing: 5,
                          children: [
                            Text(
                              "12 Jan. 2025",
                              style: Typo.mediumBody.copyWith(
                                color: AppColors.neutral400,
                              ),
                            ),
                            CircleAvatar(
                              radius: 3,
                              backgroundColor: AppColors.neutral200,
                            ),
                            Text(
                              "12:00 PM",
                              style: Typo.mediumBody.copyWith(
                                color: AppColors.neutral400,
                              ),
                            ),
                          ],
                        ),
                      ]),
                ],
              ),
              DecoratedChip(
                backgroundColor: AppColors.secondary50,
                text: '+2 Pts',
                textStyle: Typo.smallBody.copyWith(
                  color: AppColors.secondary600,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
                icon: Iconsax.cup5,
                color: AppColors.secondary600,
              ),
            ],
          ),
          Column(
            children: !showDivider
                ? []
                : [
                    Dimens.space(1),
                    Divider(
                      color: AppColors.neutral50,
                      thickness: 1,
                    ),
                  ],
          ),
        ],
      ),
    );
  }
}
