import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:here_sdk/core.dart';
import 'package:here_sdk/mapview.dart';
import 'package:iconly/iconly.dart';
import 'package:letdem/common/widgets/button.dart';
import 'package:letdem/common/widgets/chip.dart';
import 'package:letdem/core/constants/assets.dart';
import 'package:letdem/core/constants/colors.dart';
import 'package:letdem/core/constants/dimens.dart';
import 'package:letdem/core/constants/typo.dart';
import 'package:letdem/core/enums/CarTagType.dart';
import 'package:letdem/core/extensions/locale.dart';
import 'package:letdem/features/activities/presentation/widgets/no_car_registered.widget.dart';
import 'package:letdem/models/car/car.model.dart';

import '../../../../infrastructure/services/res/navigator.dart';
import '../../../map/presentation/views/navigate.view.dart';

class RegisteredCarWidget extends StatelessWidget {
  final Car car;
  const RegisteredCarWidget({super.key, required this.car});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: 0,
        horizontal: 0,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Padding(
            padding: const EdgeInsets.all(25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Your Car Details
                Text(
                  context.l10n.yourCarDetails,
                  style: Typo.smallBody.copyWith(
                    color: AppColors.neutral500,
                    fontWeight: FontWeight.w700,
                    fontSize: 14
                  ),
                ),
                Dimens.space(1),
                //   Mercedes Benz E350
                Text(
                  car.brand,
                  style: Typo.largeBody.copyWith(
                      // color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 17),
                ),
                Dimens.space(1),

                Row(
                  spacing: 11,
                  children: <Widget>[
                    Text(car.registrationNumber,
                        style: Typo.largeBody.copyWith(
                          color: AppColors.neutral500,
                          fontWeight: FontWeight.w500,
                        )),
                    CircleAvatar(
                      radius: 3,
                      backgroundColor: AppColors.neutral500,
                    ),
                    SvgPicture.asset(
                      geTagTypeIcon(car.tagType),
                      width: 25,
                    )
                  ],
                ),
                Dimens.space(2),

                GestureDetector(
                  onTap: () {
                    NavigatorHelper.to(RegisterCarView(car: car));
                  },
                  child: DecoratedChip(
                    backgroundColor: AppColors.primary50,
                    text: context.l10n.editDetails,
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 14,
                    ),
                    textStyle: Typo.smallBody.copyWith(
                      color: AppColors.primary500,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                    textSize: 11,
                    color: AppColors.primary500,
                  ),
                ),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: car.lastParkingLocation == null
                      ? []
                      : [
                          Dimens.space(2),
                          Divider(
                            color: AppColors.neutral50,
                            height: 1,
                          ),
                          Dimens.space(2),
                          Text(
                            context.l10n.lastPlaceParked,
                            style: Typo.smallBody.copyWith(
                                color: AppColors.neutral500,
                                fontWeight: FontWeight.w700,
                                fontSize: 14
                            ),
                          ),
                          Dimens.space(2),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Row(
                                  children: [
                                    Icon(
                                      IconlyBold.location,
                                      color: AppColors.neutral500,
                                      size: 16,
                                    ),
                                    Dimens.space(1),
                                    Flexible(
                                      child: Text(
                                        car.lastParkingLocation?.streetName ??
                                            context.l10n.unknown,
                                        maxLines: 2,
                                        style: Typo.mediumBody.copyWith(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12,
                                          color: AppColors.neutral500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Dimens.space(2),
                              GestureDetector(
                                onTap: () {
                                    NavigatorHelper.to(NavigationView(
                                      destinationLat:
                                          car.lastParkingLocation!.lat ?? 0,
                                      destinationLng:
                                          car.lastParkingLocation!.lng ?? 0,
                                    ));
                                },
                                child: Row(
                                  children: [
                                    Text(
                                      context.l10n.navigateToCar,
                                      style: Typo.mediumBody.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.primary500,
                                        fontSize: 12,
                                      ),
                                    ),
                                    Dimens.space(1),
                                    Icon(
                                      Icons.arrow_forward,
                                      color: AppColors.primary500,
                                      size: 15,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                ),
              ],
            ),
          ),
          Positioned(
            right: 0,
            child: SvgPicture.asset(
              AppAssets.eclipse,
              width: 130,
              height: 130,
            ),
          ),
          Positioned(
            right: 0,
            top: 10,
            child: SvgPicture.asset(
              AppAssets.car,
              width: MediaQuery.of(context).size.width * 0.3,
              height: MediaQuery.of(context).size.width * 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class LastParkedWidget extends StatefulWidget {
  final LastParkingLocation? lastParked;
  const LastParkedWidget({super.key, required this.lastParked});

  @override
  State<LastParkedWidget> createState() => _LastParkedWidgetState();
}

class _LastParkedWidgetState extends State<LastParkedWidget> {
  HereMapController? _mapController;

  void _onMapCreated(HereMapController controller) {
    _mapController = controller;

    _mapController!.mapScene.loadSceneForMapScheme(MapScheme.normalDay,
        (error) {
      if (error != null) {
        debugPrint('Map load error: $error');
        return;
      }

      // Set the parking location coordinates
      final parkingLocation = GeoCoordinates(widget.lastParked?.lat ?? 37.3318,
          widget.lastParked?.lng ?? -122.0312);

      // Add a marker at the parking location
      _addMarker(parkingLocation);

      // Center the map on the parking location
      _mapController!.camera.lookAtPointWithMeasure(
          parkingLocation, MapMeasure(MapMeasureKind.distanceInMeters, 500));
    });
  }

  void _addMarker(GeoCoordinates coordinates) {
    // // Create a default marker image
    // final mapMarker = MapMarker(
    //   coordinates,
    // );
    //
    // // Alternative: create a default marker if you don't have a custom image
    // // final mapMarker = MapMarker(coordinates);
    //
    // // Add the marker to the map
    // _mapController?.mapScene.addMapMarker(mapMarker);
  }

  @override
  Widget build(BuildContext context) {
    return widget.lastParked == null
        ? const SizedBox()
        : Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(0),
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.l10n.lastPlaceParked,
                            style: Typo.smallBody.copyWith(
                              color: AppColors.neutral500,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Dimens.space(1),
                          Text(
                            widget.lastParked?.streetName ??
                                context.l10n.unknown,
                            style: Typo.largeBody.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Dimens.space(2),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.45,
                            child: PrimaryButton(
                              color: AppColors.primary300,
                              onTap: () {
                                NavigatorHelper.to(NavigationView(
                                  destinationLat: widget.lastParked?.lat ?? 0,
                                  destinationLng: widget.lastParked?.lng ?? 0,
                                ));
                              },
                              text: context.l10n.navigateToCar,
                              iconRight: Icons.arrow_forward,
                              padding: const EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Right side - Map with shadow effect
                  // Padding(
                  //   padding: const EdgeInsets.only(right: 0),
                  //   child: Container(
                  //     width: 150,
                  //     height: 150,
                  //     decoration: BoxDecoration(),
                  //     child: ClipRRect(
                  //       child: Stack(
                  //         children: [
                  //           HereMap(onMapCreated: _onMapCreated),
                  //           // Optional: Add a very slight overlay for a shadow-like effect
                  //           Container(
                  //             decoration: BoxDecoration(
                  //               gradient: LinearGradient(
                  //                 begin: Alignment.topCenter,
                  //                 end: Alignment.bottomCenter,
                  //                 colors: [
                  //                   Colors.black.withOpacity(0.05),
                  //                   Colors.black.withOpacity(0.1),
                  //                 ],
                  //               ),
                  //             ),
                  //           ),
                  //         ],
                  //       ),
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
          );
  }
}
