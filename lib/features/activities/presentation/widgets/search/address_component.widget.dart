import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:iconsax/iconsax.dart';
import 'package:letdem/common/popups/popup.dart';
import 'package:letdem/core/constants/colors.dart';
import 'package:letdem/core/constants/dimens.dart';
import 'package:letdem/core/constants/typo.dart';
import 'package:letdem/core/enums/LetDemLocationType.dart';
import 'package:letdem/core/extensions/locale.dart';
import 'package:letdem/core/utils/location_utils.dart';
import 'package:letdem/features/activities/presentation/widgets/search/add_location.widget.dart';
import 'package:letdem/infrastructure/services/mapbox_search/models/service.dart';
import 'package:letdem/infrastructure/services/res/navigator.dart';
import 'package:letdem/models/location/local_location.model.dart';

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
    // Early return for empty places
    if (place?.title == "") return const SizedBox();

    // final hasLocation = place != null || apiPlace != null;
    // final locationName = apiPlace?.name ?? place?.title ?? "";
    final shouldShowEllipsis =
        locationType != LetDemLocationType.other && apiPlace != null;

    return GestureDetector(
      onTap: () {
        if (apiPlace != null && onApiPlaceSelected != null) {
          onApiPlaceSelected!(apiPlace!);
        }
        if (place != null) {
          onPlaceSelected(place!);
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
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
                    Icon(IconlyBold.delete, color: AppColors.red500),
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
                                  _getLocationIcon(),
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _getLocationTypeText(context)
                                          .toUpperCase(),
                                      style: Typo.smallBody.copyWith(
                                        fontWeight: FontWeight.w400,
                                        color: AppColors.neutral400,
                                      ),
                                    ),
                                    Dimens.space(1),
                                    _buildLocationNameWidget(context),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (shouldShowEllipsis)
                    IconButton(
                      icon: Icon(
                        CupertinoIcons.ellipsis,
                        color: AppColors.neutral400,
                        size: 17,
                      ),
                      onPressed: () => _showLocationBottomSheet(),
                    ),
                ],
              ),
            ),
            if (showDivider) ...[
              Dimens.space(1),
              Divider(
                color: AppColors.neutral50,
                thickness: 1,
              ),
            ],
          ],
        ),
      ),
    );
  }

// Helper method to get location icon
  IconData _getLocationIcon() {
    switch (locationType) {
      case LetDemLocationType.home:
        return IconlyBold.home;
      case LetDemLocationType.work:
        return IconlyBold.work;
      case LetDemLocationType.other:
      default:
        return Iconsax.location5;
    }
  }

// Helper method to get location type text
  String _getLocationTypeText(BuildContext context) {
    if (isLocationCreating) {
      return context.l10n.updatingLocation(
          LocationUtils.getLocationTypeString(context, locationType));
    }

    if (apiPlace != null) {
      return LocationUtils.getLocationTypeString(context, locationType);
    }

    if (place?.address != null) {
      final address = place!.address!;
      final parts = address.split(",");
      return parts.isNotEmpty ? parts[0] : address;
    }

    return context.l10n.locationType(locationType == LetDemLocationType.home
        ? context.l10n.homeLocationShort
        : context.l10n.work);
  }

// Helper method to build location name widget
  Widget _buildLocationNameWidget(BuildContext context) {
    final hasLocation = place != null || apiPlace != null;

    if (hasLocation) {
      final locationName = apiPlace?.name ?? place!.title;
      return Text(
        locationName,
        style: Typo.mediumBody.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        overflow: TextOverflow.ellipsis,
      );
    }

    return GestureDetector(
      onTap: () => _showAddLocationBottomSheet(context),
      child: Text(
        context.l10n.setLocation(
            LocationUtils.getLocationTypeString(context, locationType)),
        style: Typo.mediumBody.copyWith(
          color: AppColors.primary400,
          fontWeight: FontWeight.w500,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }

// Helper method to show add location bottom sheet
  void _showAddLocationBottomSheet(BuildContext context) {
    print("showing add location bottom sheet for ${locationType.name}");
    AppPopup.showBottomSheet(
      context,
      AddLocationBottomSheet(
        title: context.l10n.setLocation(
            LocationUtils.getLocationTypeString(context, locationType)),
        onLocationSelected: (HerePlace place) {
          onPlaceSelected(place);
        },
      ),
    );
  }

// Helper method to show location bottom sheet
  void _showLocationBottomSheet() {
    AppPopup.showBottomSheet(
      NavigatorHelper.navigatorKey.currentState!.context,
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
                LocationUtils.getLocationTypeString(context, locationType)
                    .toUpperCase(),
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
