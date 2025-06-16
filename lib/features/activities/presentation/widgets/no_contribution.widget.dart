import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:letdem/common/popups/multi_selector.popup.dart';
import 'package:letdem/common/popups/popup.dart';
import 'package:letdem/common/widgets/button.dart';
import 'package:letdem/core/constants/colors.dart';
import 'package:letdem/core/constants/dimens.dart';
import 'package:letdem/core/constants/typo.dart';
import 'package:letdem/core/extensions/locale.dart';
import 'package:letdem/core/extensions/user.dart';
import 'package:letdem/features/activities/presentation/widgets/no_car_registered.widget.dart';
import 'package:letdem/features/car/car_bloc.dart';
import 'package:letdem/features/earning_account/presentation/views/connect_account.view.dart';
import 'package:letdem/features/map/presentation/views/publish_space/publish_space.view.dart';
import 'package:letdem/infrastructure/services/res/navigator.dart';

class NoContributionsWidget extends StatelessWidget {
  const NoContributionsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Spacer(),
        Text(
          context.l10n.noContributions,
          style: Typo.largeBody.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        Dimens.space(2),
        Text(
          context.l10n.noContributionsDescription,
          style: Typo.mediumBody.copyWith(color: AppColors.neutral400),
          textAlign: TextAlign.center,
        ),
        Dimens.space(2),
        SizedBox(
          width: MediaQuery.of(context).size.width / 1.9,
          child: PrimaryButton(
            onTap: () async {
              ImagePicker imagePicker = ImagePicker();

              AppPopup.showBottomSheet(
                  context,
                  MultiSelectPopup(
                    title: context.l10n.publishSpace,
                    items: [
                      MultiSelectItem(
                        backgroundColor: AppColors.primary50,
                        icon: Iconsax.location,
                        iconColor: AppColors.primary500,
                        text: context.l10n.regularSpace,
                        onTap: () async {
                          XFile? image = kDebugMode
                              ? await imagePicker.pickImage(
                                  source: ImageSource.gallery)
                              : await imagePicker.pickImage(
                                  source: ImageSource.camera);
                          if (image != null) {
                            NavigatorHelper.to(
                              PublishSpaceScreen(
                                  onAdded: () {},
                                  isPaid: false,
                                  file: File(image.path)),
                            );
                          }
                        },
                      ),
                      Divider(color: AppColors.neutral50, height: 1),
                      MultiSelectItem(
                        backgroundColor: AppColors.secondary50,
                        icon: Iconsax.money,
                        iconColor: AppColors.secondary600,
                        text: context.l10n.paidSpace,
                        onTap: () async {
                          bool isCarExist =
                              context.read<CarBloc>().state is CarLoaded &&
                                  (context.read<CarBloc>().state as CarLoaded)
                                          .car !=
                                      null;

                          if (!isCarExist) {
                            AppPopup.showBottomSheet(
                                context,
                                SizedBox(
                                  child: Container(
                                    padding:
                                        EdgeInsets.all(Dimens.defaultMargin),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // Alert icon in purple circle
                                        Container(
                                          width: 90,
                                          height: 90,
                                          decoration: BoxDecoration(
                                            color: AppColors.primary500
                                                .withOpacity(0.1),
                                            shape: BoxShape.circle,
                                          ),
                                          padding: const EdgeInsets.all(22),
                                          child: Container(
                                            width: 70,
                                            height: 70,
                                            decoration: BoxDecoration(
                                              color: AppColors.primary500,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Center(
                                              child: Icon(
                                                Icons.priority_high,
                                                color: Colors.white,
                                                size: 32,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 24),

                                        // Important Notice text
                                        Text(
                                          context.l10n.importantNotice,
                                          style: Typo.heading4.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 16),

                                        // Description text
                                        Text(
                                          context.l10n.createCarProfileFirst,
                                          textAlign: TextAlign.center,
                                          style: Typo.mediumBody.copyWith(
                                            color: AppColors.neutral500,
                                          ),
                                        ),
                                        const SizedBox(height: 32),

                                        // Continue button
                                        SizedBox(
                                          width: double.infinity,
                                          child: PrimaryButton(
                                            onTap: () {
                                              NavigatorHelper.pop();
                                            },
                                            text: context.l10n.continuee,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ));
                            return;
                          }

                          var isPaidAccountExist =
                              context.userProfile!.earningAccount != null;

                          if (!isPaidAccountExist) {
                            AppPopup.showBottomSheet(
                                context,
                                SizedBox(
                                  child: Container(
                                    padding:
                                        EdgeInsets.all(Dimens.defaultMargin),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // Alert icon in purple circle
                                        Container(
                                          width: 90,
                                          height: 90,
                                          decoration: BoxDecoration(
                                            color: AppColors.primary500
                                                .withOpacity(0.1),
                                            shape: BoxShape.circle,
                                          ),
                                          padding: const EdgeInsets.all(22),
                                          child: Container(
                                            width: 70,
                                            height: 70,
                                            decoration: BoxDecoration(
                                              color: AppColors.primary500,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Center(
                                              child: Icon(
                                                Icons.priority_high,
                                                color: Colors.white,
                                                size: 32,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 24),

                                        // Important Notice text
                                        Text(
                                          context.l10n.importantNotice,
                                          style: Typo.heading4.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 16),

                                        // Description text
                                        Text(
                                          context
                                              .l10n.createEarningAccountFirst,
                                          textAlign: TextAlign.center,
                                          style: Typo.mediumBody.copyWith(
                                            color: AppColors.neutral500,
                                          ),
                                        ),
                                        const SizedBox(height: 32),

                                        // Continue button
                                        SizedBox(
                                          width: double.infinity,
                                          child: PrimaryButton(
                                            onTap: () {
                                              NavigatorHelper.pop();
                                              NavigatorHelper.to(
                                                const ConnectAccountView(
                                                  status: null,
                                                  remainingStep: null,
                                                ),
                                              );
                                            },
                                            text: context.l10n.continuee,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ));
                            return;
                          }
                          if (!isCarExist) {
                            AppPopup.showBottomSheet(
                                context,
                                SizedBox(
                                  child: Container(
                                    padding:
                                        EdgeInsets.all(Dimens.defaultMargin),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // Alert icon in purple circle
                                        Container(
                                          width: 90,
                                          height: 90,
                                          decoration: BoxDecoration(
                                            color: AppColors.primary500
                                                .withOpacity(0.1),
                                            shape: BoxShape.circle,
                                          ),
                                          padding: const EdgeInsets.all(22),
                                          child: Container(
                                            width: 70,
                                            height: 70,
                                            decoration: BoxDecoration(
                                              color: AppColors.primary500,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Center(
                                              child: Icon(
                                                Icons.priority_high,
                                                color: Colors.white,
                                                size: 32,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 24),

                                        // Important Notice text
                                        Text(
                                          'Important Notice',
                                          style: Typo.heading4.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 16),

                                        // Description text
                                        Text(
                                          'You need to create a car profile to publish a paid space. Please create a car profile first.',
                                          textAlign: TextAlign.center,
                                          style: Typo.mediumBody.copyWith(
                                            color: AppColors.neutral500,
                                          ),
                                        ),
                                        const SizedBox(height: 32),

                                        // Continue button
                                        SizedBox(
                                          width: double.infinity,
                                          child: PrimaryButton(
                                            onTap: () {
                                              NavigatorHelper.pop();
                                              NavigatorHelper.to(
                                                const RegisterCarView(),
                                              );
                                            },
                                            text: 'Continue',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ));
                            return;
                          }
                          XFile? image = kDebugMode
                              ? await imagePicker.pickImage(
                                  source: ImageSource.gallery)
                              : await imagePicker.pickImage(
                                  source: ImageSource.camera);
                          if (image != null) {
                            NavigatorHelper.pop();

                            NavigatorHelper.to(
                              PublishSpaceScreen(
                                  onAdded: () {},
                                  isPaid: true,
                                  file: File(image.path)),
                            );
                          }
                        },
                      ),
                    ],
                  ));
            },
            icon: Iconsax.location5,
            text: context.l10n.publishSpace,
          ),
        ),
        Dimens.space(1),
        const Spacer(),
      ],
    );
  }
}
