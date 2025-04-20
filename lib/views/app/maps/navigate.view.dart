import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:here_sdk/core.dart' as HERE;
import 'package:here_sdk/core.engine.dart';
import 'package:here_sdk/core.errors.dart';
import 'package:here_sdk/gestures.dart';
import 'package:here_sdk/location.dart' as HERE;
import 'package:here_sdk/mapview.dart';
import 'package:here_sdk/navigation.dart' as HERE;
import 'package:here_sdk/routing.dart' as HERE;
import 'package:letdem/constants/ui/colors.dart';
import 'package:letdem/constants/ui/dimens.dart';
import 'package:letdem/features/map/map_bloc.dart';
import 'package:letdem/global/popups/popup.dart';
import 'package:letdem/global/widgets/button.dart';
import 'package:letdem/models/auth/map/map_options.model.dart';
import 'package:letdem/models/auth/map/nearby_payload.model.dart';
import 'package:letdem/services/map/map_asset_provider.service.dart';
import 'package:letdem/services/res/navigator.dart';
import 'package:letdem/views/app/home/widgets/home/bottom_sheet/add_event_sheet.widget.dart';

class NavigationView extends StatefulWidget {
  final double destinationLat;
  final double destinationLng;

  const NavigationView({
    super.key,
    required this.destinationLat,
    required this.destinationLng,
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
  // Controllers and engines
  HereMapController? _hereMapController;
  late final AppLifecycleListener _lifecycleListener;
  HERE.RoutingEngine? _routingEngine;
  HERE.VisualNavigator? _visualNavigator;
  HERE.LocationSimulator? _locationSimulator;
  HERE.LocationEngine? _locationEngine;

  // Navigation state
  HERE.GeoCoordinates? _currentLocation;
  bool _isNavigating = false;
  bool _isLoading = false;
  String _navigationInstruction = "";
  int _distanceToNextManeuver = 0;
  int _totalRouteTime = 0;
  int _totalRouteDistance = 0;
  bool _isMuted = false;
  String _errorMessage = "";
  int _lastTriggerDistance = 0;
  double _lastLatitude = 0;
  double _lastLongitude = 0;
  int _distanceTraveled = 0;
  // Map of direction icons
  final Map<String, IconData> _directionIcons = {
    'turn right': Icons.turn_right,
    'turn left': Icons.turn_left,
    'go straight': Icons.arrow_upward,
    'make a u-turn': Icons.u_turn_left,
  };

  @override
  void initState() {
    super.initState();

    // Delay navigation start until map is created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestLocationPermission();
    });
  }

  putParkingsSpacesOnMao() {
    context.read<MapBloc>().add(
          GetNearbyPlaces(
            queryParams: MapQueryParams(
              currentPoint:
                  "${_currentLocation?.latitude},${_currentLocation?.longitude}",
              previousPoint:
                  "${_currentLocation?.latitude},${_currentLocation?.longitude}",
              radius: 1000,
              drivingMode: false,
              options: ['spaces'],
            ),
          ),
        );
  }

  @override
  void dispose() {
    _cleanupNavigation();
    _disposeHERESDK();
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

  bool _isPopupDisplayed = false;

  // Map initialization and cleanup
  void _onMapCreated(HereMapController hereMapController) {
    debugPrint('🗺️ Map created!');
    _hereMapController = hereMapController;

    // move gestures

    _hereMapController?.gestures.enableDefaultAction(
      GestureType.pinchRotate,
    );
    _loadMapScene();
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
            _errorMessage = "Failed to load map";
            _isLoading = false;
          });
          return;
        }

        debugPrint('✅ Map scene loaded.');
        MapMeasure mapMeasureZoom = MapMeasure(
            MapMeasureKind.distanceInMeters, _initialZoomDistanceInMeters);

        _hereMapController!.camera.lookAtPointWithMeasure(
            HERE.GeoCoordinates(52.520798, 13.409408), mapMeasureZoom);

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

    // Stop location simulator
    if (_locationSimulator != null) {
      _locationSimulator!.stop();
      _locationSimulator = null; // Explicitly clear reference
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
      _distanceToNextManeuver = 0;
      _totalRouteTime = 0;
      _totalRouteDistance = 0;
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
    _lifecycleListener.dispose();
    // HERE.SdkContext.release();
    debugPrint('✅ HERE SDK resources disposed.');
  }

  void _pauseNavigation() {
    if (_isNavigating) {
      _locationSimulator?.pause();
    }
  }

  void _resumeNavigation() {
    if (_isNavigating) {
      _locationSimulator?.resume();
    }
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
    debugPrint('Distance trigger: $_distanceTraveled meters traveled');
    context.read<MapBloc>().add(
          GetNearbyPlaces(
              queryParams: MapQueryParams(
            currentPoint: "$_lastLatitude,$_lastLongitude",
            previousPoint: "$_lastLatitude,$_lastLongitude",
            radius: 400,
            drivingMode: false,
            options: ['events'],
          )),
        );
  }

  final MapAssetsProvider _assetsProvider = MapAssetsProvider();

  String normalManuevers = "";

  void _addMapMarkers(List<Event> events, List<Space> spaces) {
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

        _hereMapController?.mapScene.addMapMarker(marker);
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
        _hereMapController?.mapScene.addMapMarker(marker);
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

    _routingEngine!.calculateCarRoute(
      [startWaypoint, destinationWaypoint],
      carOptions,
      (HERE.RoutingError? routingError, List<HERE.Route>? routeList) async {
        if (routingError == null && routeList != null && routeList.isNotEmpty) {
          HERE.Route calculatedRoute = routeList.first;

          _totalRouteTime = calculatedRoute.duration.inSeconds;
          _totalRouteDistance = calculatedRoute.lengthInMeters;

          debugPrint(
              '✅ Route calculated: ${_totalRouteDistance}m, ${_totalRouteTime ~/ 60} minutes');

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

  void _startGuidance(HERE.Route route) {
    if (_hereMapController == null) return;

    debugPrint('🧭 Starting visual guidance...');
    try {
      _visualNavigator = HERE.VisualNavigator();
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
      // Throttle updates to avoid too many setState calls
      final now = DateTime.now();

      HERE.SectionProgress lastSectionProgress =
          routeProgress.sectionProgress.last;
      int distance = lastSectionProgress.remainingDistanceInMeters;
      Duration trafficDelay = lastSectionProgress.trafficDelay;

      if (now.difference(lastUpdateTime).inMilliseconds < 500) {
        return;
      }
      String getStreetNameFromManeuver(HERE.Maneuver maneuver,
          {List<Locale> preferredLocales = const []}) {
        // Try next road name first (where the vehicle is heading)
        String? name = maneuver.nextRoadTexts.names.getDefaultValue();

        // Fallback to current road name if next is unavailable
        name ??= maneuver.roadTexts.names.getDefaultValue();

        return name ?? 'Unnamed Road';
      }

      // var sectionProgress = routeProgress.sectionProgress;
// Access the last SectionProgress in the list

// Retrieve the remaining distance and duration
      final remainingDistanceInMeters =
          lastSectionProgress.remainingDistanceInMeters;
      final remainingDurationInSeconds =
          lastSectionProgress.remainingDuration.inSeconds;

      setState(() {
        _distanceToNextManeuver = remainingDistanceInMeters;
      });

      // load spaces if 10 m away from destination

      if (remainingDistanceInMeters < 1) {
        if (!_isPopupDisplayed) {
          setState(() {
            _isPopupDisplayed = true;
          });

          putParkingsSpacesOnMao();

          AppPopup.showDialogSheet(context, ParkingRatingWidget());
        }
        return;
      }

      lastUpdateTime = now;

      final maneuver = routeProgress.maneuverProgress;
      if (maneuver.isEmpty) return;

      if (mounted) {
        setState(() {
          _distanceToNextManeuver = maneuver.first.remainingDistanceInMeters;
          _totalRouteDistance = distance;
          _totalRouteTime = remainingDurationInSeconds;
        });
      }
    });

    // Set up voice instruction listener
    _visualNavigator!.eventTextListener =
        HERE.EventTextListener((HERE.EventText eventText) {
      String? streetName = getStreetNameFromManeuver(
        eventText.maneuverNotificationDetails!.maneuver,
      );

      debugPrint("🗣️ Voice maneuver text: ${streetName}");
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

      // Create simulator options with realistic movement
      final options = HERE.LocationSimulatorOptions()
        ..speedFactor = 2.0; // Speed up a bit for testing

      // Create the location simulator with our route
      _locationSimulator = HERE.LocationSimulator.withRoute(route, options);

      // Add our custom location listener to track 50m intervals
      _locationSimulator!.listener =
          HERE.LocationListener((HERE.Location location) {
        final coordinates = location.coordinates;

        // Check distance trigger for 50m intervals
        _checkDistanceTrigger(coordinates.latitude, coordinates.longitude);

        // Forward to visual navigator's listener to update the 3D navigation view
        locationListener.onLocationUpdated(location);
      });

      // Set visual navigator to follow the route
      _visualNavigator!.startRendering(_hereMapController!);

      // Configure map view for 3D navigation
      _hereMapController!.camera.lookAtPoint(
        HERE.GeoCoordinates(
          widget.destinationLat,
          widget.destinationLng,
        ),
      );

      // Tilt camera for 3D effect
      _hereMapController!.camera.setOrientationAtTarget(
          HERE.GeoOrientationUpdate(0, 60) // 60-degree tilt for 3D view
          );

      // Start simulation
      _locationSimulator!.start();

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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${_distanceToNextManeuver > 0 ? _distanceToNextManeuver.toFormattedDistance() : _totalRouteDistance.toFormattedDistance()} ahead',
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
        Container(
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
                "${(_totalRouteTime.toFormattedTime())} (${_totalRouteDistance.toFormattedDistance()})",
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                semanticsLabel:
                    "Estimated arrival in ${_totalRouteTime.toFormattedTime()} with ${_totalRouteDistance} meters remaining",
              ),
            ],
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
    return const Center(
      child: Card(
        color: Colors.white,
        child: Padding(
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
      child: Card(
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

                // Loading indicator
                if (_isLoading) _buildLoadingIndicator(),

                // ParkingRatingWidget once done
                //
                // if (_totalRouteDistance < 3 &&
                //     _totalRouteTime < 1 &&
                //     _isNavigating)
                //   Positioned(
                //     bottom: 0,
                //     child: SizedBox(
                //       width: MediaQuery.of(context).size.width,
                //       child: const Positioned(
                //         bottom: 0,
                //         child: ParkingRatingWidget(),
                //       ),
                //     ),
                //   ),

                // Error message
                if (_errorMessage.isNotEmpty) _buildErrorMessage(),

                // Navigation instruction
                if (_isNavigating &&
                    _navigationInstruction.isNotEmpty &&
                    _totalRouteDistance > 0)
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

    return "${minutesStr} min".startsWith("00")
        ? "${secondsStr} sec"
        : "${minutesStr} min";
  }

//   format meters to km
  String toFormattedDistance() {
    if (this >= 1000) {
      return "${(this / 1000).toStringAsFixed(1)} km";
    } else {
      return "${this} m";
    }
  }
}

class ParkingRatingWidget extends StatefulWidget {
  const ParkingRatingWidget({Key? key}) : super(key: key);

  @override
  _ParkingRatingWidgetState createState() => _ParkingRatingWidgetState();
}

class _ParkingRatingWidgetState extends State<ParkingRatingWidget> {
  String? _selectedOption;
  bool _submitted = false;

  final List<Map<String, dynamic>> _options = [
    {
      'id': 'take',
      'label': "I'll take it",
      'icon': Icons.thumb_up,
      'color': Colors.green.shade100,
      'iconColor': Colors.green
    },
    {
      'id': 'inuse',
      'label': "It's in use",
      'icon': Icons.directions_car,
      'color': AppColors.primary500.withOpacity(0.1),
      'iconColor': AppColors.primary500
    },
    {
      'id': 'notuseful',
      'label': "Not useful",
      'icon': Icons.thumb_down,
      'color': Colors.amber.shade100,
      'iconColor': Colors.amber.shade700
    },
    {
      'id': 'prohibited',
      'label': "Prohibited",
      'icon': Icons.not_interested,
      'color': Colors.red.shade100,
      'iconColor': Colors.red
    },
  ];

  void _handleSubmit() {
    NavigatorHelper.pop();
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
    return Container(
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Location icon
            Container(
              padding: EdgeInsets.all(15),
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
                child: Icon(
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
                    "Available parking spaces are shown on the map. Select an option to navigate to the nearest one.",
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // const SizedBox(height: 32),

            // Options Grid

            // SingleChildScrollView(
            //   scrollDirection: Axis.horizontal,
            //   child: Row(
            //     spacing: Dimens.defaultMargin / 2,
            //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            //     children: _options.map((option) {
            //       return GestureDetector(
            //         onTap: () {
            //           setState(() {
            //             _selectedOption = option['id'];
            //           });
            //         },
            //         child: Container(
            //           padding: const EdgeInsets.all(10),
            //           decoration: BoxDecoration(
            //             color: _selectedOption == option['id']
            //                 ? Colors.transparent
            //                 : Colors.transparent,
            //             borderRadius: BorderRadius.circular(15),
            //             border: Border.all(
            //               color: _selectedOption == option['id']
            //                   ? AppColors.primary500
            //                   : Colors.grey.withOpacity(0.3),
            //               width: _selectedOption == option['id'] ? 2 : 1,
            //             ),
            //           ),
            //           child: Column(
            //             mainAxisSize: MainAxisSize.min,
            //             children: [
            //               Icon(
            //                 option['icon'],
            //                 color: _selectedOption == option['id']
            //                     ? option['iconColor']
            //                     : Colors.grey,
            //                 size: 32,
            //               ),
            //               const SizedBox(height: 8),
            //               Text(
            //                 option['label'],
            //                 style: TextStyle(
            //                   fontSize: 16,
            //                   color: Colors.black87,
            //                 ),
            //               ),
            //             ],
            //           ),
            //         ),
            //       );
            //     }).toList(),
            //   ),
            // ),
            Dimens.space(4),

            // Submit Button
            PrimaryButton(
              text: _submitted ? 'Submitted' : 'Go Back',
              isLoading: _submitted,
              onTap: _submitted ? null : _handleSubmit,
            ),
          ],
        ),
      ),
    );
  }
}
