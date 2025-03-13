import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart' as geolocator;
import 'package:here_sdk/core.dart';
import 'package:here_sdk/gestures.dart';
import 'package:here_sdk/mapview.dart';
import 'package:iconly/iconly.dart';
import 'package:iconsax/iconsax.dart';
import 'package:letdem/constants/ui/colors.dart';
import 'package:letdem/constants/ui/dimens.dart';
import 'package:letdem/constants/ui/typo.dart';
import 'package:letdem/enums/EventTypes.dart';
import 'package:letdem/features/map/map_bloc.dart';
import 'package:letdem/global/popups/popup.dart';
import 'package:letdem/global/widgets/button.dart';
import 'package:letdem/global/widgets/chip.dart';
import 'package:letdem/models/auth/map/map_options.model.dart';
import 'package:letdem/models/auth/map/nearby_payload.model.dart';
import 'package:letdem/services/map/map_asset_provider.service.dart';
import 'package:letdem/services/res/navigator.dart';
import 'package:letdem/views/app/home/widgets/home/home_bottom_section.widget.dart';
import 'package:letdem/views/app/home/widgets/home/no_connection.widget.dart';
import 'package:letdem/views/app/home/widgets/home/shimmers/home_page_shimmer.widget.dart';
import 'package:letdem/views/app/maps/route.view.dart';
import 'package:letdem/views/app/publish_space/screens/publish_space.view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView>
    with AutomaticKeepAliveClientMixin {
  HereMapController? _mapController;

  GeoCoordinates? _currentPosition;

  bool isLocationLoading = false;
  bool isLoadingAssets = true;
  bool hasNoPermission = false;

  final MapAssetsProvider _assetsProvider = MapAssetsProvider();

  MapMarker? _currentLocationMarker;
  final Map<MapMarker, Space> _spaceMarkers = {};
  final Map<MapMarker, Event> _eventMarkers = {};

  @override
  void initState() {
    super.initState();
    _loadAssets();
    _getCurrentLocation();
  }

  Future<void> _loadAssets() async {
    await _assetsProvider.loadAssets();
    setState(() {
      isLoadingAssets = false;
    });
  }

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
              GeoCoordinates(position.latitude, position.longitude);
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

  void _addMapMarkers(List<Space> spaces, List<Event> events) {
    _spaceMarkers.clear();
    _eventMarkers.clear();

    for (var space in spaces) {
      try {
        Uint8List imageData = _assetsProvider.getImageForType(space.type);

        MapImage mapImage =
            MapImage.withPixelDataAndImageFormat(imageData, ImageFormat.png);

        final marker = MapMarker(
          GeoCoordinates(space.location.point.lat, space.location.point.lng),
          mapImage,
        );

        _mapController?.mapScene.addMapMarker(marker);
        _spaceMarkers[marker] = space;
      } catch (e) {
        print("Error adding space marker: $e");
      }
    }

    for (var event in events) {
      try {
        Uint8List imageData = _assetsProvider.getEventIcon(event.type);

        MapImage mapImage =
            MapImage.withPixelDataAndImageFormat(imageData, ImageFormat.png);

        final marker = MapMarker(
          GeoCoordinates(event.location.point.lat, event.location.point.lng),
          mapImage,
        );

        _mapController?.mapScene.addMapMarker(marker);
        _eventMarkers[marker] = event;
      } catch (e) {
        print("Error adding event marker: $e");
      }
    }
  }

  void _setTapGestureHandler() {
    _mapController!.gestures.tapListener = TapListener((Point2D touchPoint) {
      _pickMapMarker(touchPoint);
    });
  }

  void _pickMapMarker(Point2D touchPoint) {
    Point2D originInPixels = Point2D(touchPoint.x, touchPoint.y);
    Size2D sizeInPixels = Size2D(1, 1);
    Rectangle2D rectangle = Rectangle2D(originInPixels, sizeInPixels);

    List<MapSceneMapPickFilterContentType> contentTypesToPickFrom = [
      MapSceneMapPickFilterContentType.mapItems
    ];

    MapSceneMapPickFilter filter =
        MapSceneMapPickFilter(contentTypesToPickFrom);
    _mapController!.pick(filter, rectangle, (pickMapItemsResult) {
      if (pickMapItemsResult == null) return;

      PickMapItemsResult? mapItemsResult = pickMapItemsResult.mapItems;

      if (mapItemsResult != null) {
        List<MapMarker>? mapMarkerList = mapItemsResult.markers;

        if (mapMarkerList.isNotEmpty) {
          MapMarker topmostMapMarker = mapMarkerList.first;

          if (_spaceMarkers.containsKey(topmostMapMarker)) {
            Space space = _spaceMarkers[topmostMapMarker]!;
            showSpacePopup(space: space);
          } else if (_eventMarkers.containsKey(topmostMapMarker)) {
            Event event = _eventMarkers[topmostMapMarker]!;
            showEventPopup(
              event: event,
            );
          }
        }
      }
    });
  }

  showEventPopup({
    required Event event,
  }) {
    AppPopup.showBottomSheet(
      context,
      Padding(
        padding: EdgeInsets.all(Dimens.defaultMargin + 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: [
                Image(
                  image: AssetImage(
                    _assetsProvider.getAssetEvent(event.type),
                  ),
                  height: 40,
                ),
                Dimens.space(1),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          getEventMessage(event.type),
                          style: Typo.largeBody.copyWith(
                              fontWeight: FontWeight.w700, fontSize: 18),
                        ),
                        Dimens.space(2),
                        DecoratedChip(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 5),
                          text: '${geolocator.Geolocator.distanceBetween(
                            _currentPosition!.latitude,
                            _currentPosition!.longitude,
                            event.location.point.lat,
                            event.location.point.lng,
                          ).floor()}m away',
                          textStyle: Typo.smallBody.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.green600,
                          ),
                          icon: Iconsax.clock,
                          color: AppColors.green500,
                        )
                      ],
                    ),
                    Text(
                      event.location.streetName,
                      style: Typo.largeBody.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: AppColors.neutral600),
                    ),
                  ],
                ),
              ],
            ),
            Dimens.space(4),
            Row(
              children: <Widget>[
                const Flexible(
                  child: PrimaryButton(
                    text: 'Got it, Thank you',
                  ),
                ),
                Dimens.space(1),
                Flexible(
                  child: PrimaryButton(
                    outline: true,
                    background: AppColors.primary50,
                    borderColor: Colors.transparent,
                    color: AppColors.primary500,
                    text: 'Feedback',
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  showSpacePopup({
    required Space space,
  }) {
    AppPopup.showBottomSheet(
      context,
      Padding(
        padding: EdgeInsets.all(Dimens.defaultMargin + 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(13),
                      child: Image(
                        image: NetworkImage(space.image),
                        height: 100,
                        width: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Dimens.space(2),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              SvgPicture.asset(
                                getSpaceTypeIcon(space.type),
                                width: 20,
                                height: 20,
                              ),
                              Dimens.space(1),
                              Text(
                                getSpaceAvailabilityMessage(space.type),
                                style: Typo.largeBody
                                    .copyWith(fontWeight: FontWeight.w800),
                              ),
                            ],
                          ),
                          Text(
                            space.location.streetName,
                            style: Typo.largeBody.copyWith(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: AppColors.neutral600),
                          ),
                          Dimens.space(1),
                          DecoratedChip(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 5),
                            text:
                                '${parseMeters(geolocator.Geolocator.distanceBetween(
                              _currentPosition!.latitude,
                              _currentPosition!.longitude,
                              space.location.point.lat,
                              space.location.point.lng,
                            ))} away',
                            textStyle: Typo.smallBody.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.green600,
                            ),
                            icon: Iconsax.clock,
                            color: AppColors.green500,
                          )
                        ],
                      ),
                    ),
                  ],
                ),
                Dimens.space(2),
                PrimaryButton(
                  icon: IconlyBold.location,
                  text: 'Navigate to Space',
                  onTap: () {
                    NavigatorHelper.to(TrafficRouteLineExample(
                      hideToggle: true,
                      streetName: space.location.streetName,
                      lat: space.location.point.lat,
                      lng: space.location.point.lng,
                    ));
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showMarkerPopup({
    required String title,
    required String type,
    required String details,
    required var location,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Type: $type'),
              const SizedBox(height: 8),
              Text('Details: $details'),
              const SizedBox(height: 8),
              Text(
                'Location: Lat ${location.point.lat}, Lng ${location.point.lng}',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('More Details'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _onMapCreated(HereMapController hereMapController) {
    _mapController = hereMapController;

    const double distanceToEarthInMeters = 8000;
    MapMeasure mapMeasureZoom =
        MapMeasure(MapMeasureKind.distanceInMeters, distanceToEarthInMeters);

    GeoCoordinates targetCoordinates =
        _currentPosition ?? GeoCoordinates(37.3318, -122.0312);

    hereMapController.camera
        .lookAtPointWithMeasure(targetCoordinates, mapMeasureZoom);

    _setTapGestureHandler();

    hereMapController.mapScene.loadSceneForMapScheme(MapScheme.normalDay,
        (error) {
      if (error != null) {
        print('Map scene not loaded. MapError: ${error.toString()}');
      } else {}
    });

    final state = context.read<MapBloc>().state;
    if (state is MapLoaded) {
      _addMapMarkers(state.payload.spaces, state.payload.events);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return isLocationLoading || isLoadingAssets
        ? const HomePageShimmer()
        : hasNoPermission
            ? const NoMapPermissionSection()
            : BlocConsumer<MapBloc, MapState>(
                listener: (context, state) {
                  if (state is MapLoaded && _mapController != null) {
                    _addMapMarkers(state.payload.spaces, state.payload.events);
                  }
                },
                builder: (context, state) {
                  return Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      _currentPosition != null
                          ? HereMap(
                              key: UniqueKey(),
                              onMapCreated: _onMapCreated,
                            )
                          : const CircularProgressIndicator(),
                      const HomeMapBottomSection(),
                    ],
                  );
                },
              );
  }

  @override
  void dispose() {
    _mapController = null;
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;
}
