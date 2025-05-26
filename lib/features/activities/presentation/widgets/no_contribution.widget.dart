import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:letdem/common/popups/multi_selector.popup.dart';
import 'package:letdem/common/popups/popup.dart';
import 'package:letdem/common/widgets/button.dart';
import 'package:letdem/core/constants/colors.dart';
import 'package:letdem/core/constants/dimens.dart';
import 'package:letdem/core/constants/typo.dart';
import 'package:letdem/core/extensions/locale.dart';
import 'package:letdem/infrastructure/services/res/navigator.dart';
import 'package:letdem/views/app/publish_space/screens/publish_space.view.dart';

class NoContributionsWidget extends StatelessWidget {
  const NoContributionsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Spacer(),
        Text(
          "No Contributions Yet",
          style: Typo.largeBody.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        Dimens.space(2),
        Text(
          "Your Contributions history will appear\nhere, Publish to see them",
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
                        backgroundColor: AppColors.green50,
                        icon: Icons.done,
                        iconColor: AppColors.green500,
                        text: "Regular Space",
                        onTap: () async {
                          XFile? image = kDebugMode
                              ? await imagePicker.pickImage(
                                  source: ImageSource.gallery)
                              : await imagePicker.pickImage(
                                  source: ImageSource.camera);
                          if (image != null) {
                            NavigatorHelper.to(
                              PublishSpaceScreen(
                                  isPaid: false, file: File(image.path)),
                            );
                          }
                        },
                      ),
                      const Divider(color: Colors.grey, height: 1),
                      MultiSelectItem(
                        backgroundColor: AppColors.secondary50,
                        icon: Icons.close,
                        iconColor: AppColors.secondary600,
                        text: "Paid Space",
                        onTap: () async {
                          XFile? image = kDebugMode
                              ? await imagePicker.pickImage(
                                  source: ImageSource.gallery)
                              : await imagePicker.pickImage(
                                  source: ImageSource.camera);
                          if (image != null) {
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
            text: 'Publish Space',
          ),
        ),
        Dimens.space(1),
        const Spacer(),
      ],
    );
  }
}
