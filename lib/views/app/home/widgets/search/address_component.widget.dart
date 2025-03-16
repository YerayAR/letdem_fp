import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:letdem/constants/ui/colors.dart';
import 'package:letdem/constants/ui/dimens.dart';
import 'package:letdem/constants/ui/typo.dart';
import 'package:letdem/enums/LetDemLocationType.dart';
import 'package:letdem/global/popups/popup.dart';
import 'package:letdem/models/location/local_location.model.dart';
import 'package:letdem/services/mapbox_search/models/model.dart';
import 'package:letdem/services/res/navigator.dart';
import 'package:letdem/views/app/home/widgets/search/add_location.widget.dart';

class SavedAddressComponent extends StatelessWidget {
  final bool showDivider;

  final bool isLocationCreating;
  final LetDemLocationType locationType;

  final Function(MapBoxPlace) onPlaceSelected;

  final Function? onEditLocationTriggered;

  final Function(LetDemLocation place)? onApiPlaceSelected;

  final MapBoxPlace? place;

  final Function(MapBoxPlace place) onMapBoxPlaceDeleted;
  final Function(LetDemLocation location) onLetDemLocationDeleted;

  final LetDemLocation? apiPlace;
  const SavedAddressComponent(
      {super.key,
      this.showDivider = true,
      this.apiPlace,
      this.isLocationCreating = false,
      this.onEditLocationTriggered,
      required this.onMapBoxPlaceDeleted,
      required this.onLetDemLocationDeleted,
      this.locationType = LetDemLocationType.other,
      this.place,
      required this.onPlaceSelected,
      this.onApiPlaceSelected});

  @override
  Widget build(BuildContext context) {
    return (place != null && place!.placeFormatted == "")
        ? const SizedBox()
        : GestureDetector(
            onTap: () {
              if (apiPlace != null && onApiPlaceSelected != null) {
                onApiPlaceSelected!(apiPlace!)!;
              }

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
                      direction: locationType == LetDemLocationType.other
                          ? DismissDirection.endToStart
                          : DismissDirection.none,
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
                        children: [
                          Flexible(
                            child: Row(
                              children: <Widget>[
                                CircleAvatar(
                                  radius: 24,
                                  backgroundColor: AppColors.neutral50,
                                  child: isLocationCreating
                                      ? const CupertinoActivityIndicator()
                                      : Icon(
                                          locationType ==
                                                  LetDemLocationType.other
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
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
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
                                                            : place!
                                                                .placeFormatted
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
                                                        style: Typo.mediumBody
                                                            .copyWith(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                        overflow: TextOverflow
                                                            .ellipsis,
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
                                                            color: AppColors
                                                                .primary400,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            decoration:
                                                                TextDecoration
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
                          if (locationType != LetDemLocationType.other &&
                              apiPlace != null)
                            IconButton(
                              icon: Icon(
                                CupertinoIcons.ellipsis,
                                color: AppColors.neutral400,
                                size: 17,
                              ),
                              onPressed: () {
                                AppPopup.showBottomSheet(
                                    NavigatorHelper
                                        .navigatorKey!.currentState!.context,
                                    LocationBottomSheet(
                                      type: locationType ==
                                              LetDemLocationType.other
                                          ? "Other"
                                          : locationType ==
                                                  LetDemLocationType.home
                                              ? "Home"
                                              : "Work",
                                      locationName: apiPlace!.name,
                                      onEdit: () {
                                        if (onEditLocationTriggered != null) {
                                          print("editting");

                                          onEditLocationTriggered!();
                                        }
                                      },
                                      onDelete: () {
                                        onLetDemLocationDeleted(apiPlace!);
                                        NavigatorHelper.pop();
                                      },
                                    ));
                              },
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

class LocationBottomSheet extends StatelessWidget {
  final String locationName;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  final String type;

  const LocationBottomSheet({
    Key? key,
    required this.locationName,
    required this.onEdit,
    required this.type,
    required this.onDelete,
  }) : super(key: key);

  /// Build CircleAvatar Icon Button
  Widget buildIconButton({
    required IconData icon,
    required Color iconColor,
    required Color backgroundColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: 17,
        backgroundColor: backgroundColor,
        child: Icon(
          icon,
          size: 18,
          color: iconColor,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(Dimens.defaultMargin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Header
          Row(
            children: [
              Text(
                "$type Location",
                style: Typo.mediumBody.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 17,
                ),
              ),
              const Spacer(),
              buildIconButton(
                icon: CupertinoIcons.xmark,
                iconColor: AppColors.neutral400,
                backgroundColor: AppColors.neutral50,
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
          Dimens.space(5),

          /// Edit Option
          GestureDetector(
            onTap: onEdit,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    buildIconButton(
                      icon: Iconsax.edit,
                      iconColor: AppColors.primary500,
                      backgroundColor: AppColors.primary50,
                      onTap: onEdit,
                    ),
                    Dimens.space(1),
                    Text(
                      "Edit",
                      style: Typo.mediumBody.copyWith(),
                    ),
                  ],
                ),
                Icon(
                  CupertinoIcons.chevron_forward,
                  color: AppColors.neutral400,
                ),
              ],
            ),
          ),
          Dimens.space(1),

          Divider(
            color: AppColors.neutral50,
            thickness: 1,
          ),
          Dimens.space(1),

          /// Delete Option
          GestureDetector(
            onTap: onDelete,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    buildIconButton(
                      icon: Iconsax.trash,
                      iconColor: AppColors.red500,
                      backgroundColor: AppColors.red50,
                      onTap: onDelete,
                    ),
                    Dimens.space(1),
                    Text(
                      "Delete",
                      style: Typo.mediumBody.copyWith(),
                    ),
                  ],
                ),
                Icon(
                  CupertinoIcons.chevron_forward,
                  color: AppColors.neutral400,
                ),
              ],
            ),
          ),
          Dimens.space(2),
        ],
      ),
    );
  }
}
