import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as geolocator;
import 'package:iconly/iconly.dart';
import 'package:iconsax/iconsax.dart';
import 'package:letdem/extenstions/location.dart';
import 'package:letdem/global/popups/popup.dart';
import 'package:letdem/main.dart';
import 'package:letdem/services/mapbox_search/models/model.dart';
import 'package:letdem/services/mapbox_search/models/service.dart';
import 'package:letdem/services/res/navigator.dart';
import 'package:letdem/views/app/publish_space/screens/publish_space.view.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mapbox;

import '../../../constants/ui/colors.dart';
import '../../../constants/ui/dimens.dart';
import '../../../constants/ui/typo.dart';
import '../../../global/widgets/button.dart';
import '../../../global/widgets/textfield.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  mapbox.Position? _currentPosition;

  @override
  void initState() {
    _getCurrentLocation();
    super.initState();
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled =
          await geolocator.Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await geolocator.Geolocator.requestPermission();
      }
      geolocator.LocationPermission permission =
          await geolocator.Geolocator.checkPermission();
      if (permission == geolocator.LocationPermission.denied ||
          permission == geolocator.LocationPermission.deniedForever) {
        permission = await geolocator.Geolocator.requestPermission();
      }

      if (permission == geolocator.LocationPermission.whileInUse ||
          permission == geolocator.LocationPermission.always) {
        var position = await geolocator.Geolocator.getCurrentPosition(
          desiredAccuracy: geolocator.LocationAccuracy.high,
        );

        setState(() {
          _currentPosition = mapbox.Position(
            position.longitude,
            position.latitude,
          );
          _cameraPosition = mapbox.CameraOptions(
              center: mapbox.Point(
                  coordinates: mapbox.Position(
                position.longitude,
                position.latitude,
              )),
              zoom: 13,
              bearing: 0,
              pitch: 0);
        });
      }
    } catch (e) {
      print("Error getting location: $e");
    }
  }

  late mapbox.MapboxMap mapboxController;

  Future<bool> checkLocationFuture() async {
    return await context.hasLocationPermission;
  }

  late mapbox.CameraOptions _cameraPosition;

  @override
  Widget build(BuildContext context) {
    return _currentPosition == null
        ? const CupertinoActivityIndicator()
        : Center(
            key: UniqueKey(),
            child: Stack(
              children: [
                mapbox.MapWidget(
                  key: UniqueKey(),
                  styleUri: mapbox.MapboxStyles.OUTDOORS,
                  cameraOptions: _cameraPosition,
                ),
                Positioned(
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
                              AppPopup.showBottomSheet(
                                  context, const MapSearchBottomSheet());
                            },
                            child: AbsorbPointer(
                              child: TextInputField(
                                label: null,
                                onChanged: (value) async {
                                  MapboxSearchApiService()
                                      .getLocationResults(value)
                                      .then((value) {
                                    for (var element in value) {
                                      print(element.fullAddress);
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
                            style: Typo.largeBody
                                .copyWith(fontWeight: FontWeight.w500),
                          ),
                          Dimens.space(2),
                          Row(
                            children: [
                              Flexible(
                                child: PrimaryButton(
                                  onTap: () async {
                                    NavigatorHelper.to(
                                        const PublishSpaceScreen());
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
                                  onTap: () {},
                                  icon: IconlyBold.star,
                                  color: AppColors.primary500,
                                  text: 'Publish Event',
                                ),
                              ),
                            ],
                          ),
                          Dimens.space(2),
                        ],
                      )),
                ),
              ],
            ),
          );
  }
}

class SavedAddressComponent extends StatelessWidget {
  final bool showDivider;

  final MapBoxPlace? place;
  const SavedAddressComponent({super.key, this.showDivider = true, this.place});

  @override
  Widget build(BuildContext context) {
    return (place != null && place!.placeFormatted == "")
        ? const SizedBox()
        : Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              children: [
                Row(
                  children: <Widget>[
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: AppColors.neutral50,
                      child: Icon(
                        place != null ? Iconsax.location5 : IconlyBold.home,
                        color: AppColors.neutral600,
                      ),
                    ),
                    Dimens.space(2),
                    Flexible(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              place != null
                                  ? place!.name.toUpperCase()
                                  : "HOME LOCATION",
                              style: Typo.smallBody.copyWith(
                                fontWeight: FontWeight.w400,
                                color: AppColors.neutral400,
                              ),
                            ),
                            Dimens.space(1),
                            SizedBox(
                              child: place != null
                                  ? Text(
                                      place!.placeFormatted,
                                      style: Typo.mediumBody.copyWith(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    )
                                  : Text(
                                      "Set Home Location",
                                      style: Typo.mediumBody.copyWith(
                                        color: AppColors.primary400,
                                        fontWeight: FontWeight.w500,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                            ),
                          ]),
                    ),
                  ],
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
          );
  }
}
