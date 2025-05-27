import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:here_sdk/core.dart' as HERE;
import 'package:here_sdk/core.engine.dart';
import 'package:here_sdk/core.errors.dart';
import 'package:here_sdk/gestures.dart';
import 'package:here_sdk/location.dart' as HERE;
import 'package:here_sdk/mapview.dart';
import 'package:here_sdk/navigation.dart' as HERE;
import 'package:here_sdk/routing.dart' as HERE;
import 'package:iconly/iconly.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:letdem/common/popups/multi_selector.popup.dart';
import 'package:letdem/common/popups/popup.dart';
import 'package:letdem/common/widgets/button.dart';
import 'package:letdem/common/widgets/chip.dart';
import 'package:letdem/core/constants/colors.dart';
import 'package:letdem/core/constants/dimens.dart';
import 'package:letdem/core/constants/typo.dart';
import 'package:letdem/core/enums/EventTypes.dart';
import 'package:letdem/core/enums/PublishSpaceType.dart';
import 'package:letdem/core/extensions/user.dart';
import 'package:letdem/features/activities/activities_bloc.dart';
import 'package:letdem/features/activities/activities_state.dart';
import 'package:letdem/features/activities/presentation/bottom_sheets/add_event_sheet.widget.dart';
import 'package:letdem/features/auth/models/map_options.model.dart';
import 'package:letdem/features/auth/models/nearby_payload.model.dart';
import 'package:letdem/features/map/map_bloc.dart';
import 'package:letdem/features/map/presentation/views/route.view.dart';
import 'package:letdem/infrastructure/api/api/endpoints.dart';
import 'package:letdem/infrastructure/services/map/map_asset_provider.service.dart';
import 'package:letdem/infrastructure/services/res/navigator.dart';
import 'package:letdem/infrastructure/toast/toast/toast.dart';
import 'package:letdem/infrastructure/toast/toast/tone.dart';
import 'package:letdem/infrastructure/tts/tts/tts.dart';

import '../../../../common/popups/success_dialog.dart';

class NavigationView extends StatefulWidget {
  final double destinationLat;
  final double destinationLng;

  final bool isNavigatingToParking;

  final String? parkingSpaceID;

  const NavigationView({
    super.key,
    required this.destinationLat,
    this.isNavigatingToParking = false,
    required this.destinationLng,
    this.parkingSpaceID,
  });

  @override
  State<NavigationView> createState() => _NavigationViewState();
}

class _NavigationViewState extends State<NavigationView> {
  // Constants
  static const double _initialZoomDistanceInMeters = 8000;
  static const double _mapPadding = 20;
  static const double _buttonRadius = 26;
  static const double _containerPadding = 15;
  static const double _borderRadius = 20;
  static const int _distanceTriggerThreshold =
      200; // 50m threshold for triggering
  DateTime? _navigationStartTime;
  bool _hasShownFatigueAlert = false;

  // Controllers and engines
  HereMapController? _hereMapController;
  late final AppLifecycleListener _lifecycleListener;
  HERE.RoutingEngine? _routingEngine;
  HERE.VisualNavigator? _visualNavigator;
  HERE.LocationEngine? _locationEngine;

  // Navigation state
  HERE.GeoCoordinates? _currentLocation;

  double _speed = 0;
  bool _isNavigating = false;
  bool _isLoading = false;
  String _navigationInstruction = "";
  int _totalRouteTime = 0;
  bool _isMuted = false;
  String _errorMessage = "";
  int _lastTriggerDistance = 10;
  double _lastLatitude = 0;
  double _lastLongitude = 0;
  int _distanceTraveled = 0;

  Space? _currentSpace;

  // Added for the fixes
  bool _hasShownArrivalNotification = false;
  HERE.SpeedLimit? _currentSpeedLimit;
  bool _isOverSpeedLimit = false;

// Add this method to initialize the speed limit listener
  void _setupSpeedLimitListener() {
    if (_visualNavigator == null) return;

    debugPrint('🚗 Setting up speed limit listener...');

    _visualNavigator!.speedLimitListener =
        HERE.SpeedLimitListener((HERE.SpeedLimit? speedLimit) {
      if (speedLimit == null) {
        debugPrint('⚠️ No speed limit information available');
        setState(() {
          _currentSpeedLimit = null;
        });
        return;
      }

      debugPrint(
          '🛑 Speed limit updated: ${speedLimit.speedLimitInMetersPerSecond} m/s');

      setState(() {
        _currentSpeedLimit = speedLimit;

        // Check if current speed exceeds speed limit (with a small buffer)
        if (_speed > 0 && _currentSpeedLimit != null) {
          // Adding a 5% buffer to avoid overly sensitive alerts
          final buffer =
              _currentSpeedLimit!.speedLimitInMetersPerSecond! * 0.05;
          _isOverSpeedLimit = _speed >
              (_currentSpeedLimit!.speedLimitInMetersPerSecond! + buffer);

          // Show speed limit alert if over the limit and not already shown
          if (_isOverSpeedLimit && !_isMuted) {
            _showSpeedLimitAlert();
          }
        }
      });
    });

    debugPrint('✅ Speed limit listener set up successfully');
  }

  Widget _buildSpeedLimitIndicator() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 120,
      right: _mapPadding,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Current maximum speed indicator
            Container(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 13),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    (_speed * 3.6).round().toString(),
                    style: TextStyle(
                      color: Colors.orange.shade700,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                  Text(
                    "Km/h",
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Speed limit indicator
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.red, width: 2),
              ),
              child: Center(
                child: _currentSpeedLimit != null &&
                        _currentSpeedLimit!.speedLimitInMetersPerSecond != null
                    ? Text(
                        "${(_currentSpeedLimit!.speedLimitInMetersPerSecond! * 3.6).round()}",
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      )
                    : Icon(
                        Icons.speed,
                        color: Colors.grey.shade400,
                        size: 18,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

// Add this method to show speed limit alerts
  void _showSpeedLimitAlert() {
    if (_currentSpeedLimit == null || context.isSpeedAlertEnabled) return;

    // Convert m/s to km/h for display
    final speedLimitKmh =
        (_currentSpeedLimit!.speedLimitInMetersPerSecond! * 3.6).round();
    final currentSpeedKmh = (_speed * 3.6).round();

    AlertHelper.showWarning(
      context: context,
      title: 'Speed Limit Alert',
      subtext: 'You are driving at speed limit, slow down',
    );

    // Optionally use text-to-speech for alert
    if (!_isMuted) {
      speech.speak("Speed limit is $speedLimitKmh kilometers per hour");
    }
  }

  // Map of direction icons
  final Map<String, IconData> _directionIcons = {
    'turn right': Icons.turn_right,
    'turn left': Icons.turn_left,
    'go straight': Icons.arrow_upward,
    'make a u-turn': Icons.u_turn_left,
  };

  @override
  void initState() {
    print("IS navigating to parking: ${widget.isNavigatingToParking}");
    print("Parking space ID: ${widget.parkingSpaceID}");
    // assert(
    //   widget.isNavigatingToParking && widget.parkingSpaceID != null,
    //   "isNavigatingToParking cannot be null",
    // );
    super.initState();

    // Set up app lifecycle listener
    _lifecycleListener = AppLifecycleListener(
      onDetach: _cleanupNavigation,
      onHide: _cleanupNavigation,
      onPause: _cleanupNavigation,
      onRestart: _startNavigation,
    );

    // Delay navigation start until map is created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestLocationPermission();
    });
  }

  putParkingSpacesOnMap() {
    if (_currentLocation == null) return;

    context.read<MapBloc>().add(
          GetNearbyPlaces(
            queryParams: MapQueryParams(
              currentPoint:
                  "${_currentLocation?.latitude},${_currentLocation?.longitude}",
              previousPoint:
                  "${_currentLocation?.latitude},${_currentLocation?.longitude}",
              radius: 1000,
              drivingMode: true,
              options: ['spaces', 'events', 'alerts'],
            ),
          ),
        );
  }

  @override
  void dispose() {
    _cleanupNavigation();
    _rerouteDebounceTimer?.cancel();
    _distanceNotifier.dispose();
    _lifecycleListener.dispose();
    super.dispose();
  }

  // Permission handling
  Future<void> _requestLocationPermission() async {
    setState(() => _isLoading = true);
    await _assetsProvider.loadAssets();

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _errorMessage = "Location permission denied";
          _isLoading = false;
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _errorMessage =
            "Location permissions permanently denied, please enable in settings";
        _isLoading = false;
      });
      return;
    }

    setState(() => _isLoading = false);
  }

  final speech = SpeechService();

  bool _isPopupDisplayed = false;

  // Map initialization and cleanup
  void _onMapCreated(HereMapController hereMapController) {
    debugPrint('🗺️ Map created!');
    _hereMapController = hereMapController;

    // Enable all map gestures for user interaction
    _hereMapController?.gestures.enableDefaultAction(GestureType.pan);
    _hereMapController?.gestures.enableDefaultAction(GestureType.pinchRotate);
    _hereMapController?.gestures.enableDefaultAction(GestureType.twoFingerPan);
    _hereMapController?.gestures.enableDefaultAction(GestureType.pinchRotate);

    _hereMapController?.mapScene.enableFeatures({
      MapFeatures.buildingFootprints: MapFeatureModes.buildingFootprintsAll
    });
    _hereMapController?.mapScene
        .enableFeatures({MapFeatures.contours: MapFeatureModes.contoursAll});
    _hereMapController?.mapScene.enableFeatures(
        {MapFeatures.congestionZones: MapFeatureModes.congestionZonesAll});
    _hereMapController?.mapScene.enableFeatures({
      MapFeatures.environmentalZones: MapFeatureModes.environmentalZonesAll
    });
    _hereMapController?.mapScene.enableFeatures(
        {MapFeatures.landmarks: MapFeatureModes.landmarksTextured});
    _hereMapController?.mapScene
        .enableFeatures({MapFeatures.shadows: MapFeatureModes.shadowsAll});
    _hereMapController?.mapScene.enableFeatures(
        {MapFeatures.roadExitLabels: MapFeatureModes.roadExitLabelsAll});
    _hereMapController?.mapScene.enableFeatures(
        {MapFeatures.safetyCameras: MapFeatureModes.defaultMode});
    _hereMapController?.mapScene
        .enableFeatures({MapFeatures.shadows: MapFeatureModes.shadowsAll});
    _hereMapController?.mapScene
        .enableFeatures({MapFeatures.terrain: MapFeatureModes.defaultMode});
    _hereMapController?.mapScene.enableFeatures(
        {MapFeatures.trafficFlow: MapFeatureModes.trafficFlowWithFreeFlow});
    _hereMapController?.mapScene.enableFeatures(
        {MapFeatures.lowSpeedZones: MapFeatureModes.lowSpeedZonesAll});
    _hereMapController?.mapScene.enableFeatures(
        {MapFeatures.ambientOcclusion: MapFeatureModes.ambientOcclusionAll});
    _hereMapController?.mapScene.enableFeatures({
      MapFeatures.vehicleRestrictions:
          MapFeatureModes.vehicleRestrictionsActiveAndInactive
    });
    _hereMapController?.gestures.tapListener =
        TapListener((HERE.Point2D touchPoint) {
      _pickMapMarker(touchPoint);
    });
    _hereMapController?.gestures.panListener = PanListener((GestureState state,
        HERE.Point2D point1, HERE.Point2D point2, double distanceInPixels) {
      if (state == GestureState.begin) {
        // User started panning - disable automatic camera tracking
        if (_isCameraLocked && _visualNavigator != null) {
          setState(() {
            _isUserPanning = true;
            _isCameraLocked = false;
          });
          _visualNavigator!.cameraBehavior = null;
          debugPrint('🖐️ User panning detected, disabled camera tracking');
        }
      }
    });

    _loadMapScene();
  }

  void _toggleCameraTracking() {
    if (_visualNavigator == null) return;

    setState(() {
      _isCameraLocked = !_isCameraLocked;
      _isUserPanning = false;
    });

    if (_isCameraLocked) {
      // Re-enable camera tracking
      _visualNavigator!.cameraBehavior = HERE.FixedCameraBehavior();
      debugPrint('🔒 Camera tracking re-enabled');
    } else {
      // Disable camera tracking
      _visualNavigator!.cameraBehavior = null;
      debugPrint('🔓 Camera tracking disabled');
    }
  }

  bool _isUserPanning = false;

  void _loadMapScene() {
    if (_hereMapController == null) return;

    setState(() => _isLoading = true);

    _hereMapController!.mapScene.loadSceneForMapScheme(
      MapScheme.normalDay,
      (error) {
        if (error != null) {
          debugPrint('❌ Map scene not loaded. MapError: ${error.toString()}');
          setState(() {
            _errorMessage = "Failed to load map";
            _isLoading = false;
          });
          return;
        }

        debugPrint('✅ Map scene loaded.');
        MapMeasure mapMeasureZoom = MapMeasure(
            MapMeasureKind.distanceInMeters, _initialZoomDistanceInMeters);

        _hereMapController!.camera.lookAtPointWithMeasure(
            HERE.GeoCoordinates(widget.destinationLat, widget.destinationLng),
            mapMeasureZoom);

        _initLocationEngine();
        _startNavigation();
      },
    );
  }

  void _cleanupNavigation() {
    debugPrint('🧹 Cleaning up navigation resources...');

    // Stop visual rendering
    if (_visualNavigator != null) {
      _visualNavigator!.stopRendering();
      _visualNavigator = null; // Explicitly clear reference
    }

    // Stop location engine
    if (_locationEngine != null) {
      _locationEngine!.stop();
      _locationEngine = null; // Explicitly clear reference
    }

    // Clear route
    _routingEngine = null;

    // Reset navigation state
    setState(() {
      _isNavigating = false;
      _navigationInstruction = "";
      _totalRouteTime = 0;
      _errorMessage = "";
      _navigationInstruction = "";
      _isNavigating = false;
      _isLoading = false;
      _isMuted = false;
      _hasShownFatigueAlert = false;
      _currentSpeedLimit = null;
      _isOverSpeedLimit = false;
      _hasShownArrivalNotification = false;
    });

    debugPrint('✅ Navigation resources fully cleaned up.');
  }

  Future<bool> _handleBackPress() async {
    debugPrint('🔙 Back button pressed.');
    _cleanupNavigation();
    return true;
  }

  void _disposeHERESDK() {
    debugPrint('🧼 Disposing HERE SDK resources...');
    SDKNativeEngine.sharedInstance?.dispose();
    HERE.SdkContext.release();
    debugPrint('✅ HERE SDK resources disposed.');
  }

  // Location and routing
  void _initLocationEngine() {
    debugPrint('🛰️ Initializing Location Engine...');
    try {
      _locationEngine = HERE.LocationEngine();
      debugPrint('✅ Location Engine initialized.');
    } on InstantiationException {
      debugPrint('❌ Initialization of LocationEngine failed.');
      setState(() {
        _errorMessage = "Failed to initialize location services";
        _isLoading = false;
      });
    }
  }

  void _startNavigation() async {
    _cleanupNavigation();
    _navigationStartTime = DateTime.now();
    _hasShownFatigueAlert = false;

    if (_hereMapController == null) return;

    setState(() => _isLoading = true);

    debugPrint('🚗 Starting navigation...');
    double destLat = widget.destinationLat;
    double destLng = widget.destinationLng;

    try {
      var currentLocationGeo = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );

      debugPrint(
          '📍 Current location: ${currentLocationGeo.latitude}, ${currentLocationGeo.longitude}');

      _currentLocation = HERE.GeoCoordinates(
        currentLocationGeo.latitude,
        currentLocationGeo.longitude,
      );

      // Initialize last known position
      _lastLatitude = currentLocationGeo.latitude;
      _lastLongitude = currentLocationGeo.longitude;
      _distanceTraveled = 0;
      _lastTriggerDistance = 0;

      _calculateRoute(
        _currentLocation!,
        HERE.GeoCoordinates(destLat, destLng),
      );
    } catch (e) {
      debugPrint('❌ Error getting current location: $e');
      setState(() {
        _errorMessage = "Failed to get current location";
        _isLoading = false;
      });
    }
  }

  void _checkDistanceTrigger(double latitude, double longitude) {
    // Calculate distance between last position and current position
    final distanceBetweenPoints = Geolocator.distanceBetween(
      _lastLatitude,
      _lastLongitude,
      latitude,
      longitude,
    ).toInt();

    if (distanceBetweenPoints > 0) {
      _distanceTraveled += distanceBetweenPoints;

      // Update last known position
      _lastLatitude = latitude;
      _lastLongitude = longitude;

      // Check if we've traveled another 50m since last trigger
      if (_distanceTraveled - _lastTriggerDistance >=
          _distanceTriggerThreshold) {
        _lastTriggerDistance =
            (_distanceTraveled ~/ _distanceTriggerThreshold) *
                _distanceTriggerThreshold;

        // Trigger action for every 50m traveled
        _showDistanceTriggerToast();
      }
    }
  }

  void _showDistanceTriggerToast() {
    if (widget.isNavigatingToParking) return;
    debugPrint('Distance trigger: $_distanceTraveled meters traveled');
    context.read<MapBloc>().add(
          GetNearbyPlaces(
              queryParams: MapQueryParams(
            currentPoint: "$_lastLatitude,$_lastLongitude",
            previousPoint: "$_lastLatitude,$_lastLongitude",
            radius: 400,
            drivingMode: true,
            options: ['events', 'alerts', 'spaces'],
          )),
        );
  }

  final MapAssetsProvider _assetsProvider = MapAssetsProvider();
  final Map<MapMarker, Space> _spaceMarkers = {};
  final Map<MapMarker, Event> _eventMarkers = {};

  bool _isNavigatingToParking = false;
  String _parkingSpaceName =
      ""; // Store parking space name for the thank you message

// Modified showSpacePopup to set the flag when navigating to a parking space
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
                            text: '${parseMeters(Geolocator.distanceBetween(
                              _currentLocation!.latitude,
                              _currentLocation!.longitude,
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
                    // Close the popup first
                    Navigator.pop(context);

                    setState(() {
                      _currentSpace = space;
                    });

                    // Clean up existing navigation
                    _stopNavigation();
                    _cleanupNavigation();

                    // Navigate to the space directly instead of creating a new screen
                    setState(() {
                      _hasShownArrivalNotification = false;
                      _isLoading = true;
                      // Set flag for parking navigation and store space name
                      _isNavigatingToParking = true;
                      _parkingSpaceName = space.location.streetName;
                    });

                    // Recalculate route to the space
                    if (_currentLocation != null) {
                      _calculateRoute(
                          _currentLocation!,
                          HERE.GeoCoordinates(space.location.point.lat,
                              space.location.point.lng));

                      // Show toast notification
                      _showToast("Navigating to parking space",
                          backgroundColor: AppColors.primary500);
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _lastSpokenInstruction = "";

  final ValueNotifier<int> _distanceNotifier = ValueNotifier<int>(0);
  int _nextManuoverDistance = 0;
  Timer? _rerouteDebounceTimer;
  int _lastRerouteTime = 0;
  void _pickMapMarker(HERE.Point2D touchPoint) {
    final rectangle = HERE.Rectangle2D(touchPoint, HERE.Size2D(1, 1));
    final filter =
        MapSceneMapPickFilter([MapSceneMapPickFilterContentType.mapItems]);

    _hereMapController?.pick(filter, rectangle, (result) {
      if (result == null || result.mapItems == null) return;

      final markers = result.mapItems!.markers;
      if (markers.isNotEmpty) {
        final topMarker = markers.first;

        if (_spaceMarkers.containsKey(topMarker)) {
          final space = _spaceMarkers[topMarker]!;

          showSpacePopup(space: space);
        }
        if (_eventMarkers.containsKey(topMarker)) {
          final event = _eventMarkers[topMarker]!;

          AppPopup.showBottomSheet(
            context,
            EventFeedback(
              currentDistance: Geolocator.distanceBetween(
                _currentLocation!.latitude,
                _currentLocation!.longitude,
                event.location.point.lat,
                event.location.point.lng,
              ),
              event: event,
              onSubmit: () {
                NavigatorHelper.pop();
              },
            ),
          );
        }
      }
    });
  }

  void _addMapMarkers(List<Event> events, List<Space> spaces) {
    // Clear existing markers
    _hereMapController?.mapScene.removeMapMarkers(_spaceMarkers.keys.toList());
    _spaceMarkers.clear();
    for (var space in events) {
      try {
        Uint8List imageData = _assetsProvider.getEventIcon(space.type);

        MapImage mapImage =
            MapImage.withPixelDataAndImageFormat(imageData, ImageFormat.png);

        final marker = MapMarker(
          HERE.GeoCoordinates(
              space.location.point.lat, space.location.point.lng),
          mapImage,
        );
        marker.fadeDuration = const Duration(seconds: 2);

        _hereMapController?.mapScene.addMapMarker(marker);
        _eventMarkers[marker] = space;
      } catch (e) {
        print("Error adding space marker: $e");
      }
    }
    for (var space in spaces) {
      try {
        final imageData = _assetsProvider.getImageForType(space.type);
        final marker = MapMarker(
          HERE.GeoCoordinates(
              space.location.point.lat, space.location.point.lng),
          MapImage.withPixelDataAndImageFormat(imageData, ImageFormat.png),
        );
        marker.fadeDuration = const Duration(seconds: 2);

        _hereMapController?.mapScene.addMapMarker(marker);
        _spaceMarkers[marker] = space;
      } catch (e) {
        debugPrint("Space marker error: $e");
      }
    }
  }

  void _calculateRoute(
      HERE.GeoCoordinates start, HERE.GeoCoordinates destination) {
    debugPrint('🧭 Calculating route...');

    try {
      _routingEngine = HERE.RoutingEngine();
      debugPrint('✅ Routing Engine initialized.');
    } on InstantiationException {
      debugPrint('❌ Initialization of RoutingEngine failed.');
      setState(() {
        _errorMessage = "Failed to initialize routing";
        _isLoading = false;
      });
      return;
    }

    HERE.Waypoint startWaypoint = HERE.Waypoint(start);
    HERE.Waypoint destinationWaypoint = HERE.Waypoint(destination);

    // Create car options with realistic route
    final carOptions = HERE.CarOptions();
    carOptions.routeOptions.enableTolls = true;
    carOptions.routeOptions.optimizationMode = HERE.OptimizationMode.fastest;

    _routingEngine!.calculateCarRoute(
      [startWaypoint, destinationWaypoint],
      carOptions,
      (HERE.RoutingError? routingError, List<HERE.Route>? routeList) async {
        if (routingError == null && routeList != null && routeList.isNotEmpty) {
          HERE.Route calculatedRoute = routeList.first;

          _totalRouteTime = calculatedRoute.duration.inSeconds;
          _distanceNotifier.value =
              calculatedRoute.lengthInMeters; // Update distance notifier

          setState(() {
            _isNavigating = true;
            _isLoading = false;
          });

          _startGuidance(calculatedRoute);
        } else {
          final error = routingError?.toString() ?? "Unknown error";
          debugPrint('❌ Error while calculating route: $error');
          setState(() {
            _errorMessage = "Could not calculate route. Please try again.";
            _isLoading = false;
          });
        }
      },
    );
  }

  String normalManuevers = "";

  void _startGuidance(HERE.Route route) {
    if (_hereMapController == null) return;

    debugPrint('🧭 Starting visual guidance...');
    try {
      _visualNavigator = HERE.VisualNavigator();
      _setupRouteDeviationListener();
      debugPrint('✅ VisualNavigator initialized.');
    } on InstantiationException {
      debugPrint('❌ Initialization of VisualNavigator failed.');
      setState(() {
        _errorMessage = "Failed to initialize navigation";
        _isNavigating = false;
      });
      return;
    }

    _visualNavigator!.startRendering(_hereMapController!);
    debugPrint('📡 Started rendering navigator.');

    // Set up route progress listener with throttling
    DateTime lastUpdateTime = DateTime.now();

    _visualNavigator!.routeProgressListener =
        HERE.RouteProgressListener((HERE.RouteProgress routeProgress) {
      final now = DateTime.now();
      HERE.SectionProgress lastSectionProgress =
          routeProgress.sectionProgress.last;
      int distance = lastSectionProgress.remainingDistanceInMeters;

      print('🟡 Route progress update at ${now.toIso8601String()}');
      print('➡️ Remaining distance in section: $distance meters');
      print(
          '➡️ Section remaining duration: ${lastSectionProgress.remainingDuration.inSeconds} seconds');

      // Throttle updates to avoid too many setState calls
      if (now.difference(lastUpdateTime).inMilliseconds < 500) {
        print('⏱ Throttling update. Skipping this tick.');
        return;
      }

      if (!_isMuted && normalManuevers != _lastSpokenInstruction) {
        _lastSpokenInstruction = normalManuevers;
        speech.speak(normalManuevers);
      }

      _nextManuoverDistance = routeProgress
          .maneuverProgress.first.remainingDistanceInMeters
          .floor();

      final remainingDistanceInMeters =
          lastSectionProgress.remainingDistanceInMeters;
      final remainingDurationInSeconds =
          lastSectionProgress.remainingDuration.inSeconds;

      _distanceNotifier.value = remainingDistanceInMeters;

      // Show arrival notification when very close to destination (within 10 meters)
      if (remainingDistanceInMeters < 10) {
        print('✅ Within 10 meters of destination.');
        if (!_hasShownArrivalNotification) {
          print('📣 Showing arrival notification...');
          setState(() {
            _hasShownArrivalNotification = true;
          });

          if (_isNavigatingToParking) {
            print(
                '🅿️ Navigated to a selected parking space. Showing rating UI.');
            AppPopup.showBottomSheet(
                context,
                ParkingRatingWidget(
                  spaceID: _currentSpace?.id ?? widget.parkingSpaceID!,
                  onSubmit: () {
                    _stopNavigation();
                    _cleanupNavigation();
                    NavigatorHelper.pop();
                  },
                ));
          } else {
            print('🎯 Standard destination reached. Showing toast.');
            _showToast("You have arrived at your destination!",
                backgroundColor: AppColors.green600);
          }

          putParkingSpacesOnMap();
        }
      }

      // Load spaces if very close to destination
      if (remainingDistanceInMeters < 1) {
        print('📌 Less than 1 meter away. Checking if popup needs to show.');
        if (!_isPopupDisplayed) {
          print('🧩 Showing nearby parking spaces.');
          setState(() {
            _isPopupDisplayed = true;
          });

          putParkingSpacesOnMap();
        }
        return;
      }

      lastUpdateTime = now;

      final maneuver = routeProgress.maneuverProgress;
      if (maneuver.isEmpty) {
        print('⚠️ No maneuvers found in route progress.');
        return;
      }

      if (mounted) {
        _distanceNotifier.value = distance;

        setState(() {
          _totalRouteTime = remainingDurationInSeconds;
        });
        if (context.isFatigueAlertEnabled) {
          if (_navigationStartTime != null &&
              !_hasShownFatigueAlert &&
              DateTime.now().difference(_navigationStartTime!).inSeconds >=
                  10800) {
            _hasShownFatigueAlert = true;
            AlertHelper.showWarning(
              context: context,
              title: 'Fatigue Alert',
              subtext:
                  'You have been driving for 3 hours. Please consider taking a break.',
            );

            if (!_isMuted) {
              speech.speak(
                  "You have been driving for three hours. Please take a rest.");
            }
          }
        }
        if (distance < 10 &&
            (_isNavigatingToParking || widget.isNavigatingToParking)) {
          AppPopup.showBottomSheet(
            context,
            ParkingRatingWidget(
              spaceID: _currentSpace?.id ?? widget.parkingSpaceID!,
              onSubmit: () {
                _stopNavigation();
                _cleanupNavigation();
                NavigatorHelper.pop();
              },
            ),
          );
        }

        print('🚗 Maneuver updated:');
        print(
            '➡️ Distance to next maneuver: ${_distanceNotifier.value} meters');
        print(
            '📏 Total remaining route distance: ${_distanceNotifier.value} meters');
        print('⏳ Total remaining time: $_totalRouteTime seconds');
      }
    });

    //
    // // Add route deviation listener for re-routing

    // Set up voice instruction listener
    _visualNavigator!.eventTextListener =
        HERE.EventTextListener((HERE.EventText eventText) {
      String? streetName = getStreetNameFromManeuver(
        eventText.maneuverNotificationDetails!.maneuver,
      );

      debugPrint("🗣️ Voice maneuver text: $streetName");
      if (mounted) {
        setState(() {
          _navigationInstruction = streetName;
          normalManuevers = eventText.text;
        });
      }
    });

    // Set route and start location simulation
    _visualNavigator!.route = route;

    _setupLocationSource(_visualNavigator!, route);
  }

  bool _isRecalculatingRoute = false;

// Replace the entire routeDeviationListener implementation with this optimized version
  void _setupRouteDeviationListener() {
    _visualNavigator!.routeDeviationListener =
        HERE.RouteDeviationListener((HERE.RouteDeviation routeDeviation) {
      debugPrint('🛰️ Route deviation listener triggered');

      // Skip processing if already calculating a new route
      if (_isRecalculatingRoute) {
        debugPrint('⏳ Already recalculating route. Skipping...');
        return;
      }

      // Get current route or skip if none
      HERE.Route? route = _visualNavigator?.route;
      if (route == null) {
        debugPrint(
            '❌ No active route found. Skipping route deviation handling.');
        return;
      }

      // Get current location coordinates
      HERE.GeoCoordinates currentGeoCoordinates =
          routeDeviation.currentLocation.originalLocation.coordinates;
      debugPrint(
          '📍 Current location: (${currentGeoCoordinates.latitude}, ${currentGeoCoordinates.longitude})');

      // Calculate deviation distance
      double distanceInMeters = Geolocator.distanceBetween(
        _currentLocation!.latitude,
        _currentLocation!.longitude,
        currentGeoCoordinates.latitude,
        currentGeoCoordinates.longitude,
      );
      debugPrint('📏 Calculated deviation: $distanceInMeters meters');

      final now = DateTime.now().millisecondsSinceEpoch;

      debugPrint('⏰ Time since last reroute: ${now - _lastRerouteTime} ms');

      // Conditions to trigger reroute
      bool isSignificantlyOffRoute = true;
      bool isFarEnoughFromDestination = _distanceNotifier.value > 50;
      bool isTimeElapsedSinceLastReroute = (now - _lastRerouteTime > 5000);

      if (isSignificantlyOffRoute &&
          isFarEnoughFromDestination &&
          isTimeElapsedSinceLastReroute) {
        debugPrint(
            '⚠️ Significant deviation detected! Off by ${distanceInMeters}m');
        debugPrint('📡 Initiating reroute sequence...');

        // Cancel any existing timer
        _rerouteDebounceTimer?.cancel();

        // Set flag to prevent multiple calculations
        _isRecalculatingRoute = true;
        _lastRerouteTime = now;

        // Show toast to inform user
        _showToast(
          "Recalculating route...",
          backgroundColor: AppColors.red500,
        );

        // Force the UI to update before heavy calculation

        // Delay slightly to allow UI to update
        Future.delayed(const Duration(milliseconds: 100), () {
          debugPrint('🚀 Launching route recalculation from new position...');
          _recalculateRouteFromCurrentLocation(currentGeoCoordinates);
        });
      } else {
        debugPrint('✅ No reroute needed at this time.');
        if (!isFarEnoughFromDestination) {
          debugPrint('🏁 Already close to destination.');
        }
        if (!isTimeElapsedSinceLastReroute) {
          debugPrint('⌛ Too soon since last reroute.');
        }
      }
    });
  }

  bool _isCameraLocked = true; // Add this flag to track camera lock state

// New method to separate route recalculation logic
  void _recalculateRouteFromCurrentLocation(
      HERE.GeoCoordinates currentPosition) {
    if (_currentLocation == null) return;

    try {
      debugPrint('🧭 Recalculating route from current position...');

      HERE.Waypoint startWaypoint = HERE.Waypoint(currentPosition);
      HERE.Waypoint destinationWaypoint = HERE.Waypoint(
          HERE.GeoCoordinates(widget.destinationLat, widget.destinationLng));

      // Create car options with realistic route
      final carOptions = HERE.CarOptions();
      carOptions.routeOptions.enableTolls = true;
      carOptions.routeOptions.optimizationMode = HERE.OptimizationMode.fastest;

      // Check if routing engine is still valid
      _routingEngine ??= HERE.RoutingEngine();

      _routingEngine!.calculateCarRoute(
        [startWaypoint, destinationWaypoint],
        carOptions,
        (HERE.RoutingError? routingError, List<HERE.Route>? routeList) async {
          if (routingError == null &&
              routeList != null &&
              routeList.isNotEmpty) {
            HERE.Route calculatedRoute = routeList.first;

            _totalRouteTime = calculatedRoute.duration.inSeconds;
            _distanceNotifier.value =
                calculatedRoute.lengthInMeters; // Update distance notifier

            if (_visualNavigator != null && mounted) {
              // Set new route for visualization
              _visualNavigator!.route = calculatedRoute;

              // Update UI state
              setState(() {
                _isNavigating = true;
                _isRecalculatingRoute = false;
              });

              // Show success toast
            }
          } else {
            final error = routingError?.toString() ?? "Unknown error";
            debugPrint('❌ Error while recalculating route: $error');

            setState(() {
              _isRecalculatingRoute = false;
            });

            // Show error toast
            _showToast(
              "Could not recalculate route",
              backgroundColor: AppColors.red500,
            );
          }
        },
      );
    } catch (e) {
      debugPrint('❌ Exception during route recalculation: $e');
      setState(() {
        _isRecalculatingRoute = false;
      });
    }
  }

  String getStreetNameFromManeuver(HERE.Maneuver maneuver,
      {List<Locale> preferredLocales = const []}) {
    // Try next road name first (where the vehicle is heading)
    String? name = maneuver.nextRoadTexts.names.getDefaultValue();

    // Fallback to current road name if next is unavailable
    name ??= maneuver.roadTexts.names.getDefaultValue();

    return name ?? 'Unnamed Road';
  }

  void _setupLocationSource(
      HERE.LocationListener locationListener, HERE.Route route) {
    debugPrint('📍 Setting up navigation with visual map...');
    try {
      // Set the route for visualization first
      _visualNavigator!.route = route;
      _locationEngine = HERE.LocationEngine();

      _locationEngine?.startWithLocationAccuracy(
        HERE.LocationAccuracy.navigation,
      );

      _locationEngine!.addLocationListener(
        HERE.LocationListener((HERE.Location location) {
          // Update current location
          _currentLocation = location.coordinates;
          double? speed = location.speedInMetersPerSecond;

          setState(() {
            _speed = speed ?? 0;
          });

          // reset the last location if it is in 50m
          if (_lastLatitude == 0 && _lastLongitude == 0) {
            _lastLatitude = location.coordinates.latitude;
            _lastLongitude = location.coordinates.longitude;
          }

          // Check distance trigger for 50m intervals
          _checkDistanceTrigger(
            location.coordinates.latitude,
            location.coordinates.longitude,
          );
          locationListener.onLocationUpdated(location);
        }),
      );

      // Set visual navigator to follow the route
      _visualNavigator!.startRendering(_hereMapController!);
      _setupSpeedLimitListener();

      // Configure map view for 3D navigation
      // _hereMapController!.camera.lookAtPoint(
      //   HERE.GeoCoordinates(
      //     widget.destinationLat,
      //     widget.destinationLng,
      //   ),
      // );

      // Tilt camera for 3D effect
      _hereMapController!.camera.setOrientationAtTarget(
          HERE.GeoOrientationUpdate(0, 65) // 60-degree tilt for 3D view
          );

      debugPrint('✅ Navigation with 3D view started successfully');
    } catch (e) {
      debugPrint('❌ Failed to set up location simulation: $e');
      setState(() {
        _errorMessage = "Failed to start navigation visualization";
        _isNavigating = false;
        _isLoading = false;
      });
    }
  }

  void _stopNavigation() {
    debugPrint('🛑 Stopping navigation...');
    _cleanupNavigation();

    setState(() {
      _isNavigating = false;
      _navigationInstruction = "";
    });

    debugPrint('✅ Navigation stopped.');
  }

  // Add a method to show toast notifications
  void _showToast(String message, {Color backgroundColor = Colors.black}) {
    // Fluttertoast.showToast(
    //     msg: message,
    //     toastLength: Toast.LENGTH_LONG,
    //     gravity: ToastGravity.CENTER,
    //     timeInSecForIosWeb: 2,
    //     backgroundColor: backgroundColor,
    //     textColor: Colors.white,
    //     fontSize: 16.0
    // );
    // Toast.show(
    //   message,
    // );
  }

  // UI Components
  Widget _buildNavigationInstructionCard() {
    // Determine which icon to show based on the instruction text
    IconData directionIcon = Icons.navigation;

    // Check if any of the direction phrases are contained in the instruction
    for (final entry in _directionIcons.entries) {
      print(normalManuevers);
      if (normalManuevers.toLowerCase().contains(entry.key)) {
        directionIcon = entry.value;
        break;
      }
    }

    return Container(
      height: 90,
      padding: const EdgeInsets.symmetric(
          horizontal: _containerPadding, vertical: _containerPadding + 5),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(_borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.amber,
            ),
            child: Icon(directionIcon, color: Colors.black, size: 24),
          ),
          const SizedBox(width: 15),
          ValueListenableBuilder<int>(
            valueListenable: _distanceNotifier,
            builder: (context, state, _) {
              print("Distance: $state");
              if (state < 4) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    _isPopupDisplayed = true;
                    AppPopup.showBottomSheet(
                      context,
                      ParkingRatingWidget(
                        spaceID:
                            _currentSpace?.id ?? widget.parkingSpaceID ?? "-1",
                        onSubmit: () {
                          _stopNavigation();
                          _cleanupNavigation();
                          NavigatorHelper.pop();
                        },
                      ),
                    );
                  }
                });
              }
              return Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${_nextManuoverDistance.toFormattedDistance()} ahead',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                    Text(
                      _navigationInstruction,
                      style: const TextStyle(color: Colors.white, fontSize: 15),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          ),
          Dimens.space(1),
          CircleAvatar(
            backgroundColor: AppColors.neutral500.withOpacity(0.5),
            child: IconButton(
              icon: Icon(_isMuted ? Icons.volume_off : Icons.volume_up,
                  color: Colors.white),
              onPressed: () {
                setState(() {
                  _isMuted = !_isMuted;

                  // TODO: Implement actual muting of navigation instructions
                  if (_visualNavigator != null) {
                    // _visualNavigator!.isVoiceEnabled = !_isMuted;
                    // This would be the ideal implementation but depends on the HERE SDK version
                    debugPrint('🔊 Voice ${_isMuted ? 'muted' : 'unmuted'}');
                  }
                });
                if (_isMuted) {
                  speech.mute();
                } else {
                  speech.unmute();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationControls() {
    return Row(
      children: [
        // Close button
        CircleAvatar(
          radius: _buttonRadius,
          backgroundColor: Colors.white,
          child: IconButton(
            icon: const Icon(Icons.close, color: Colors.black),
            onPressed: () {
              _stopNavigation();
              Navigator.pop(context);
            },
          ),
        ),
        const Spacer(),

        // Time and distance indicator
        GestureDetector(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(2000),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  "${(_totalRouteTime.toFormattedTime())} (${_distanceNotifier.value.toFormattedDistance()})",
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),

        const Spacer(),

        // Add event button
        CircleAvatar(
          radius: _buttonRadius,
          backgroundColor: AppColors.red500,
          child: IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            tooltip: "Add event",
            onPressed: () {
              AppPopup.showBottomSheet(context, const AddEventBottomSheet());
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Container(
        color: Colors.white,
        child: const Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text("Preparing your navigation..."),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Center(
      child: Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(_errorMessage, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _errorMessage = "";
                    _isLoading = false;
                  });
                  _startNavigation();
                },
                child: const Text("Try Again"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MapBloc, MapState>(
      listener: (context, state) {
        if (state is MapLoaded) {
          // Add markers to the map
          _addMapMarkers(state.payload.events, state.payload.spaces);

          if (state.payload.alerts.isNotEmpty) {
            for (var alert in state.payload.alerts) {
              AlertHelper.showWarning(
                context: context,
                title: "${toBeginningOfSentenceCase(alert.type)} Alert",
                subtext: alert.type.toLowerCase() == "camera"
                    ? "You are in a CCTV Camera surveillance zone "
                    : "You are approaching a nearby radar zone",
              );
            }
          }
        }
        // TODO: implement listener
      },
      builder: (context, state) {
        return WillPopScope(
          onWillPop: _handleBackPress,
          child: Scaffold(
            body: Stack(
              children: [
                // Map layer
                HereMap(onMapCreated: _onMapCreated),
                _buildSpeedLimitIndicator(),
                // Loading indicator
                if (_isLoading) _buildLoadingIndicator(),
                Positioned(
                  top: MediaQuery.of(context).padding.top + 200,
                  right: _mapPadding,
                  child: CircleAvatar(
                    radius: _buttonRadius,
                    backgroundColor: Colors.white,
                    child: IconButton(
                      icon: Icon(
                        _isCameraLocked ? Icons.gps_fixed : Icons.gps_not_fixed,
                        color: _isCameraLocked
                            ? AppColors.primary500
                            : Colors.grey,
                      ),
                      onPressed: _toggleCameraTracking,
                      tooltip:
                          _isCameraLocked ? "Free camera" : "Lock to position",
                    ),
                  ),
                ),
                // Error message
                if (_errorMessage.isNotEmpty) _buildErrorMessage(),

                // Navigation instruction
                if (_isNavigating &&
                    _navigationInstruction.isNotEmpty &&
                    _distanceNotifier.value > 0)
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 10,
                    left: _mapPadding,
                    right: _mapPadding,
                    child: _buildNavigationInstructionCard(),
                  ),

                // Bottom controls
                if (_isNavigating)
                  Positioned(
                    bottom: 30,
                    left: _mapPadding,
                    right: _mapPadding,
                    child: _buildNavigationControls(),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Extension to parse seconds to minutes and seconds
extension TimeFormatter on int {
  String toFormattedTime() {
    int minutes = this ~/ 60;
    int seconds = this % 60;

    String minutesStr = minutes.toString().padLeft(2, '0');
    String secondsStr = seconds.toString().padLeft(2, '0');

    return "$minutesStr min".startsWith("00")
        ? "$secondsStr sec"
        : "$minutesStr min";
  }

//   format meters to km
  String toFormattedDistance() {
    if (this >= 1000) {
      return "${(this / 1000).toStringAsFixed(1)} km";
    } else {
      return "$this m";
    }
  }
}

class ParkingRatingWidget extends StatefulWidget {
  final VoidCallback onSubmit;

  final String spaceID;
  const ParkingRatingWidget(
      {super.key, required this.onSubmit, required this.spaceID});

  @override
  _ParkingRatingWidgetState createState() => _ParkingRatingWidgetState();
}

class _ParkingRatingWidgetState extends State<ParkingRatingWidget> {
  TakeSpaceType? _selectedOption;
  bool _submitted = false;

  final List<Map<String, dynamic>> _options = [
    {
      'id': 'take',
      'label': "I'll take it",
      'icon': Icons.thumb_up,
      'color': Colors.green.shade100,
      "enum": TakeSpaceType.TAKE_IT,
      'iconColor': Colors.green
    },
    {
      'id': 'inuse',
      'label': "It's in use",
      'icon': Icons.directions_car,
      "enum": TakeSpaceType.IN_USE,
      'color': AppColors.primary500.withOpacity(0.1),
      'iconColor': AppColors.primary500
    },
    {
      'id': 'notuseful',
      'label': "Not useful",
      "enum": TakeSpaceType.NOT_USEFUL,
      'icon': Icons.thumb_down,
      'color': Colors.amber.shade100,
      'iconColor': Colors.amber.shade700
    },
    {
      'id': 'prohibited',
      'label': "Prohibited",
      "enum": TakeSpaceType.PROHIBITED,
      'icon': Icons.not_interested,
      'color': Colors.red.shade100,
      'iconColor': Colors.red
    },
  ];

  void _handleSubmit() {
    context.read<ActivitiesBloc>().add(
          TakeSpaceEvent(
            type: _selectedOption as TakeSpaceType,
            spaceID: widget.spaceID,
          ),
        );
    return;

    if (_selectedOption != null) {
      setState(() {
        _submitted = true;
      });
      // Here you would typically send data to backend
      print('Selected option: $_selectedOption');
    }
  }

  void _resetForm() {
    setState(() {
      _selectedOption = null;
      _submitted = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _buildRatingForm();
  }

  Widget _buildRatingForm() {
    return BlocConsumer<ActivitiesBloc, ActivitiesState>(
      listener: (context, state) {
        if (state is ActivitiesPublished) {
          // Show success message
          AppPopup.showDialogSheet(
            context,
            SuccessDialog(
              title: "Your feedback has been submitted",
              subtext: "Thank you for your input!",
              onProceed: () {
                NavigatorHelper.pop();
                NavigatorHelper.pop();
                widget.onSubmit();
              },
            ),
          );
        }
        // TODO: implement listener
      },
      builder: (context, state) {
        return Container(
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Dimens.space(3),
                // Location icon
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: AppColors.primary500.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary500,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.location_on,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Text
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'You have arrived at your destination.',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "How would you like to rate this parking space?",
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                Dimens.space(3),

                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Rating options
                      ..._options.map((option) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedOption = option['enum'];
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: _selectedOption == option['enum']
                                  ? (option['color'] as Color).withOpacity(0.4)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: _selectedOption == option['enum']
                                    ? option['iconColor']
                                    : Colors.grey.withOpacity(0.4),
                              ),
                            ),
                            child: Column(
                              children: [
                                CircleAvatar(
                                  backgroundColor:
                                      (option['iconColor'] as Color)
                                          .withOpacity(0.1),
                                  child: Icon(option['icon'],
                                      color: option['iconColor']),
                                ),
                                const SizedBox(height: 5),
                                Text(option['label']),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),

                Dimens.space(4),

                // Submit Button
                PrimaryButton(
                  text: 'Done',
                  isLoading: state is ActivitiesLoading,
                  onTap: _submitted ? null : _handleSubmit,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class EventFeedback extends StatelessWidget {
  final Event event;
  final double currentDistance;
  final VoidCallback? onSubmit;

  const EventFeedback(
      {super.key,
      required this.event,
      this.onSubmit,
      required this.currentDistance});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(Dimens.defaultMargin + 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: [
                Image(
                  image: AssetImage(
                    MapAssetsProvider.getAssetEvent(event.type),
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
                          text: '${currentDistance.floor()}m away',
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
                Flexible(
                  child: PrimaryButton(
                    onTap: () {
                      NavigatorHelper.pop();
                    },
                    text: 'Got it, Thank you',
                  ),
                ),
                Dimens.space(1),
                Flexible(
                  child: PrimaryButton(
                    outline: true,
                    onTap: () {
                      AppPopup.showBottomSheet(
                        context,
                        FeedbackForm(eventID: event.id),
                      );
                    },
                    background: AppColors.primary50,
                    borderColor: Colors.transparent,
                    color: AppColors.primary500,
                    text: 'Feedback',
                  ),
                )
              ],
            ),
          ],
        ));
  }
}

class FeedbackForm extends StatelessWidget {
  final String eventID;
  const FeedbackForm({super.key, required this.eventID});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ActivitiesBloc, ActivitiesState>(
      listener: (context, state) {
        if (state is ActivitiesPublished) {
          // Show success message
          AppPopup.showDialogSheet(
            context,
            SuccessDialog(
              title: "Your feedback has been submitted",
              subtext: "Thank you for your input!",
              onProceed: () {
                NavigatorHelper.pop();
                NavigatorHelper.pop();
              },
            ),
          );
        }
        if (state is ActivitiesError) {
          // Show error message
          Toast.showError(
            state.error,
          );
        }
        // TODO: implement listener
      },
      builder: (context, state) {
        return MultiSelectPopup(
          title: "Event Feedback",
          isLoading: state is ActivitiesLoading,
          items: [
            MultiSelectItem(
              backgroundColor: AppColors.green50,
              icon: Icons.done,
              iconColor: AppColors.green500,
              text: "It’s still there",
              onTap: () {
                context.read<ActivitiesBloc>().add(
                      EventFeedBackEvent(
                        eventID: eventID,
                        isThere: true,
                      ),
                    );
              },
            ),
            Divider(color: AppColors.neutral50, height: 1),
            MultiSelectItem(
              backgroundColor: AppColors.secondary50,
              icon: Icons.close,
              iconColor: AppColors.secondary600,
              text: "It’s not there",
              onTap: () {
                context.read<ActivitiesBloc>().add(
                      EventFeedBackEvent(
                        eventID: eventID,
                        isThere: false,
                      ),
                    );
              },
            ),
          ],
        );
      },
    );
  }
}
