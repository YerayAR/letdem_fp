import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconly/iconly.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:letdem/common/popups/multi_selector.popup.dart';
import 'package:letdem/common/popups/popup.dart';
import 'package:letdem/common/widgets/button.dart';
import 'package:letdem/common/widgets/textfield.dart';
import 'package:letdem/core/constants/colors.dart';
import 'package:letdem/core/constants/dimens.dart';
import 'package:letdem/core/constants/typo.dart';
import 'package:letdem/core/extensions/locale.dart';
import 'package:letdem/core/extensions/user.dart';
import 'package:letdem/features/activities/presentation/bottom_sheets/add_event_sheet.widget.dart';
import 'package:letdem/features/activities/presentation/widgets/no_car_registered.widget.dart';
import 'package:letdem/features/activities/presentation/widgets/search/search_bottom_sheet.widget.dart';
import 'package:letdem/features/car/car_bloc.dart';
import 'package:letdem/features/earning_account/presentation/views/connect_account.view.dart';
import 'package:letdem/infrastructure/services/res/navigator.dart';

import '../../../../infrastructure/services/mapbox_search/models/service.dart';
import '../../../map/presentation/views/publish_space/publish_space.view.dart';

class HomeMapBottomSection extends StatelessWidget {
  const HomeMapBottomSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.all(Dimens.defaultMargin),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 1,
              blurRadius: 7,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Dimens.space(2),
            GestureDetector(
              onTap: () async {
                AppPopup.showBottomSheet(context, const MapSearchBottomSheet());
              },
              child: AbsorbPointer(
                child: TextInputField(
                  label: null,
                  onChanged: (value) async {
                    MapboxSearchApiService()
                        .getLocationResults(value, context)
                        .then((value) {
                      for (var element in value) {
                        debugPrint(element.fullAddress);
                      }
                    });
                  },
                  prefixIcon: IconlyLight.search,
                  placeHolder: context.l10n.enterDestination,
                ),
              ),
            ),
            Dimens.space(2),
            GestureDetector(
              onTap: () {},
              child: Text(
                context.l10n.whatDoYouWantToDo,
                style: Typo.largeBody.copyWith(fontWeight: FontWeight.w500),
              ),
            ),
            Dimens.space(2),
            Row(
              children: [
                Flexible(
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
                                  bool isCarExist = context
                                          .read<CarBloc>()
                                          .state is CarLoaded &&
                                      (context.read<CarBloc>().state
                                                  as CarLoaded)
                                              .car !=
                                          null;

                                  if (!isCarExist) {
                                    AppPopup.showBottomSheet(
                                        context,
                                        SizedBox(
                                          child: Container(
                                            padding: EdgeInsets.all(
                                                Dimens.defaultMargin),
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
                                                  padding:
                                                      const EdgeInsets.all(22),
                                                  child: Container(
                                                    width: 70,
                                                    height: 70,
                                                    decoration: BoxDecoration(
                                                      color:
                                                          AppColors.primary500,
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
                                                  context.l10n
                                                      .createCarProfileFirst,
                                                  textAlign: TextAlign.center,
                                                  style:
                                                      Typo.mediumBody.copyWith(
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
                                                    text:
                                                        context.l10n.continuee,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ));
                                    return;
                                  }

                                  var isPaidAccountExist =
                                      context.userProfile!.earningAccount !=
                                          null;

                                  if (!isPaidAccountExist) {
                                    AppPopup.showBottomSheet(
                                        context,
                                        SizedBox(
                                          child: Container(
                                            padding: EdgeInsets.all(
                                                Dimens.defaultMargin),
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
                                                  padding:
                                                      const EdgeInsets.all(22),
                                                  child: Container(
                                                    width: 70,
                                                    height: 70,
                                                    decoration: BoxDecoration(
                                                      color:
                                                          AppColors.primary500,
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
                                                  context.l10n
                                                      .createEarningAccountFirst,
                                                  textAlign: TextAlign.center,
                                                  style:
                                                      Typo.mediumBody.copyWith(
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
                                                    text:
                                                        context.l10n.continuee,
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
                                            padding: EdgeInsets.all(
                                                Dimens.defaultMargin),
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
                                                  padding:
                                                      const EdgeInsets.all(22),
                                                  child: Container(
                                                    width: 70,
                                                    height: 70,
                                                    decoration: BoxDecoration(
                                                      color:
                                                          AppColors.primary500,
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
                                                  style:
                                                      Typo.mediumBody.copyWith(
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
                                          isPaid: true, file: File(image.path)),
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
                Flexible(
                  child: PrimaryButton(
                    outline: true,
                    background: AppColors.primary50,
                    borderColor: Colors.transparent,
                    onTap: () {
                      AppPopup.showBottomSheet(
                          context, const AddEventBottomSheet());
                    },
                    icon: IconlyBold.star,
                    color: AppColors.primary500,
                    text: context.l10n.publishEvent,
                  ),
                ),
              ],
            ),
            Dimens.space(2),
          ],
        ),
      ),
    );
  }
}
