import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:here_sdk/core.dart' as HERE;
import 'package:here_sdk/core.engine.dart';
import 'package:here_sdk/core.errors.dart';
import 'package:here_sdk/location.dart' as HERE;
import 'package:here_sdk/mapview.dart';
import 'package:here_sdk/navigation.dart' as HERE;
import 'package:here_sdk/routing.dart' as HERE;
import 'package:letdem/common/popups/popup.dart';
import 'package:letdem/constants/ui/colors.dart';
import 'package:letdem/constants/ui/dimens.dart';
import 'package:letdem/infrastructure/toast/toast/toast.dart';
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
  static const double _initialZoomDistanceInMeters =
      500; // Lowered to get closer view
  static const double _mapPadding = 20;
  static const double _buttonRadius = 26;
  static const double _containerPadding = 15;
  static const double _borderRadius = 20;
  static const int _distanceTriggerThreshold =
      50; // 50m threshold for triggering

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

  // Distance tracking
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
    _lifecycleListener = AppLifecycleListener(
      onDetach: _disposeHERESDK,
      onPause: _pauseNavigation,
      onResume: _resumeNavigation,
    );

    // Delay navigation start until map is created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestLocationPermission();
    });
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

  // Map initialization and cleanup
  void _onMapCreated(HereMapController hereMapController) {
    debugPrint('🗺️ Map created!');
    _hereMapController = hereMapController;
    _loadMapScene();
  }

  void _loadMapScene() {
    if (_hereMapController == null) return;

    setState(() => _isLoading = true);

    _hereMapController!.mapScene.loadSceneForMapScheme(
      MapScheme.normalDay,
      (MapError? error) {
        if (error != null) {
          debugPrint('❌ Map scene not loaded. MapError: ${error.toString()}');
          setState(() {
            _errorMessage = "Failed to load map";
            _isLoading = false;
          });
          return;
        }

        debugPrint('✅ Map scene loaded.');

        // Enable camera tracking of position indicator

        MapMeasure mapMeasureZoom = MapMeasure(
            MapMeasureKind.distanceInMeters, _initialZoomDistanceInMeters);

        _startNavigation();
      },
    );
  }

  void _cleanupNavigation() {
    debugPrint('🧹 Cleaning up navigation resources...');
    _visualNavigator?.stopRendering();
    _locationSimulator?.stop();
    _locationEngine?.stop();
  }

  Future<bool> _handleBackPress() async {
    debugPrint('🔙 Back button pressed.');
    _cleanupNavigation();
    return true;
  }

  void _disposeHERESDK() {
    debugPrint('🧼 Disposing HERE SDK resources...');
    _cleanupNavigation();
    SDKNativeEngine.sharedInstance?.dispose();
    HERE.SdkContext.release();
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

      // Initialize last known coordinates for distance tracking
      _lastLatitude = currentLocationGeo.latitude;
      _lastLongitude = currentLocationGeo.longitude;

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

  // Track distance changes and trigger events every 50m
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
    Toast.show(
      "You have traveled $_distanceTraveled meters",
    );

    debugPrint('🚶 Distance trigger: $_distanceTraveled meters traveled');
  }

  // Set up simulated or real location source
  void _setupLocationSource(
      HERE.LocationListener locationListener, HERE.Route route) {
    debugPrint('🚀 Setting up location simulation for navigation...');

    try {
      // Create a location simulator for navigation testing
      _locationSimulator = HERE.LocationSimulator.withRoute(
          route, HERE.LocationSimulatorOptions());

      // Add location listener to get position updates
      _locationSimulator!.listener =
          HERE.LocationListener((HERE.Location location) {
        // Update current location
        if (mounted) {
          final coordinates = location.coordinates;

          // Check distance trigger
          _checkDistanceTrigger(coordinates.latitude, coordinates.longitude);

          // Move camera to follow
          if (_hereMapController != null) {
            MapMeasure mapMeasure =
                MapMeasure(MapMeasureKind.distanceInMeters, 100);
            _hereMapController!.camera.lookAtPoint(coordinates);
          }
        }
      });

      // Start the simulation
      _locationSimulator!.start();

      // Set route for visual navigator
      _visualNavigator!.route = route;

      debugPrint('✅ Location simulator started successfully.');
    } catch (e) {
      debugPrint('❌ Failed to set up location simulation: $e');
      setState(() {
        _errorMessage = "Failed to start navigation simulation";
        _isLoading = false;
      });
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
      if (now.difference(lastUpdateTime).inMilliseconds < 500) {
        return;
      }
      lastUpdateTime = now;

      final maneuver = routeProgress.maneuverProgress;
      if (maneuver.isEmpty) return;

      debugPrint(
          '🗺️ Maneuver progress: ${maneuver.first.remainingDistanceInMeters}m');

      if (mounted) {
        setState(() {
          _distanceToNextManeuver = maneuver.first.remainingDistanceInMeters;
          _totalRouteDistance =
              routeProgress.maneuverProgress.first.remainingDistanceInMeters;
          _totalRouteTime =
              routeProgress.maneuverProgress.first.remainingDuration.inSeconds;
        });
      }
    });

    // Set up voice instruction listener
    _visualNavigator!.eventTextListener =
        HERE.EventTextListener((HERE.EventText eventText) {
      debugPrint("🗣️ Voice maneuver text: ${eventText.text}");
      if (mounted) {
        setState(() {
          _navigationInstruction = eventText.text;
        });
      }
    });

    // Set route and start location simulation
    _setupLocationSource(_visualNavigator!, route);
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
      if (_navigationInstruction.toLowerCase().contains(entry.key)) {
        directionIcon = entry.value;
        break;
      }
    }

    return Container(
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
              children: [
                Text(
                  '${_distanceToNextManeuver > 0 ? _distanceToNextManeuver : _totalRouteDistance}m ahead',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                ),
                Text(
                  _navigationInstruction,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
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
                "${(_totalRouteTime.toFormattedTime())} ($_totalRouteDistance m)",
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                semanticsLabel:
                    "Estimated arrival in ${_totalRouteTime.toFormattedTime()} with $_totalRouteDistance meters remaining",
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

  Widget _buildDistanceTraveled() {
    return Positioned(
      top: MediaQuery.of(context).padding.top +
          (_navigationInstruction.isNotEmpty ? 100 : 10),
      left: _mapPadding,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          "Distance traveled: $_distanceTraveled m",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
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
    return WillPopScope(
      onWillPop: _handleBackPress,
      child: Scaffold(
        body: Stack(
          children: [
            // Map layer
            HereMap(onMapCreated: _onMapCreated),

            // Loading indicator
            if (_isLoading) _buildLoadingIndicator(),

            // Error message
            if (_errorMessage.isNotEmpty) _buildErrorMessage(),

            // Navigation instruction
            if (_isNavigating && _navigationInstruction.isNotEmpty)
              Positioned(
                top: MediaQuery.of(context).padding.top + 10,
                left: _mapPadding,
                right: _mapPadding,
                child: _buildNavigationInstructionCard(),
              ),

            // Distance traveled indicator
            if (_isNavigating) _buildDistanceTraveled(),

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
  }
}

// Extension to parse seconds to minutes and seconds
extension TimeFormatter on int {
  String toFormattedTime() {
    if (this < 60) {
      return "$this seconds";
    } else if (this < 3600) {
      final minutes = (this / 60).floor();
      final seconds = this % 60;
      return seconds > 0 ? "$minutes min $seconds sec" : "$minutes minutes";
    } else {
      final hours = (this / 3600).floor();
      final minutes = ((this % 3600) / 60).floor();
      return minutes > 0 ? "$hours hr $minutes min" : "$hours hours";
    }
  }
}
