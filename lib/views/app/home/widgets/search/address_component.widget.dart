import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:letdem/constants/ui/colors.dart';
import 'package:letdem/constants/ui/dimens.dart';
import 'package:letdem/constants/ui/typo.dart';
import 'package:letdem/features/search/repository/search_location.repository.dart';
import 'package:letdem/global/popups/popup.dart';
import 'package:letdem/services/mapbox_search/models/model.dart';
import 'package:letdem/views/app/home/widgets/search/add_location.widget.dart';

class SavedAddressComponent extends StatelessWidget {
  final bool showDivider;

  final bool isLocationCreating;
  final LetDemLocationType locationType;

  final Function(MapBoxPlace) onPlaceSelected;

  final MapBoxPlace? place;

  final Function(MapBoxPlace place) onMapBoxPlaceDeleted;
  final Function(LetDemLocation location) onLetDemLocationDeleted;

  final LetDemLocation? apiPlace;
  const SavedAddressComponent(
      {super.key,
      this.showDivider = true,
      this.apiPlace,
      this.isLocationCreating = false,
      required this.onMapBoxPlaceDeleted,
      required this.onLetDemLocationDeleted,
      this.locationType = LetDemLocationType.other,
      this.place,
      required this.onPlaceSelected});

  @override
  Widget build(BuildContext context) {
    return (place != null && place!.placeFormatted == "")
        ? const SizedBox()
        : GestureDetector(
            onTap: () {
              if (place != null) {
                onPlaceSelected(place!);
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: SizedBox(
                child: Column(
                  children: [
                    Dismissible(
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: AppColors.red500.withOpacity(0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Icon(
                              IconlyBold.delete,
                              color: AppColors.red500,
                            ),
                            Dimens.space(2),
                          ],
                        ),
                      ),
                      key: UniqueKey(),
                      onDismissed: (direction) {
                        if (apiPlace != null) {
                          onLetDemLocationDeleted(apiPlace!);
                        } else {
                          onMapBoxPlaceDeleted(place!);
                        }
                      },
                      child: Row(
                        children: <Widget>[
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: AppColors.neutral50,
                            child: isLocationCreating
                                ? const CupertinoActivityIndicator()
                                : Icon(
                                    locationType == LetDemLocationType.other
                                        ? Iconsax.location5
                                        : locationType ==
                                                LetDemLocationType.home
                                            ? IconlyBold.home
                                            : IconlyBold.work,
                                    color: AppColors.neutral600,
                                  ),
                          ),
                          Dimens.space(2),
                          Flexible(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          isLocationCreating
                                              ? ""
                                                  "UPDATING ${locationType.name.toUpperCase()} LOCATION"
                                              : place != null ||
                                                      apiPlace != null
                                                  ? apiPlace != null
                                                      ? "${locationType.name.toUpperCase()} LOCATION"
                                                      : place!.placeFormatted
                                                          .toUpperCase()
                                                  : "${locationType.name.toUpperCase()} LOCATION",
                                          style: Typo.smallBody.copyWith(
                                            fontWeight: FontWeight.w400,
                                            color: AppColors.neutral400,
                                          ),
                                        ),
                                        Dimens.space(1),
                                        SizedBox(
                                          child: place != null ||
                                                  apiPlace != null
                                              ? Text(
                                                  apiPlace != null
                                                      ? apiPlace!.name
                                                      : place!.name,
                                                  style:
                                                      Typo.mediumBody.copyWith(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                )
                                              : GestureDetector(
                                                  onTap: () {
                                                    AppPopup.showBottomSheet(
                                                        context,
                                                        AddLocationBottomSheet(
                                                          title:
                                                              "${toBeginningOfSentenceCase(locationType.name)} Location",
                                                          onLocationSelected:
                                                              (MapBoxPlace
                                                                  place) {
                                                            onPlaceSelected(
                                                                place);
                                                          },
                                                        ));
                                                  },
                                                  child: Text(
                                                    "Set ${toBeginningOfSentenceCase(locationType.name)} Location",
                                                    style: Typo.mediumBody
                                                        .copyWith(
                                                      color:
                                                          AppColors.primary400,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      decoration: TextDecoration
                                                          .underline,
                                                    ),
                                                  ),
                                                ),
                                        ),
                                      ]),
                                ),
                                //   delete button
                              ],
                            ),
                          ),
                        ],
                      ),
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
              ),
            ),
          );
  }
}
