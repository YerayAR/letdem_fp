import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart' as geolocator;
import 'package:iconly/iconly.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:letdem/constants/ui/assets.dart';
import 'package:letdem/features/activities/activities_bloc.dart';
import 'package:letdem/global/popups/popup.dart';
import 'package:letdem/services/location/location.service.dart';
import 'package:letdem/services/mapbox_search/models/service.dart';
import 'package:letdem/services/res/navigator.dart';
import 'package:letdem/services/toast/toast.dart';
import 'package:letdem/views/app/home/widgets/search/search_bottom_sheet.widget.dart';
import 'package:letdem/views/app/publish_space/screens/publish_space.view.dart';
import 'package:letdem/views/auth/views/onboard/verify_account.view.dart';
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

class _HomeViewState extends State<HomeView>
    with AutomaticKeepAliveClientMixin {
  mapbox.Position? _currentPosition;

  @override
  void dispose() {
    _currentPosition = null;

    super.dispose();
  }

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

  late mapbox.CameraOptions _cameraPosition;

  @override
  Widget build(BuildContext context) {
    return _currentPosition == null
        ? const CupertinoActivityIndicator()
        : Center(
            child: Stack(
              children: [
                mapbox.MapWidget(
                  onMapCreated: (controller) {
                    mapboxController = controller;

                    mapboxController.scaleBar
                        .updateSettings(mapbox.ScaleBarSettings(
                      enabled: false,
                    )); // hide the scale bar
                  },
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
                                    // open camera
                                    ImagePicker imagePicker = ImagePicker();

                                    if (kDebugMode) {
                                      XFile? f = await imagePicker.pickImage(
                                          source: ImageSource.gallery);

                                      // get asset folder path

                                      NavigatorHelper.to(PublishSpaceScreen(
                                        file: File(f!.path),
                                      ));
                                      return;
                                    }

                                    final XFile? image = await imagePicker
                                        .pickImage(source: ImageSource.camera);

                                    if (image != null) {
                                      NavigatorHelper.to(PublishSpaceScreen(
                                        file: File(image!.path),
                                      ));
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
                      )),
                ),
              ],
            ),
          );
  }

  @override
  void updateKeepAlive() {
    // TODO: implement updateKeepAlive
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}

enum EventTypes {
  police,
  closeRoad,

  accident
}

String eventTypeToString(EventTypes type) {
  switch (type) {
    case EventTypes.police:
      return "Police";
    case EventTypes.closeRoad:
      return "Close Road";
    case EventTypes.accident:
      return "Accident";
  }
}

String getEnumName(EventTypes t) {
  switch (t) {
    case EventTypes.accident:
      return "ACCIDENT";
    case EventTypes.police:
      return "POLICE";
    case EventTypes.closeRoad:
      return "CLOSED_ROAD";
  }
}

String getEventTypeIcon(EventTypes type) {
  switch (type) {
    case EventTypes.police:
      return AppAssets.police;
    case EventTypes.closeRoad:
      return AppAssets.closeRoad;
    case EventTypes.accident:
      return AppAssets.accident;
  }
}

class AddEventBottomSheet extends StatefulWidget {
  const AddEventBottomSheet({super.key});

  @override
  State<AddEventBottomSheet> createState() => _AddEventBottomSheetState();
}

class _AddEventBottomSheetState extends State<AddEventBottomSheet> {
  EventTypes selectedType = EventTypes.police;
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<CurrentLocationPayload?>(
        future: MapboxService.getPlaceFromLatLng(),
        builder: (context, snapshot) {
          return BlocConsumer<ActivitiesBloc, ActivitiesState>(
            listener: (context, state) {
              if (state is ActivitiesError) {
                Toast.showError(state.error);
              }
              if (state is ActivitiesPublished) {
                Navigator.of(context).pop();
                AppPopup.showDialogSheet(
                  context,
                  SuccessDialog(
                    title: "Event Published\nSuccessfully",
                    subtext:
                        "Your event have been published successfully, people can now see this event on map.",
                    onProceed: () {
                      NavigatorHelper.pop();
                    },
                  ),
                );
              }
              // TODO: implement listener
            },
            builder: (context, state) {
              return Padding(
                padding: EdgeInsets.all(Dimens.defaultMargin / 2),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Select Event type",
                          style: Typo.largeBody
                              .copyWith(fontWeight: FontWeight.w700),
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          icon: Icon(
                            Iconsax.close_circle5,
                            color: AppColors.neutral100,
                          ),
                        ),
                      ],
                    ),
                    Dimens.space(4),
                    Row(
                      spacing: 15,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: EventTypes.values
                          .map(
                            (e) => Flexible(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedType = e;
                                  });
                                },
                                child: AspectRatio(
                                  aspectRatio: 1,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    height: 93,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      border: selectedType == e
                                          ? Border.all(
                                              color: AppColors.primary200,
                                              width: 2)
                                          : Border.all(
                                              color: AppColors.neutral50,
                                              width: 2),
                                    ),
                                    child: Center(
                                        child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SvgPicture.asset(
                                          getEventTypeIcon(e),
                                          width: 50,
                                          height: 50,
                                        ),
                                        Dimens.space(2),
                                        Text(
                                          eventTypeToString(e),
                                          style: Typo.smallBody.copyWith(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    )),
                                  ),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                    Dimens.space(4),
                    PrimaryButton(
                      isDisabled:
                          snapshot.connectionState == ConnectionState.waiting ||
                              snapshot.data == null,
                      isLoading: state is ActivitiesLoading,
                      onTap: () {
                        BlocProvider.of<ActivitiesBloc>(context).add(
                          PublishRoadEventEvent(
                            type: getEnumName(selectedType),
                            latitude: snapshot.data!.latitude,
                            longitude: snapshot.data!.longitude,
                            locationName: snapshot.data!.locationName!,
                          ),
                        );
                      },
                      text: 'Publish',
                    ),
                    Dimens.space(6),
                  ],
                ),
              );
            },
          );
        });
  }
}
