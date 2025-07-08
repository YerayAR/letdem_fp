import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:letdem/common/popups/popup.dart';
import 'package:letdem/core/constants/colors.dart';
import 'package:letdem/core/constants/dimens.dart';
import 'package:letdem/core/constants/typo.dart';
import 'package:letdem/core/enums/LetDemLocationType.dart';
import 'package:letdem/core/extensions/locale.dart';
import 'package:letdem/features/activities/presentation/widgets/search/add_location.widget.dart';
import 'package:letdem/infrastructure/services/mapbox_search/models/service.dart';
import 'package:letdem/infrastructure/services/res/navigator.dart';
import 'package:letdem/models/location/local_location.model.dart';
import 'package:letdem/core/utils/location_utils.dart';

class SavedAddressComponent extends StatelessWidget {
  final bool showDivider;

  final bool isLocationCreating;
  final LetDemLocationType locationType;

  final Function(HerePlace) onPlaceSelected;

  final Function? onEditLocationTriggered;

  final Function(LetDemLocation place)? onApiPlaceSelected;

  final HerePlace? place;

  final Function(HerePlace place) onHerePlaceDeleted;
  final Function(LetDemLocation location) onLetDemLocationDeleted;

  final LetDemLocation? apiPlace;
  const SavedAddressComponent(
      {super.key,
      this.showDivider = true,
      this.apiPlace,
      this.isLocationCreating = false,
      this.onEditLocationTriggered,
      required this.onHerePlaceDeleted,
      required this.onLetDemLocationDeleted,
      this.locationType = LetDemLocationType.other,
      this.place,
      required this.onPlaceSelected,
      this.onApiPlaceSelected});

  @override
  Widget build(BuildContext context) {
    return (place != null && place!.title == "")
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
                          onHerePlaceDeleted(place!);
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
                                                    ? context.l10n
                                                        .updatingLocation(LocationUtils
                                                            .getLocationTypeString(
                                                                context,
                                                                locationType))
                                                        .toUpperCase()
                                                    : place != null ||
                                                            apiPlace != null
                                                        ? apiPlace != null
                                                            ? LocationUtils.getLocationTypeString(
                                                                    context,
                                                                    locationType)
                                                                .toUpperCase()
                                                            : place!
                                                                .placeFormatted
                                                                .toUpperCase()
                                                        : LocationUtils.getLocationTypeString(
                                                                context,
                                                                locationType)
                                                                    .toString()
                                                                    .split(",")
                                                                    .isNotEmpty
                                                                ? place!.address
                                                                    .toString()
                                                                    .split(
                                                                        ",")[0]
                                                                    .toUpperCase()
                                                                : place!.address
                                                                    .toString()
                                                                    .toUpperCase()
                                                        : context.l10n
                                                            .locationType(
                                                                locationType
                                                                    .name)
                                                            .toUpperCase(),
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
                                                            : place!.title,
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
                                                                title: context
                                                                    .l10n
                                                                    .setLocation(LocationUtils.getLocationTypeString(
                                                                        context,
                                                                        locationType)),
                                                                onLocationSelected:
                                                                    (HerePlace
                                                                        place) {
                                                                  onPlaceSelected(
                                                                      place);
                                                                },
                                                              ));
                                                        },
                                                        child: Text(
                                                          context.l10n.setLocation(
                                                              LocationUtils.getLocationTypeString(
                                                                  context,
                                                                  locationType)),
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
                                        .navigatorKey.currentState!.context,
                                    LocationBottomSheet(
                                      locationType: locationType,
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
  final LetDemLocationType locationType;

  const LocationBottomSheet({
    super.key,
    required this.locationName,
    required this.onEdit,
    required this.onDelete,
    required this.locationType,
  });

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
                LocationUtils.getLocationTypeString(context, locationType).toUpperCase(),
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
                      context.l10n.edit,
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
                      context.l10n.delete,
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
