import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:here_sdk/core.dart' as HERE;
import 'package:here_sdk/core.errors.dart';
import 'package:here_sdk/gestures.dart';
import 'package:here_sdk/location.dart' as HERE;
import 'package:here_sdk/mapview.dart';
import 'package:here_sdk/navigation.dart' as HERE;
import 'package:here_sdk/routing.dart' as HERE;
import 'package:iconly/iconly.dart';
import 'package:iconsax/iconsax.dart';
import 'package:letdem/common/popups/popup.dart';
import 'package:letdem/common/widgets/button.dart';
import 'package:letdem/common/widgets/chip.dart';
import 'package:letdem/core/constants/colors.dart';
import 'package:letdem/core/constants/dimens.dart';
import 'package:letdem/core/constants/typo.dart';
import 'package:letdem/core/enums/PublishSpaceType.dart';
import 'package:letdem/core/extensions/locale.dart';
import 'package:letdem/core/extensions/time.dart';
import 'package:letdem/core/extensions/user.dart';
import 'package:letdem/features/activities/presentation/bottom_sheets/add_event_sheet.widget.dart';
import 'package:letdem/features/auth/models/map_options.model.dart';
import 'package:letdem/features/auth/models/nearby_payload.model.dart';
import 'package:letdem/features/map/map_bloc.dart';
import 'package:letdem/features/map/presentation/views/route.view.dart';
import 'package:letdem/features/map/presentation/widgets/navigation/event_feedback.widget.dart';
import 'package:letdem/features/map/presentation/widgets/navigation/space_feedback.widget.dart';
import 'package:letdem/infrastructure/services/map/map_asset_provider.service.dart';
import 'package:letdem/infrastructure/services/res/navigator.dart';
import 'package:letdem/infrastructure/toast/toast/tone.dart';
import 'package:letdem/infrastructure/tts/tts/tts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

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
  static const double _initialZoomDistanceInMeters = 8000;
  static const double _mapPadding = 20;
  static const double _buttonRadius = 26;
  static const double _containerPadding = 15;
  static const double _borderRadius = 20;
  static const int _distanceTriggerThreshold = 200;

  DateTime? _navigationStartTime;
  bool _hasShownFatigueAlert = false;

  HereMapController? _hereMapController;
  late final AppLifecycleListener _lifecycleListener;
  HERE.RoutingEngine? _routingEngine;
  HERE.VisualNavigator? _visualNavigator;
  HERE.LocationEngine? _locationEngine;

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

  bool _hasShownArrivalNotification = false;
  bool _hasShownParkingRating = false;
  HERE.SpeedLimit? _currentSpeedLimit;
  bool _isOverSpeedLimit = false;
  bool _isPopupDisplayed = false;
  bool _isUserPanning = false;
  bool _isCameraLocked = true;
  bool _isRecalculatingRoute = false;

  late double _actualDestinationLat;
  late double _actualDestinationLng;

  String _lastSpokenInstruction = "";
  final ValueNotifier<int> _distanceNotifier = ValueNotifier<int>(0);
  int _nextManuoverDistance = 0;
  Timer? _rerouteDebounceTimer;
  int _lastRerouteTime = 0;
  String normalManuevers = "";

  int DISTANCE_THREESHOLD = 10;

  final Map<String, IconData> _directionIcons = {
    'turn right': Icons.turn_right,
    'turn left': Icons.turn_left,
    'go straight': Icons.arrow_upward,
    'make a u-turn': Icons.u_turn_left,
  };

  final MapAssetsProvider _assetsProvider = MapAssetsProvider();
  final Map<MapMarker, Space> _spaceMarkers = {};
  final Map<MapMarker, Event> _eventMarkers = {};

  bool _isShownRegularDestinationAlert = false;
  final speech = SpeechService();

  @override
  void initState() {
    print("IS navigating to parking: ${widget.isNavigatingToParking}");
    print("Parking space ID: ${widget.parkingSpaceID}");
    WakelockPlus.enable();

    super.initState();

    _actualDestinationLat = widget.destinationLat;
    _actualDestinationLng = widget.destinationLng;

    // _lifecycleListener = AppLifecycleListener(
    //   onDetach: _cleanupNavigation,
    //   onHide: _cleanupNavigation,
    //   onPause: _cleanupNavigation,
    //   onRestart: _startNavigation,
    // );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestLocationPermission();
    });
  }

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

        if (_speed > 0 && _currentSpeedLimit != null) {
          final buffer =
              _currentSpeedLimit!.speedLimitInMetersPerSecond! * 0.05;
          _isOverSpeedLimit = _speed >
              (_currentSpeedLimit!.speedLimitInMetersPerSecond! + buffer);

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
            Container(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 13),
              decoration: BoxDecoration(
                // CHANGE: Use red background when overspeeding, orange when normal
                color: _isOverSpeedLimit
                    ? Colors.redAccent
                        .withOpacity(0.2) // Red background when overspeeding
                    : Colors.orange.shade50, // Normal orange background
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    (_speed * 3.6).round().toString(),
                    style: TextStyle(
                      // CHANGE: Use red text when overspeeding, orange when normal
                      color: _isOverSpeedLimit
                          ? Colors.redAccent
                              .withOpacity(0.8) // Red text when overspeeding
                          : Colors.orange.shade700, // Normal orange text
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                  Text(
                    context.l10n.kmPerHour,
                    style: TextStyle(
                      color: _isOverSpeedLimit
                          ? Colors.redAccent
                              .withOpacity(0.8) // Red text when overspeeding
                          : Colors.orange.shade700, // Normal orange text
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                // CHANGE: Make speed limit sign border red when overspeeding
                border: Border.all(
                  color: _isOverSpeedLimit ? Colors.red : Colors.red,
                  width: _isOverSpeedLimit
                      ? 3
                      : 2, // Thicker border when overspeeding
                ),
              ),
              child: Center(
                child: _currentSpeedLimit != null &&
                        _currentSpeedLimit!.speedLimitInMetersPerSecond != null
                    ? Text(
                        "${(_currentSpeedLimit!.speedLimitInMetersPerSecond! * 3.6).round()}",
                        style: TextStyle(
                          // CHANGE: Make speed limit text red when overspeeding
                          color: _isOverSpeedLimit ? Colors.red : Colors.black,
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

  bool isSpeedLimitCooldownActive = false;

  void _showSpeedLimitAlert() {
    if (isSpeedLimitCooldownActive) return;

    isSpeedLimitCooldownActive = true;

    if (_currentSpeedLimit == null || context.isSpeedAlertEnabled) return;

    final speedLimitKmh =
        (_currentSpeedLimit!.speedLimitInMetersPerSecond! * 3.6).round();

    AlertHelper.showWarning(
      context: context,
      title: context.l10n.speedLimitAlert,
      subtext: context.l10n.speedLimitWarning,
    );

    Timer.periodic(const Duration(seconds: 3), (timer) {
      isSpeedLimitCooldownActive = false;
      timer.cancel();
    });

    if (!_isMuted) {
      speech.speak(context.l10n.speedLimitVoiceAlert(speedLimitKmh.toString()));
    }
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
    debugPrint('🗑️ Disposing NavigationView...');

    // Cleanup navigation first
    _cleanupNavigation();

    // Cancel timers
    _rerouteDebounceTimer?.cancel();

    // Dispose notifiers
    _distanceNotifier.dispose();

    // Dispose lifecycle listener
    // _lifecycleListener.dispose();

    // Disable wakelock
    WakelockPlus.disable();

    debugPrint('✅ NavigationView disposed');
    super.dispose();
  }

  Future<void> _requestLocationPermission() async {
    setState(() => _isLoading = true);
    await _assetsProvider.loadAssets();

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _errorMessage = context.l10n.locationPermissionDenied;
          _isLoading = false;
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _errorMessage = context.l10n.locationPermissionDeniedPermanently;
        _isLoading = false;
      });
      return;
    }

    setState(() => _isLoading = false);
  }

  void _onMapCreated(HereMapController hereMapController) {
    debugPrint('🗺️ Map created!');
    _hereMapController = hereMapController;

    _hereMapController?.gestures.enableDefaultAction(GestureType.pan);
    _hereMapController?.gestures.enableDefaultAction(GestureType.pinchRotate);
    _hereMapController?.gestures.enableDefaultAction(GestureType.twoFingerPan);
    _hereMapController?.gestures.enableDefaultAction(GestureType.pinchRotate);

    _hereMapController?.mapScene.enableFeatures({
      MapFeatures.buildingFootprints: MapFeatureModes.buildingFootprintsAll
    });
    _hereMapController?.mapScene.enableFeatures(
        {MapFeatures.trafficFlow: MapFeatureModes.trafficFlowWithFreeFlow});

    _hereMapController?.mapScene.enableFeatures(
        {MapFeatures.trafficIncidents: MapFeatureModes.trafficIncidentsAll});

    // Additional traffic-related features
    _hereMapController?.mapScene.enableFeatures(
        {MapFeatures.roadExitLabels: MapFeatureModes.roadExitLabelsAll});

    _hereMapController?.mapScene.enableFeatures({
      MapFeatures.vehicleRestrictions:
          MapFeatureModes.vehicleRestrictionsActiveAndInactive
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
        {MapFeatures.trafficFlow: MapFeatureModes.trafficIncidentsAll});
    _hereMapController?.mapScene.enableFeatures(
        {MapFeatures.lowSpeedZones: MapFeatureModes.lowSpeedZonesAll});
    _hereMapController?.mapScene.enableFeatures(
        {MapFeatures.ambientOcclusion: MapFeatureModes.ambientOcclusionAll});
    _hereMapController?.mapScene.enableFeatures({
      MapFeatures.vehicleRestrictions:
          MapFeatureModes.vehicleRestrictionsActiveAndInactive
    });
    _hereMapController?.mapScene
        .enableFeatures({MapFeatures.contours: MapFeatureModes.contoursAll});
    _hereMapController?.gestures.tapListener =
        TapListener((HERE.Point2D touchPoint) {
      _pickMapMarker(touchPoint);
    });
    _hereMapController?.gestures.panListener = PanListener((GestureState state,
        HERE.Point2D point1, HERE.Point2D point2, double distanceInPixels) {
      if (state == GestureState.begin) {
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
      _visualNavigator!.cameraBehavior = HERE.FixedCameraBehavior();
      debugPrint('🔒 Camera tracking re-enabled');
    } else {
      _visualNavigator!.cameraBehavior = null;
      debugPrint('🔓 Camera tracking disabled');
    }
  }

  void _loadMapScene() {
    if (_hereMapController == null) return;

    setState(() => _isLoading = true);

    _hereMapController!.mapScene.loadSceneForMapScheme(
      MapScheme.normalDay,
      (error) {
        if (error != null) {
          debugPrint('❌ Map scene not loaded. MapError: ${error.toString()}');
          setState(() {
            _errorMessage = context.l10n.failedToLoadMap;
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
    debugPrint('🧹 Starting comprehensive navigation cleanup...');

    // Stop and cleanup VisualNavigator
    if (_visualNavigator != null) {
      try {
        _visualNavigator!.stopRendering();
        _visualNavigator!.routeProgressListener = null;
        _visualNavigator!.speedLimitListener = null;
        _visualNavigator!.routeDeviationListener = null;
        _visualNavigator!.eventTextListener = null;
        _visualNavigator!.cameraBehavior = null;
        _visualNavigator!.route = null;
        debugPrint('✅ VisualNavigator cleaned up');
      } catch (e) {
        debugPrint('⚠️ Error cleaning up VisualNavigator: $e');
      }
      _visualNavigator = null;
    }

    // Stop and cleanup LocationEngine
    if (_locationEngine != null) {
      try {
        _locationEngine!.stop();
        // Clear all location listeners
        _locationEngine = null;
        debugPrint('✅ LocationEngine stopped and cleaned up');
      } catch (e) {
        debugPrint('⚠️ Error stopping LocationEngine: $e');
      }
    }

    // NEW: Clean up map scene and remove all markers/indicators
    if (_hereMapController != null) {
      try {
        // NEW: Reset camera behavior to default
        _hereMapController!.camera
            .setOrientationAtTarget(HERE.GeoOrientationUpdate(0, 0));

        debugPrint(
            '✅ Map scene cleaned up - removed markers, polylines, and reset camera');
      } catch (e) {
        debugPrint('⚠️ Error cleaning up map scene: $e');
      }
    }

    // Cleanup RoutingEngine
    if (_routingEngine != null) {
      _routingEngine = null;
      debugPrint('✅ RoutingEngine cleaned up');
    }

    // Reset state variables
    if (mounted) {
      setState(() {
        _isNavigating = false;
        _isLoading = false;
        _navigationInstruction = "";
        _currentSpeedLimit = null;
        _isOverSpeedLimit = false;
        _hasShownArrivalNotification = false;
        _hasShownParkingRating = false;
        _isPopupDisplayed = false;
        _isRecalculatingRoute = false;
        _isCameraLocked = true;
        _isUserPanning = false;
        _speed = 0;
        _totalRouteTime = 0;
        _nextManuoverDistance = 0;
        normalManuevers = "";
        _lastSpokenInstruction = "";
        _currentLocation = null; // NEW: Reset current location
      });
    }

    debugPrint('🧹 Navigation cleanup completed');
  }

  Future<bool> _handleBackPress() async {
    debugPrint('🔙 Back button pressed.');
    _cleanupNavigation();
    return true;
  }

  void _initLocationEngine() {
    debugPrint('🛰️ Initializing Location Engine...');
    try {
      _locationEngine = HERE.LocationEngine();
      debugPrint('✅ Location Engine initialized.');
    } on InstantiationException {
      debugPrint('❌ Initialization of LocationEngine failed.');
      setState(() {
        _errorMessage = context.l10n.failedToInitializeLocation;
        _isLoading = false;
      });
    }
  }

  void _startNavigation() async {
    _cleanupNavigation();

    await Future.delayed(const Duration(milliseconds: 200));

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
    final distanceBetweenPoints = Geolocator.distanceBetween(
      _lastLatitude,
      _lastLongitude,
      latitude,
      longitude,
    ).toInt();

    if (distanceBetweenPoints > 0) {
      _distanceTraveled += distanceBetweenPoints;

      _lastLatitude = latitude;
      _lastLongitude = longitude;

      if (_distanceTraveled - _lastTriggerDistance >=
          _distanceTriggerThreshold) {
        _lastTriggerDistance =
            (_distanceTraveled ~/ _distanceTriggerThreshold) *
                _distanceTriggerThreshold;

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
                                getSpaceAvailabilityMessage(
                                    space.type, context),
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
                  text: context.l10n.navigateToSpaceButton,
                  onTap: () {
                    Navigator.pop(context);

                    setState(() {
                      _currentSpace = space;
                      _actualDestinationLat = space.location.point.lat;
                      _actualDestinationLng = space.location.point.lng;
                      _hasShownArrivalNotification = false;
                      _hasShownParkingRating = false;
                      _isPopupDisplayed = false;
                      _isLoading = true;
                    });

                    // FIX: Don't call _stopNavigation() and _cleanupNavigation() together
                    // Just update the route instead of full cleanup
                    _switchToNewDestination(space);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

// Fix 2: Add new method to switch destinations without full cleanup
  void _switchToNewDestination(Space space) {
    debugPrint('🔄 Switching to new destination: ${space.location.streetName}');

    if (_currentLocation != null) {
      // Update destination coordinates
      _actualDestinationLat = space.location.point.lat;
      _actualDestinationLng = space.location.point.lng;

      // Recalculate route to new destination
      _calculateRoute(
          _currentLocation!,
          HERE.GeoCoordinates(
              space.location.point.lat, space.location.point.lng));

      _showToast(
        context.l10n.navigatingToParking,
        backgroundColor: AppColors.primary500,
      );
    } else {
      debugPrint('❌ Current location is null, cannot switch destination');
      setState(() {
        _isLoading = false;
        _errorMessage = "Unable to get current location";
      });
    }
  }

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
    print('📍 Start: ${start.latitude}, ${start.longitude}');
    print('🎯 Destination: ${destination.latitude}, ${destination.longitude}');

    // Don't reinitialize routing engine if it already exists
    if (_routingEngine == null) {
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
    }

    HERE.Waypoint startWaypoint = HERE.Waypoint(start);
    HERE.Waypoint destinationWaypoint = HERE.Waypoint(destination);

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
          _distanceNotifier.value = calculatedRoute.lengthInMeters;

          setState(() {
            _isNavigating = true;
            _isLoading = false;
          });

          // If we already have a visual navigator, just update the route
          if (_visualNavigator != null) {
            _visualNavigator!.route = calculatedRoute;
            debugPrint('✅ Updated existing navigation route');
          } else {
            _startGuidance(calculatedRoute);
          }

          // Set initial position after route update
          Future.delayed(const Duration(milliseconds: 500), () {
            _setInitialNavigationPosition();
          });
        } else {
          final error = routingError?.toString() ?? "Unknown error";
          debugPrint('❌ Error while calculating route: $error');
          setState(() {
            _errorMessage = context.l10n.navigationError;
            _isLoading = false;
          });
        }
      },
    );
  }

  void _setInitialNavigationPosition() {
    if (_currentLocation != null && _visualNavigator != null) {
      // Create a simulated location update to kickstart navigation
      final initialLocation = HERE.Location.withCoordinates(
        _currentLocation!,
      );

      // Send initial location to visual navigator
      _visualNavigator!.onLocationUpdated(initialLocation);

      debugPrint(
          '📍 Set initial navigation position: ${_currentLocation!.latitude}, ${_currentLocation!.longitude}');
    }
  }

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
        _errorMessage = context.l10n.failedToInitNavigation;
        _isNavigating = false;
      });
      return;
    }

    _visualNavigator!.startRendering(_hereMapController!);
    debugPrint('📡 Started rendering navigator.');

    DateTime lastUpdateTime = DateTime.now();

    _visualNavigator!.routeProgressListener =
        HERE.RouteProgressListener((HERE.RouteProgress routeProgress) {
      final now = DateTime.now();
      HERE.SectionProgress lastSectionProgress =
          routeProgress.sectionProgress.last;
      int remainingDistance = lastSectionProgress.remainingDistanceInMeters;

      print('🟡 Route progress update at ${now.toIso8601String()}');
      print('➡️ Remaining distance in section: $remainingDistance meters');

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
      final remainingDurationInSeconds =
          lastSectionProgress.remainingDuration.inSeconds;
      _distanceNotifier.value = remainingDistance;

      bool isAtDestination = remainingDistance <= DISTANCE_THREESHOLD;
      bool isParkingNavigation =
          _currentSpace != null || widget.isNavigatingToParking;

      print('🎯 Distance to destination: $remainingDistance meters');
      print('🅿️ Is parking navigation: $isParkingNavigation');
      print('🔔 Has shown arrival: $_hasShownArrivalNotification');
      print('⭐ Has shown rating: $_hasShownParkingRating');

      if (isAtDestination && !_hasShownArrivalNotification) {
        print('✅ Arrived at destination!');

        if (!isParkingNavigation) {
          AppPopup.showDialogSheet(
            context,
            ArrivalNotificationWidget(
              onClose: () {
                NavigatorHelper.pop();
              },
            ),
          );
        }

        setState(() {
          _hasShownArrivalNotification = true;
        });

        if (isParkingNavigation &&
            !_hasShownParkingRating &&
            !_isPopupDisplayed) {
          setState(() {
            _hasShownParkingRating = true;
            _isPopupDisplayed = true;
          });

          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              AppPopup.showBottomSheet(
                  context,
                  ParkingRatingWidget(
                    spaceID: _currentSpace!.id,
                    onSubmit: () {
                      NavigatorHelper.pop();
                      _isPopupDisplayed = false;
                      _hasShownParkingRating = false;
                    },
                  ));
            }
          });
        } else if (!isParkingNavigation) {
          print('🎯 Standard destination reached. Showing toast.');
          _showToast(context.l10n.arrivedAtDestination,
              backgroundColor: AppColors.green600);

          putParkingSpacesOnMap();
        }
      }

      lastUpdateTime = now;

      final maneuver = routeProgress.maneuverProgress;
      if (maneuver.isEmpty) {
        print('⚠️ No maneuvers found in route progress.');
        return;
      }

      if (mounted) {
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
              title: context.l10n.fatigueAlertTitle,
              subtext: context.l10n.fatigueAlertMessage,
            );

            if (!_isMuted) {
              speech.speak(context.l10n.fatigueAlertVoice);
            }
          }
        }
      }
    });

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

    _visualNavigator!.route = route;
    _setupLocationSource(_visualNavigator!, route);
  }

  void _setupRouteDeviationListener() {
    _visualNavigator!.routeDeviationListener =
        HERE.RouteDeviationListener((HERE.RouteDeviation routeDeviation) {
      debugPrint('🛰️ Route deviation listener triggered');

      if (_isRecalculatingRoute) {
        debugPrint('⏳ Already recalculating route. Skipping...');
        return;
      }

      HERE.Route? route = _visualNavigator?.route;
      if (route == null) {
        debugPrint(
            '❌ No active route found. Skipping route deviation handling.');
        return;
      }

      HERE.GeoCoordinates currentGeoCoordinates =
          routeDeviation.currentLocation.originalLocation.coordinates;
      debugPrint(
          '📍 Current location: (${currentGeoCoordinates.latitude}, ${currentGeoCoordinates.longitude})');

      double distanceInMeters = Geolocator.distanceBetween(
        _currentLocation!.latitude,
        _currentLocation!.longitude,
        currentGeoCoordinates.latitude,
        currentGeoCoordinates.longitude,
      );
      debugPrint('📏 Calculated deviation: $distanceInMeters meters');

      final now = DateTime.now().millisecondsSinceEpoch;

      debugPrint('⏰ Time since last reroute: ${now - _lastRerouteTime} ms');

      bool isSignificantlyOffRoute = true;
      bool isFarEnoughFromDestination = _distanceNotifier.value > 50;
      bool isTimeElapsedSinceLastReroute = (now - _lastRerouteTime > 5000);

      if (isSignificantlyOffRoute &&
          isFarEnoughFromDestination &&
          isTimeElapsedSinceLastReroute) {
        debugPrint(
            '⚠️ Significant deviation detected! Off by ${distanceInMeters}m');
        debugPrint('📡 Initiating reroute sequence...');

        _rerouteDebounceTimer?.cancel();

        _isRecalculatingRoute = true;
        _lastRerouteTime = now;

        _showToast(
          context.l10n.recalculatingRoute,
          backgroundColor: AppColors.red500,
        );

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

  void _recalculateRouteFromCurrentLocation(
      HERE.GeoCoordinates currentPosition) {
    if (_currentLocation == null) return;

    try {
      debugPrint('🧭 Recalculating route from current position...');

      HERE.Waypoint startWaypoint = HERE.Waypoint(currentPosition);

      HERE.Waypoint destinationWaypoint = HERE.Waypoint(
          HERE.GeoCoordinates(_actualDestinationLat, _actualDestinationLng));

      final carOptions = HERE.CarOptions();
      carOptions.routeOptions.enableTolls = true;
      carOptions.routeOptions.optimizationMode = HERE.OptimizationMode.fastest;

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
            _distanceNotifier.value = calculatedRoute.lengthInMeters;

            if (_visualNavigator != null && mounted) {
              _visualNavigator!.route = calculatedRoute;

              setState(() {
                _isNavigating = true;
                _isRecalculatingRoute = false;
              });
            }
          } else {
            final error = routingError?.toString() ?? "Unknown error";
            debugPrint('❌ Error while recalculating route: $error');

            setState(() {
              _isRecalculatingRoute = false;
            });

            _showToast(
              context.l10n.couldNotRecalculateRoute,
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
    String? name = maneuver.nextRoadTexts.names.getDefaultValue();

    name ??= maneuver.roadTexts.names.getDefaultValue();

    return name ?? context.l10n.unnamedRoad;
  }

  void _setupLocationSource(
      HERE.LocationListener locationListener, HERE.Route route) {
    debugPrint('📍 Setting up navigation with visual map...');
    try {
      _visualNavigator!.route = route;
      _locationEngine = HERE.LocationEngine();

      _locationEngine!.addLocationListener(
        HERE.LocationListener((HERE.Location location) {
          _currentLocation = location.coordinates;
          double? speed = location.speedInMetersPerSecond;

          setState(() {
            _speed = speed ?? 0;
          });

          if (_lastLatitude == 0 && _lastLongitude == 0) {
            _lastLatitude = location.coordinates.latitude;
            _lastLongitude = location.coordinates.longitude;
          }

          _checkDistanceTrigger(
            location.coordinates.latitude,
            location.coordinates.longitude,
          );
          locationListener.onLocationUpdated(location);
        }),
      );
      _locationEngine?.startWithLocationAccuracy(
        HERE.LocationAccuracy.navigation,
      );

      _visualNavigator!.startRendering(_hereMapController!);
      _setupSpeedLimitListener();

      _hereMapController!.camera
          .setOrientationAtTarget(HERE.GeoOrientationUpdate(0, 65));

      debugPrint('✅ Navigation with 3D view started successfully');
    } catch (e) {
      debugPrint('❌ Failed to set up location simulation: $e');
      setState(() {
        _errorMessage = context.l10n.failedToStartNavigation;
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

  void _showToast(String message, {Color backgroundColor = Colors.black}) {}

  Widget _buildNavigationInstructionCard() {
    IconData directionIcon = Icons.navigation;

    for (final entry in _directionIcons.entries) {
      if (normalManuevers.toLowerCase().contains(entry.key)) {
        directionIcon = entry.value;
        break;
      }
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: _isNavigating &&
              _navigationInstruction.isNotEmpty &&
              _distanceNotifier.value > 0
          ? 90
          : 70,
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
      child: _isNavigating &&
              _navigationInstruction.isNotEmpty &&
              _distanceNotifier.value > 0
          ? Row(
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
                    return Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${_nextManuoverDistance.toFormattedDistance()} ${context.l10n.ahead}',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16),
                          ),
                          Text(
                            _navigationInstruction,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 15),
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

                        if (_visualNavigator != null) {
                          debugPrint(
                              '🔊 Voice ${_isMuted ? 'muted' : 'unmuted'}');
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
            )
          : Center(
              child: Shimmer.fromColors(
                baseColor: Colors.white.withOpacity(0.5),
                highlightColor: Colors.grey[100]!,
                child: Text(
                  context.l10n.waitingForNavigation,
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.7), fontSize: 16),
                ),
              ),
            ),
    );
  }

  Widget _buildNavigationControls() {
    return Row(
      children: [
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
        CircleAvatar(
          radius: _buttonRadius,
          backgroundColor: AppColors.red500,
          child: IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            tooltip: context.l10n.addEvent,
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(context.l10n.preparingNavigation),
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
                child: Text(context.l10n.tryAgain),
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
          _addMapMarkers(state.payload.events, state.payload.spaces);

          if (state.payload.alerts.isNotEmpty) {
            for (var alert in state.payload.alerts) {
              AlertHelper.showWarning(
                context: context,
                title: alert.type.toLowerCase() == "camera"
                    ? context.l10n.cameraAlertTitle
                    : context.l10n.radarAlertTitle,
                subtext: alert.type.toLowerCase() == "camera"
                    ? context.l10n.cameraAlertMessage
                    : context.l10n.radarAlertMessage,
              );
            }
          }
        }
      },
      builder: (context, state) {
        return WillPopScope(
          onWillPop: _handleBackPress,
          child: Scaffold(
            body: Stack(
              children: [
                HereMap(onMapCreated: _onMapCreated),
                _buildSpeedLimitIndicator(),
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
                      tooltip: _isCameraLocked
                          ? context.l10n.freeCameraMode
                          : context.l10n.lockPositionMode,
                    ),
                  ),
                ),
                if (_errorMessage.isNotEmpty) _buildErrorMessage(),
                Positioned(
                  top: MediaQuery.of(context).padding.top + 10,
                  left: _mapPadding,
                  right: _mapPadding,
                  child: _buildNavigationInstructionCard(),
                ),
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

class Debouncer {
  final Duration delay;
  Timer? _timer;

  Debouncer({required this.delay});

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }
}

class ArrivalNotificationWidget extends StatelessWidget {
  final VoidCallback? onClose;

  const ArrivalNotificationWidget({super.key, this.onClose});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        CircleAvatar(
          radius: 45,
          backgroundColor: AppColors.green50,
          child: Icon(
            Iconsax.location5,
            size: 45,
            color: AppColors.green600,
          ),
        ),
        Dimens.space(3),
        Text(
          context.l10n.arrivalTitle,
          textAlign: TextAlign.center,
          style: Typo.heading4.copyWith(color: AppColors.neutral600),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            context.l10n.arrivalSubtitle,
            textAlign: TextAlign.center,
            style: Typo.mediumBody.copyWith(color: AppColors.neutral400),
          ),
        ),
        Dimens.space(5),
        PrimaryButton(
          onTap: () {
            if (onClose != null) {
              onClose!();
            } else {
              Navigator.pop(context);
            }
          },
          text: context.l10n.proceed,
        ),
      ],
    );
  }
}
