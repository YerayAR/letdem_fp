import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:letdem/common/popups/popup.dart';
import 'package:letdem/common/widgets/button.dart';
import 'package:letdem/common/widgets/textfield.dart';
import 'package:letdem/core/constants/colors.dart';
import 'package:letdem/core/constants/dimens.dart';
import 'package:letdem/core/constants/typo.dart';
import 'package:letdem/core/extensions/locale.dart';
import 'package:letdem/features/activities/presentation/bottom_sheets/add_event_sheet.widget.dart';
import 'package:letdem/features/activities/presentation/utils/publish_space_handler.dart';
import 'package:letdem/features/activities/presentation/widgets/search/search_bottom_sheet.widget.dart';

import '../../../../infrastructure/services/mapbox_search/models/service.dart';

class HomeMapBottomSection extends StatelessWidget {
  final VoidCallback onRefreshTriggered;
  const HomeMapBottomSection({super.key, required this.onRefreshTriggered});

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
                    HereSearchApiService()
                        .getLocationResults(value, context)
                        .then((value) {
                      for (var element in value) {
                        print(element.toJson());
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
                  flex: context.isSpanish ? 6 : 1,
                  child: PrimaryButton(
                    onTap: () async {
                      PublishSpaceHandler.showSpaceOptions(context, () {
                        onRefreshTriggered();
                      });
                    },
                    icon: !context.isSpanish ? IconlyBold.location : null,
                    text: context.l10n.publishSpace,
                  ),
                ),
                Dimens.space(1),
                Flexible(
                  flex: context.isSpanish ? 4 : 1,
                  child: PrimaryButton(
                    outline: true,
                    background: AppColors.primary50,
                    borderColor: Colors.transparent,
                    onTap: () {
                      AppPopup.showBottomSheet(
                          context, const AddEventBottomSheet());
                    },
                    icon: !context.isSpanish ? IconlyBold.star : null,
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
