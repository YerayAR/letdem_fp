import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart' as geolocator;
import 'package:iconly/iconly.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:letdem/constants/ui/assets.dart';
import 'package:letdem/features/activities/activities_bloc.dart';
import 'package:letdem/features/map/map_bloc.dart';
import 'package:letdem/global/popups/popup.dart';
import 'package:letdem/models/auth/map/map_options.model.dart';
import 'package:letdem/models/auth/map/nearby_payload.model.dart';
import 'package:letdem/services/location/location.service.dart';
import 'package:letdem/services/mapbox_search/models/service.dart';
import 'package:letdem/services/res/navigator.dart';
import 'package:letdem/services/toast/toast.dart';
import 'package:letdem/views/app/home/widgets/search/search_bottom_sheet.widget.dart';
import 'package:letdem/views/app/publish_space/screens/publish_space.view.dart';
import 'package:letdem/views/auth/views/onboard/verify_account.view.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mapbox;
import 'package:shimmer/shimmer.dart';

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
  bool isLocationLoading = false;
  late mapbox.CameraOptions _cameraPosition;
  late mapbox.MapboxMap mapboxController;
  mapbox.PointAnnotationManager? pointAnnotationManager;
  final MapAssetsProvider _assetsProvider = MapAssetsProvider();

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _loadAssets();
  }

  bool isLoadingAssets = true;

  Future<void> _loadAssets() async {
    await _assetsProvider.loadAssets();
    setState(() {
      isLoadingAssets = false;
    });
  }

  bool hasNoPermission = false;

  Future<void> _getCurrentLocation() async {
    try {
      setState(() {
        isLocationLoading = true;
      });
      bool serviceEnabled =
          await geolocator.Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await geolocator.Geolocator.requestPermission();
      }

      geolocator.LocationPermission permission =
          await geolocator.Geolocator.checkPermission();
      if (permission == geolocator.LocationPermission.denied ||
          permission == geolocator.LocationPermission.deniedForever) {
        setState(() {
          hasNoPermission = true;
          isLocationLoading = false;
        });
        permission = await geolocator.Geolocator.requestPermission();
      }

      if (permission == geolocator.LocationPermission.whileInUse ||
          permission == geolocator.LocationPermission.always) {
        var position = await geolocator.Geolocator.getCurrentPosition(
          desiredAccuracy: geolocator.LocationAccuracy.high,
        );

        setState(() {
          isLocationLoading = false;

          _currentPosition =
              mapbox.Position(position.longitude, position.latitude);
          _cameraPosition = mapbox.CameraOptions(
            center: mapbox.Point(
              coordinates:
                  mapbox.Position(position.longitude, position.latitude),
            ),
            zoom: 13,
            bearing: 0,
            pitch: 0,
          );
        });

        if (_currentPosition != null) {
          context.read<MapBloc>().add(GetNearbyPlaces(
                queryParams: MapQueryParams(
                  currentPoint: "${position.latitude},${position.longitude}",
                  radius: 8000,
                  drivingMode: false,
                  options: ['spaces', 'events'],
                ),
              ));
        }
      }
    } catch (e) {
      setState(() {
        isLocationLoading = false;
      });
      debugPrint("Error getting location: $e");
    }
  }

  @override
  void dispose() {
    _currentPosition = null;
    super.dispose();
  }

  Uint8List getEventIcon(
    EventTypes type,
    Uint8List policeMapMarkerImageData,
    Uint8List closedRoadMapMarkerImageData,
    Uint8List accidentMapMarkerImageData,
  ) {
    switch (type) {
      case EventTypes.accident:
        return accidentMapMarkerImageData;
      case EventTypes.police:
        return policeMapMarkerImageData;
      case EventTypes.closeRoad:
        return closedRoadMapMarkerImageData;
    }
  }

  Uint8List getImageData(
    PublishSpaceType type,
    Uint8List freeMarkerImageData,
    Uint8List greenMarkerImageData,
    Uint8List blueMapMarkerImageData,
    Uint8List disasterMapMarkerImageData,
  ) {
    switch (type) {
      case PublishSpaceType.free:
        return freeMarkerImageData;
      case PublishSpaceType.greenZone:
        return greenMarkerImageData;
      case PublishSpaceType.blueZone:
        return blueMapMarkerImageData;
      case PublishSpaceType.disabled:
        return disasterMapMarkerImageData;
    }
  }

  void _addAnnotations(
    List<Space> spaces,
    List<Event> events,
  ) {
    // draw current location
    pointAnnotationManager?.create(
      mapbox.PointAnnotationOptions(
        geometry: mapbox.Point(
          coordinates: mapbox.Position(
            _currentPosition!.lng,
            _currentPosition!.lat,
          ),
        ),
        iconSize: 1.5,
        image: _assetsProvider.currentLocationMarker,
      ),
    );
    for (var element in spaces) {
      pointAnnotationManager?.create(
        mapbox.PointAnnotationOptions(
          geometry: mapbox.Point(
              coordinates: mapbox.Position(
                  element.location.point.lng, element.location.point.lat)),
          iconSize: 1.7,
          image: _assetsProvider.getImageForType(element.type),
        ),
      );
    }

    for (var element in events) {
      pointAnnotationManager?.create(
        mapbox.PointAnnotationOptions(
          geometry: mapbox.Point(
              coordinates: mapbox.Position(
                  element.location.point.lng, element.location.point.lat)),
          iconSize: 1.5,
          image: _assetsProvider.getEventIcon(element.type),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return isLocationLoading
        ? Stack(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                color: AppColors.neutral50,
              ),
              Positioned(
                bottom: 0,
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.3,
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
                    children: [
                      Dimens.space(1),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(45),
                        child: SizedBox(
                          height: 60.0,
                          child: Shimmer.fromColors(
                            baseColor: Colors.grey[200]!.withOpacity(0.2),
                            highlightColor: Colors.grey[50]!,
                            child: Container(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      Dimens.space(6),
                      Row(
                        children: <Widget>[
                          Flexible(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(45),
                              child: SizedBox(
                                height: 60.0,
                                child: Shimmer.fromColors(
                                  baseColor: Colors.grey[200]!.withOpacity(0.2),
                                  highlightColor: Colors.grey[50]!,
                                  child: Container(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Dimens.space(1),
                          Flexible(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(45),
                              child: SizedBox(
                                height: 60.0,
                                child: Shimmer.fromColors(
                                  baseColor: Colors.grey[200]!.withOpacity(0.2),
                                  highlightColor: Colors.grey[50]!,
                                  child: Container(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          )
        : hasNoPermission
            ? Padding(
                padding: const EdgeInsets.all(20.0),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Location Permission\nRequired",
                        style: Typo.largeBody.copyWith(
                            fontWeight: FontWeight.w700, fontSize: 25),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        "We need to get access to your location services to perform any action in the app",
                        style: Typo.mediumBody.copyWith(
                          color: AppColors.neutral400,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Dimens.space(4),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.5,
                        child: PrimaryButton(
                          onTap: () async {
                            print("Getting location");
                            _getCurrentLocation();
                          },
                          text: 'Retry',
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : BlocConsumer<MapBloc, MapState>(
                listener: (context, state) {},
                builder: (context, state) {
                  print(state);

                  return state is MapLoaded && isLoadingAssets == false ||
                          state is MapInitial
                      ? Stack(
                          children: [
                            mapbox.MapWidget(
                              key: UniqueKey(),
                              onMapCreated: (controller) async {
                                mapboxController = controller;

                                mapboxController.scaleBar.updateSettings(
                                  mapbox.ScaleBarSettings(enabled: false),
                                );
                                mapboxController.compass.updateSettings(
                                  mapbox.CompassSettings(enabled: false),
                                );

                                await mapboxController!
                                    .setBounds(mapbox.CameraBoundsOptions(
                                  maxZoom: 18,
                                  minZoom: 12,
                                ));
                                pointAnnotationManager = await mapboxController
                                    .annotations
                                    .createPointAnnotationManager();

                                if (mounted && state is MapLoaded) {
                                  _addAnnotations(
                                    (state).payload.spaces,
                                    (state).payload.events,
                                  );
                                }
                              },
                              styleUri: mapbox.MapboxStyles.MAPBOX_STREETS,
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
                                        AppPopup.showBottomSheet(context,
                                            const MapSearchBottomSheet());
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
                                      style: Typo.largeBody.copyWith(
                                          fontWeight: FontWeight.w500),
                                    ),
                                    Dimens.space(2),
                                    Row(
                                      children: [
                                        Flexible(
                                          child: PrimaryButton(
                                            onTap: () async {
                                              ImagePicker imagePicker =
                                                  ImagePicker();
                                              XFile? image = kDebugMode
                                                  ? await imagePicker.pickImage(
                                                      source:
                                                          ImageSource.gallery)
                                                  : await imagePicker.pickImage(
                                                      source:
                                                          ImageSource.camera);
                                              if (image != null) {
                                                NavigatorHelper.to(
                                                    PublishSpaceScreen(
                                                        file:
                                                            File(image.path)));
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
                                              AppPopup.showBottomSheet(context,
                                                  const AddEventBottomSheet());
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
                            ),
                          ],
                        )
                      : Column(
                          children: [],
                        );
                },
              );
  }

  @override
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

EventTypes getEventEnumFromText(String t) {
  switch (t) {
    case "ACCIDENT":
      return EventTypes.accident;
    case "POLICE":
      return EventTypes.police;
    case "CLOSED_ROAD":
      return EventTypes.closeRoad;

    default:
      return EventTypes.accident;
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
  late final Future<CurrentLocationPayload?> _locationFuture;

  @override
  void initState() {
    super.initState();
    _locationFuture = MapboxService.getPlaceFromLatLng(); // Runs only once
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<CurrentLocationPayload?>(
        future: _locationFuture,
        builder: (context, snapshot) {
          return BlocConsumer<ActivitiesBloc, ActivitiesState>(
            listener: (context, state) {
              if (state is ActivitiesError) {
                Toast.showError(state.error);
              }
              if (state is ActivitiesPublished) {
                context.read<MapBloc>().add(GetNearbyPlaces(
                      queryParams: MapQueryParams(
                        currentPoint:
                            "${snapshot.data!.latitude},${snapshot.data!.longitude}",
                        radius: 8000,
                        drivingMode: false,
                        options: ['spaces', 'events'],
                      ),
                    ));
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

class MapAssetsProvider {
  late Uint8List freeMarker, greenMarker, blueMarker, disasterMarker;

  late Uint8List currentLocationMarker;
  late Uint8List accidentMarker, closedRoadMarker, policeMarker;

  Future<void> loadAssets() async {
    freeMarker = await _loadImage(AppAssets.freeMapMarker);
    greenMarker = await _loadImage(AppAssets.greenMapMarker);
    blueMarker = await _loadImage(AppAssets.blueMapMarker);
    disasterMarker = await _loadImage(AppAssets.disabledMapMarker);

    currentLocationMarker =
        await _loadImage(AppAssets.currentLocationMapMarker);

    accidentMarker = await _loadImage(AppAssets.accidentMapMarker);
    closedRoadMarker = await _loadImage(AppAssets.closedRoadMapMarker);
    policeMarker = await _loadImage(AppAssets.policeMapMarker);
  }

  // getter for current location marker
  Uint8List get currentLocationMarkerImageData => currentLocationMarker;

  Future<Uint8List> _loadImage(String path) async {
    ByteData byteData = await rootBundle.load(path);
    return byteData.buffer.asUint8List();
  }

  Uint8List getImageForType(PublishSpaceType type) {
    switch (type) {
      case PublishSpaceType.free:
        return freeMarker;
      case PublishSpaceType.greenZone:
        return greenMarker;
      case PublishSpaceType.blueZone:
        return blueMarker;
      case PublishSpaceType.disabled:
        return disasterMarker;
    }
  }

  Uint8List getEventIcon(EventTypes type) {
    switch (type) {
      case EventTypes.accident:
        return accidentMarker;
      case EventTypes.police:
        return policeMarker;
      case EventTypes.closeRoad:
        return closedRoadMarker;
    }
  }
}
