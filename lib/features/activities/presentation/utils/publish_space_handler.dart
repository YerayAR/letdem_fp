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
import 'package:letdem/features/activities/presentation/views/spaces/reserved_space.view.dart';
import 'package:letdem/features/activities/presentation/widgets/no_car_registered.widget.dart';
import 'package:letdem/features/car/car_bloc.dart';
import 'package:letdem/features/map/presentation/views/publish_space/publish_space.view.dart';
import 'package:letdem/infrastructure/services/earnings/eranings.service.dart';
import 'package:letdem/infrastructure/services/res/navigator.dart';

class PublishSpaceHandler {
  static final ImagePicker _imagePicker = ImagePicker();

  static bool preCheck(BuildContext context) {
    final carState = context.read<CarBloc>().state;
    final isCarExist = carState is CarLoaded && carState.car != null;
    final activeReservation = context.userProfile?.activeReservation != null;

    if (activeReservation) {
      _showInfoPopup(
        context,
        context.l10n.importantNotice,
        context.l10n.activeReservationExists,
        () => NavigatorHelper.to(ReservedSpaceDetailView(
          details: context.userProfile!.activeReservation!,
          space: context.userProfile!.activeReservation!.space,
        )),
        context.l10n.viewDetails,
      );
      return false;
    }

    bool isSuccess = false;

    if (!isCarExist) {
      _showInfoPopup(
        context,
        context.l10n.importantNotice,
        context.l10n.createCarProfileFirst,
        () => NavigatorHelper.to(const RegisterCarView()),
      );
      return false;
    }

    final earningAccount = context.userProfile?.earningAccount;
    EarningAccountService.handleEarningAccountTap(
      context: context,
      earningAccount: earningAccount,
      onSuccess: () {
        isSuccess = true;
      },
    );

    return isSuccess;
  }

  static void showSpaceOptions(BuildContext context, void Function() onAdded) {
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
              // if (!preCheck(context)) return;

              final XFile? image = await _pickImage();
              if (image != null) {
                NavigatorHelper.to(
                  PublishSpaceScreen(
                    onAdded: onAdded,
                    isPaid: false,
                    file: File(image.path),
                  ),
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
              if (!preCheck(context)) return;

              final XFile? image = await _pickImage();
              if (image != null) {
                NavigatorHelper.pop();
                NavigatorHelper.to(
                  PublishSpaceScreen(
                    onAdded: onAdded,
                    isPaid: true,
                    file: File(image.path),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  static Future<XFile?> _pickImage() {
    return kDebugMode
        ? _imagePicker.pickImage(source: ImageSource.gallery)
        : _imagePicker.pickImage(source: ImageSource.camera);
  }

  static void _showInfoPopup(BuildContext context, String title, String message,
      VoidCallback onContinue,
      [String? continueText]) {
    AppPopup.showBottomSheet(
      context,
      Container(
        padding: EdgeInsets.all(Dimens.defaultMargin),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: AppColors.primary500.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(22),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.primary500,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child:
                      Icon(Icons.priority_high, color: Colors.white, size: 32),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: Typo.heading4.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Typo.mediumBody.copyWith(color: AppColors.neutral500),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: PrimaryButton(
                onTap: onContinue,
                text: continueText ?? context.l10n.continuee,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
