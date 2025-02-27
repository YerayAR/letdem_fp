import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:letdem/constants/ui/colors.dart';
import 'package:letdem/constants/ui/dimens.dart';
import 'package:letdem/constants/ui/typo.dart';
import 'package:letdem/global/popups/popup.dart';
import 'package:letdem/global/widgets/button.dart';
import 'package:letdem/services/mapbox_search/models/service.dart';
import 'package:letdem/services/res/navigator.dart';
import 'package:letdem/views/app/home/widgets/home/bottom_sheet/add_event_sheet.widget.dart';
import 'package:letdem/views/app/home/widgets/search/search_bottom_sheet.widget.dart';
import 'package:letdem/views/app/publish_space/screens/publish_space.view.dart';

import '../../../../../global/widgets/textfield.dart';

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
                        .getLocationResults(value)
                        .then((value) {
                      for (var element in value) {
                        debugPrint(element.fullAddress);
                      }
                    });
                  },
                  prefixIcon: IconlyLight.search,
                  placeHolder: 'Enter destination',
                ),
              ),
            ),
            Dimens.space(2),
            Text(
              "What do you want to do?",
              style: Typo.largeBody.copyWith(fontWeight: FontWeight.w500),
            ),
            Dimens.space(2),
            Row(
              children: [
                Flexible(
                  child: PrimaryButton(
                    onTap: () async {
                      ImagePicker imagePicker = ImagePicker();
                      XFile? image = kDebugMode
                          ? await imagePicker.pickImage(
                              source: ImageSource.gallery)
                          : await imagePicker.pickImage(
                              source: ImageSource.camera);
                      if (image != null) {
                        NavigatorHelper.to(
                            PublishSpaceScreen(file: File(image.path)));
                      }
                    },
                    icon: Iconsax.location5,
                    text: 'Publish Space',
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
                    text: 'Publish Event',
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
