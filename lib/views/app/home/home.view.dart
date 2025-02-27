import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart' as geolocator;
import 'package:letdem/constants/ui/dimens.dart';
import 'package:letdem/enums/EventTypes.dart';
import 'package:letdem/features/map/map_bloc.dart';
import 'package:letdem/models/auth/map/map_options.model.dart';
import 'package:letdem/models/auth/map/nearby_payload.model.dart';
import 'package:letdem/services/map/map_asset_provider.service.dart';
import 'package:letdem/views/app/home/widgets/home/home_bottom_section.widget.dart';
import 'package:letdem/views/app/home/widgets/home/no_connection.widget.dart';
import 'package:letdem/views/app/publish_space/screens/publish_space.view.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mapbox;
import 'package:shimmer/shimmer.dart';

import '../../../constants/ui/colors.dart';

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
    setupPositionTracking();
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
            zoom: 15,
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
    _positionStreamSubscription?.cancel();

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

  StreamSubscription? _positionStreamSubscription;

  setupPositionTracking() async {
    _positionStreamSubscription?.cancel();
    _positionStreamSubscription =
        geolocator.Geolocator.getPositionStream().listen((position) {
      //     calculate distance between two points

      double distanceInMeters = geolocator.Geolocator.distanceBetween(
        _currentPosition!.lat.toDouble(),
        _currentPosition!.lng.toDouble(),
        position.latitude,
        position.longitude,
      );
      // run a code and reset the current position to the new position if the distance is greater than 100 meters
      if (distanceInMeters > 400) {
        _currentPosition =
            mapbox.Position(position.longitude, position.latitude);
        context.read<MapBloc>().add(GetNearbyPlaces(
              queryParams: MapQueryParams(
                currentPoint: "${position.latitude},${position.longitude}",
                radius: 8000,
                drivingMode: false,
                options: ['spaces', 'events'],
              ),
            ));
      }

      debugPrint("Distance in meters: $distanceInMeters");
      mapboxController.setCamera(
        mapbox.CameraOptions(
          center: mapbox.Point(
            coordinates: mapbox.Position(
              position.longitude,
              position.latitude,
            ),
          ),
          zoom: 15,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return isLocationLoading
        ? const HomePageShimmer()
        : hasNoPermission
            ? const NoMapPermissionSection()
            : BlocConsumer<MapBloc, MapState>(
                listener: (context, state) {},
                builder: (context, state) {
                  return Stack(
                    alignment: Alignment.topCenter,
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
                          mapboxController.location.updateSettings(
                            mapbox.LocationComponentSettings(
                              enabled: true,
                              pulsingEnabled: true,

                              puckBearingEnabled: true,
                              pulsingMaxRadius: 40,
                              // pulsingColor: 0xffD899FF,
                            ),
                          );

                          await mapboxController
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
                      const HomeMapBottomSection(),
                      // Show a nice chip to show the user's current location
                      Positioned(
                        top: 70,
                        child: state is MapLoading
                            ? GestureDetector(
                                child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(1000),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.5),
                                          spreadRadius: 1,
                                          blurRadius: 7,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      spacing: 10,
                                      children: [
                                        Text(
                                          "Fetching Nearby Spaces",
                                          style: TextStyle(
                                            color: AppColors.primary500,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    )),
                              )
                            : const SizedBox(),
                      ),
                    ],
                  );
                },
              );
  }

  @override
  bool get wantKeepAlive => true;
}

class HomePageShimmer extends StatelessWidget {
  const HomePageShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
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
    );
  }
}
