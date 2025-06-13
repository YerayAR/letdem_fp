import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:letdem/common/widgets/chip.dart';
import 'package:letdem/core/constants/colors.dart';
import 'package:letdem/core/constants/dimens.dart';
import 'package:letdem/core/constants/typo.dart';
import 'package:letdem/core/extensions/locale.dart';
import 'package:letdem/features/activities/models/activity.model.dart';
import 'package:letdem/features/activities/presentation/views/activities.view.dart';

class ContributionItem extends StatelessWidget {
  final ContributionType type;

  final Activity activity;

  final bool showDivider;
  final bool showBackground;
  const ContributionItem({
    super.key,
    required this.type,
    this.showDivider = true,
    required this.activity,
    this.showBackground = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: showBackground ? 3 : 7),
      child: Container(
        padding: showBackground
            ? const EdgeInsets.symmetric(horizontal: 15, vertical: 15)
            : const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
        decoration: BoxDecoration(
          color: showBackground ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
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
                            type == ContributionType.space
                                ? context.l10n.spacePublished
                                : context.l10n.eventPublished,
                            style: Typo.largeBody.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Dimens.space(1),
                          Row(
                            spacing: 5,
                            children: [
                              Text(
                                DateFormat("dd MMM. yyyy").format(
                                  (activity.created.toLocal()),
                                ),
                                // "12 Jan. 2025",
                                style: Typo.mediumBody.copyWith(
                                  fontSize: 14,
                                  color: AppColors.neutral400,
                                ),
                              ),
                              CircleAvatar(
                                radius: 3,
                                backgroundColor: AppColors.neutral200,
                              ),
                              Text(
                                DateFormat("HH:mm").format(
                                  (activity.created.toLocal()),
                                ),
                                style: Typo.mediumBody.copyWith(
                                  fontSize: 14,
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
                  text: context.l10n.pointsEarned(activity.points as String),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 7),
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
              children: !showDivider || showBackground
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
      ),
    );
  }
}
