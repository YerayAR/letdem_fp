import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart' as geolocator;
import 'package:here_sdk/core.dart';
import 'package:here_sdk/gestures.dart';
import 'package:here_sdk/location.dart';
import 'package:here_sdk/mapview.dart';
import 'package:letdem/features/auth/models/map_options.model.dart';
import 'package:letdem/features/auth/models/nearby_payload.model.dart'
    hide Location;
import 'package:letdem/features/map/map_bloc.dart';
import 'package:letdem/views/app/home/popups/event.popup.dart';
import 'package:letdem/views/app/home/popups/space.popup.dart';
import 'package:letdem/views/app/home/widgets/home/home_bottom_section.widget.dart';
import 'package:letdem/views/app/home/widgets/home/no_connection.widget.dart';
import 'package:letdem/views/app/home/widgets/home/shimmers/home_page_shimmer.widget.dart';

import '../../../common/popups/popup.dart';
import '../../../infrastructure/services/map/map_asset_provider.service.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView>
    with AutomaticKeepAliveClientMixin {
  // ---------------------------------------------------------------------------
  // Map & Location State
  // ---------------------------------------------------------------------------
  HereMapController? _mapController;
  GeoCoordinates? _currentPosition;
  GeoCoordinates? _lastFetchPosition;

  bool isLocationLoading = false;
  bool isLoadingAssets = true;
  bool hasNoPermission = false;
  bool _isListeningToLocation = false;

  late LocationEngine _locationEngine;
  LocationIndicator? _locationIndicator;
  LocationListener? _locationListener;

  static const double TRIGGER_DISTANCE_METERS = 250.0;

  // ---------------------------------------------------------------------------
  // Marker & Asset State
  // ---------------------------------------------------------------------------
  final MapAssetsProvider _assetsProvider = MapAssetsProvider();

  MapMarker? _currentLocationMarker;
  final Map<MapMarker, Space> _spaceMarkers = {};
  final Map<MapMarker, Event> _eventMarkers = {};

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------
  @override
  void initState() {
    super.initState();
    _loadAssets();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    if (_locationListener != null) {
      _locationEngine.removeLocationListener(_locationListener!);
    }
    _locationIndicator?.disable();
    _locationIndicator = null;
    _mapController = null;
    _isListeningToLocation = false;
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  // ---------------------------------------------------------------------------
  // Asset Loading
  // ---------------------------------------------------------------------------
  Future<void> _loadAssets() async {
    setState(() => isLoadingAssets = true);
    await _assetsProvider.loadAssets();
    setState(() => isLoadingAssets = false);
  }

  // ---------------------------------------------------------------------------
  // Location Setup
  // ---------------------------------------------------------------------------
  Future<void> _getCurrentLocation() async {
    try {
      setState(() => isLocationLoading = true);
      bool serviceEnabled =
          await geolocator.Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        await geolocator.Geolocator.openLocationSettings();
        setState(() {
          isLocationLoading = false;
          hasNoPermission = true;
        });
        return;
      }

      var permission = await geolocator.Geolocator.checkPermission();
      if (permission == geolocator.LocationPermission.denied ||
          permission == geolocator.LocationPermission.deniedForever) {
        permission = await geolocator.Geolocator.requestPermission();
        if (permission == geolocator.LocationPermission.denied ||
            permission == geolocator.LocationPermission.deniedForever) {
          setState(() {
            hasNoPermission = true;
            isLocationLoading = false;
          });
          return;
        }
      }

      final position = await geolocator.Geolocator.getCurrentPosition(
        desiredAccuracy: geolocator.LocationAccuracy.high,
      );

      _currentPosition = GeoCoordinates(position.latitude, position.longitude);
      setState(() => isLocationLoading = false);

      if (_mapController != null && _currentPosition != null) {
        _addMyLocationToMap(Location.withCoordinates(_currentPosition!));
        _setupLocationUpdates();
        _fetchNearbyPlaces(_currentPosition!);
      }
    } catch (e) {
      debugPrint("Error getting location: $e");
      setState(() => isLocationLoading = false);
    }
  }

  void _setupLocationUpdates() {
    if (_mapController == null ||
        _currentPosition == null ||
        _isListeningToLocation) return;

    try {
      _locationEngine = LocationEngine();
      _locationListener = LocationListener((Location location) {
        _currentPosition = location.coordinates;
        setState(() {});
        _locationIndicator?.updateLocation(location);
        _checkDistanceAndFetchIfNeeded(location.coordinates);
      });

      _locationEngine.addLocationListener(_locationListener!);
      _locationEngine.startWithLocationAccuracy(LocationAccuracy.navigation);
      _isListeningToLocation = true;
    } catch (e) {
      debugPrint("Location setup error: $e");
    }
  }

  void _checkDistanceAndFetchIfNeeded(GeoCoordinates newPosition) {
    if (_lastFetchPosition == null) {
      _fetchNearbyPlaces(newPosition);
      return;
    }

    final distanceMoved = geolocator.Geolocator.distanceBetween(
      _lastFetchPosition!.latitude,
      _lastFetchPosition!.longitude,
      newPosition.latitude,
      newPosition.longitude,
    );

    if (distanceMoved >= TRIGGER_DISTANCE_METERS) {
      _fetchNearbyPlaces(newPosition);
    }
  }

  void _addMyLocationToMap(Location myLocation) {
    _locationIndicator ??= LocationIndicator()
      ..isAccuracyVisualized = false
      ..locationIndicatorStyle = LocationIndicatorIndicatorStyle.navigation
      ..enable(_mapController!)
      ..setHaloColor(
          LocationIndicatorIndicatorStyle.navigation, Colors.transparent);

    _locationIndicator!.updateLocation(myLocation);

    if (_lastFetchPosition == null) {
      _mapController!.camera.lookAtPointWithMeasure(
        myLocation.coordinates,
        MapMeasure(MapMeasureKind.distanceInMeters, 3000),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Data Fetching
  // ---------------------------------------------------------------------------
  void _fetchNearbyPlaces(GeoCoordinates position) {
    _lastFetchPosition = position;
    context.read<MapBloc>().add(GetNearbyPlaces(
          queryParams: MapQueryParams(
            currentPoint: "${position.latitude},${position.longitude}",
            radius: 8000,
            drivingMode: false,
            options: ['spaces', 'events'],
          ),
        ));
  }

  // ---------------------------------------------------------------------------
  // Map Markers
  // ---------------------------------------------------------------------------
  void _addMapMarkers(List<Space> spaces, List<Event> events) {
    for (var marker in _spaceMarkers.keys.toList()) {
      _mapController?.mapScene.removeMapMarker(marker);
    }
    for (var marker in _eventMarkers.keys.toList()) {
      _mapController?.mapScene.removeMapMarker(marker);
    }

    _spaceMarkers.clear();
    _eventMarkers.clear();

    for (var space in spaces) {
      try {
        final imageData = _assetsProvider.getImageForType(space.type);
        final marker = MapMarker(
          GeoCoordinates(space.location.point.lat, space.location.point.lng),
          MapImage.withPixelDataAndImageFormat(imageData, ImageFormat.png),
        );
        _mapController?.mapScene.addMapMarker(marker);
        marker.fadeDuration = const Duration(seconds: 2);
        _spaceMarkers[marker] = space;
      } catch (e) {
        debugPrint("Space marker error: $e");
      }
    }

    for (var event in events) {
      try {
        final imageData = _assetsProvider.getEventIcon(event.type);
        print(
            "??Adding ${event.type} marker at ${event.location.point.lat}, ${event.location.point.lng}");
        final marker = MapMarker(
          GeoCoordinates(event.location.point.lat, event.location.point.lng),
          MapImage.withPixelDataAndImageFormat(imageData, ImageFormat.png),
        );
        marker.fadeDuration = const Duration(seconds: 2);
        _mapController?.mapScene.addMapMarker(marker);
        _eventMarkers[marker] = event;
      } catch (e) {
        debugPrint("Event marker error: $e");
      }
    }
  }

  void _setTapGestureHandler() {
    _mapController!.gestures.tapListener = TapListener((touchPoint) {
      _pickMapMarker(touchPoint);
    });
  }

  void _pickMapMarker(Point2D touchPoint) {
    final rectangle = Rectangle2D(touchPoint, Size2D(1, 1));
    final filter =
        MapSceneMapPickFilter([MapSceneMapPickFilterContentType.mapItems]);

    _mapController?.pick(filter, rectangle, (result) {
      if (result == null || result.mapItems == null) return;

      final markers = result.mapItems!.markers;
      if (markers.isNotEmpty) {
        final topMarker = markers.first;
        if (_spaceMarkers.containsKey(topMarker)) {
          showSpacePopup(space: _spaceMarkers[topMarker]!);
        } else if (_eventMarkers.containsKey(topMarker)) {
          showEventPopup(event: _eventMarkers[topMarker]!);
        }
      }
    });
  }

  // ---------------------------------------------------------------------------
  // Map Lifecycle
  // ---------------------------------------------------------------------------
  void _onMapCreated(HereMapController controller) {
    _mapController = controller;
    _setTapGestureHandler();

    _mapController!.mapScene.loadSceneForMapScheme(MapScheme.normalDay,
        (error) {
      if (error != null) {
        debugPrint('Map load error: $error');
        return;
      }

      final target = _currentPosition ?? GeoCoordinates(37.3318, -122.0312);
      _mapController!.camera.lookAtPointWithMeasure(
        target,
        MapMeasure(MapMeasureKind.distanceInMeters, 14000),
      );

      if (_currentPosition != null) {
        _addMyLocationToMap(Location.withCoordinates(_currentPosition!));
        _setupLocationUpdates();
        _fetchNearbyPlaces(_currentPosition!);
      }
    });
  }

  // ---------------------------------------------------------------------------
  // UI
  // ---------------------------------------------------------------------------
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
                          ? HereMap(onMapCreated: _onMapCreated)
                          : const Center(child: CircularProgressIndicator()),
                      const HomeMapBottomSection(),
                    ],
                  );
                },
              );
  }

  // ---------------------------------------------------------------------------
  // Popup Builders
  // ---------------------------------------------------------------------------

  showEventPopup({
    required Event event,
  }) {
    AppPopup.showBottomSheet(
      context,
      EventPopupSheet(event: event, currentPosition: _currentPosition!),
    );
  }

  showSpacePopup({
    required Space space,
  }) {
    AppPopup.showBottomSheet(
      context,
      SpacePopupSheet(space: space, currentPosition: _currentPosition!),
    );
  }
}
