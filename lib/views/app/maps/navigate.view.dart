import 'package:flutter/material.dart';
import 'package:here_sdk/core.dart' as HERE;
import 'package:here_sdk/core.engine.dart';
import 'package:here_sdk/core.errors.dart';
import 'package:here_sdk/mapview.dart';
import 'package:here_sdk/navigation.dart' as HERE;
import 'package:here_sdk/routing.dart' as HERE;
import 'package:here_sdk/location.dart' as HERE;
import 'package:letdem/constants/ui/colors.dart'; // For current location

class NavigationView extends StatefulWidget {
  final double? destinationLat;
  final double? destinationLng;

  const NavigationView({
    super.key,
    this.destinationLat,
    this.destinationLng
  });

  @override
  State<NavigationView> createState() => _NavigationViewState();
}

class _NavigationViewState extends State<NavigationView> {
  HereMapController? _hereMapController;
  late final AppLifecycleListener _listener;

  HERE.RoutingEngine? _routingEngine;
  HERE.VisualNavigator? _visualNavigator;
  HERE.LocationSimulator? _locationSimulator;
  HERE.LocationEngine? _locationEngine;
  HERE.GeoCoordinates? _currentLocation;

  bool _isNavigating = false;
  String _navigationInstruction = "";
  int _distanceToNextManeuver = 0;
  int _totalRouteTime = 0;
  int _totalRouteDistance = 0;
  bool _isMuted = false;

  Future<bool> _handleBackPress() async {
    // Handle the back press.
    _visualNavigator?.stopRendering();
    _locationSimulator?.stop();
    _locationEngine?.stop();




    // Return true to allow the back press.
    return true;
  }


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _handleBackPress,
      child: Scaffold(
        body: Stack(
          children: [
            // Map takes the full screen
            HereMap(onMapCreated: _onMapCreated),

            // Navigation banner at the top
            if (_isNavigating && _navigationInstruction.isNotEmpty)
              Positioned(
                top: MediaQuery.of(context).padding.top + 10,
                left: 20,
                right: 20,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.amber,
                        ),
                        child: Icon(Icons.turn_right, color: Colors.black, size: 24),
                      ),
                      SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${_distanceToNextManeuver}m ahead',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Text(
                              _navigationInstruction,
                              style: TextStyle(color: Colors.white, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(_isMuted ? Icons.volume_off : Icons.volume_up, color: Colors.white),
                        onPressed: () {
                          setState(() {
                            _isMuted = !_isMuted;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),

            // Bottom info panel
            if (_isNavigating)
              Positioned(
                bottom: 30,
                left: 20,
                right: 20,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: _stopNavigation,
                        child: Icon(Icons.close, color: Colors.black54),
                      ),
                      Text(
                        '${_totalRouteTime ~/ 60} mins (${_totalRouteDistance}m)',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary500,
                        ),
                        child: Icon(Icons.add, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),

            // Current position indicator
            if (_isNavigating)
              Positioned(
                bottom: 240,
                left: MediaQuery.of(context).size.width / 2 - 25,
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.purple,
                  ),
                  child: Icon(Icons.navigation, color: Colors.white, size: 30),
                ),
              ),

            // Input destination dialog when not navigating
            // if (!_isNavigating)
            //   Center(
            //     child: Container(
            //       width: 300,
            //       padding: EdgeInsets.all(20),
            //       decoration: BoxDecoration(
            //         color: Colors.white,
            //         borderRadius: BorderRadius.circular(12),
            //         boxShadow: [
            //           BoxShadow(
            //             color: Colors.black26,
            //             blurRadius: 10,
            //           ),
            //         ],
            //       ),
            //       child: Column(
            //         mainAxisSize: MainAxisSize.min,
            //         children: [
            //           Text(
            //             'Enter Destination',
            //             style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            //           ),
            //           SizedBox(height: 20),
            //           TextField(
            //             decoration: InputDecoration(
            //               labelText: 'Latitude',
            //               border: OutlineInputBorder(),
            //               hintText: widget.destinationLat?.toString() ?? '52.530905',
            //             ),
            //             keyboardType: TextInputType.number,
            //             controller: TextEditingController(
            //               text: widget.destinationLat?.toString() ?? '',
            //             ),
            //             onChanged: (value) {
            //               // Update destination lat
            //             },
            //           ),
            //           SizedBox(height: 10),
            //           TextField(
            //             decoration: InputDecoration(
            //               labelText: 'Longitude',
            //               border: OutlineInputBorder(),
            //               hintText: widget.destinationLng?.toString() ?? '13.385007',
            //             ),
            //             keyboardType: TextInputType.number,
            //             controller: TextEditingController(
            //               text: widget.destinationLng?.toString() ?? '',
            //             ),
            //             onChanged: (value) {
            //               // Update destination lng
            //             },
            //           ),
            //           SizedBox(height: 20),
            //           ElevatedButton(
            //             onPressed: _startNavigation,
            //             style: ElevatedButton.styleFrom(
            //               backgroundColor: Colors.blue,
            //               foregroundColor: Colors.white,
            //               minimumSize: Size(double.infinity, 50),
            //             ),
            //             child: Text('Start Navigation'),
            //           ),
            //         ],
            //       ),
            //     ),
            //   ),
          ],
        ),
      ),
    );
  }

  void _onMapCreated(HereMapController hereMapController) {
    _hereMapController = hereMapController;
    _hereMapController!.mapScene.loadSceneForMapScheme(MapScheme.normalDay, (MapError? error) {
      if (error != null) {
        print('Map scene not loaded. MapError: ${error.toString()}');
        return;
      }

      // Start with a default view of the map
      const double distanceToEarthInMeters = 8000;
      MapMeasure mapMeasureZoom = MapMeasure(MapMeasureKind.distanceInMeters, distanceToEarthInMeters);
      _hereMapController!.camera.lookAtPointWithMeasure(HERE.GeoCoordinates(52.520798, 13.409408), mapMeasureZoom);

      // Initialize location engine to get current location
      _initLocationEngine();
    });
  }

  void _initLocationEngine() {
    try {
      _locationEngine = HERE.LocationEngine();
    } on InstantiationException {
      throw Exception('Initialization of LocationEngine failed.');
    }

    // Start listening for location updates

  }

  void _startNavigation() {
    // Get destination from widget parameters or use default
    double destLat = widget.destinationLat ?? 52.530905;
    double destLng = widget.destinationLng ?? 13.385007;

    if (_currentLocation == null) {
      // If current location is not available, use a default starting point
      _currentLocation = HERE.GeoCoordinates(52.520798, 13.409408);
      print("Using default starting location");
    }

    // Calculate route from current location to destination
    _calculateRoute(_currentLocation!, HERE.GeoCoordinates(destLat, destLng));
  }

  void _calculateRoute(HERE.GeoCoordinates start, HERE.GeoCoordinates destination) {
    try {
      _routingEngine = HERE.RoutingEngine();
    } on InstantiationException {
      throw Exception('Initialization of RoutingEngine failed.');
    }

    HERE.Waypoint startWaypoint = HERE.Waypoint(start);
    HERE.Waypoint destinationWaypoint = HERE.Waypoint(destination);

    _routingEngine!.calculateCarRoute([startWaypoint, destinationWaypoint], HERE.CarOptions(),
            (HERE.RoutingError? routingError, List<HERE.Route>? routeList) async {
          if (routingError == null) {
            // When error is null, it is guaranteed that the routeList is not empty.
            HERE.Route calculatedRoute = routeList!.first;

            // Get route information
            _totalRouteTime = calculatedRoute.duration.inSeconds;
            _totalRouteDistance = calculatedRoute.lengthInMeters;

            setState(() {
              _isNavigating = true;
            });

            _startGuidance(calculatedRoute);
          } else {
            final error = routingError.toString();
            print('Error while calculating a route: $error');
            _showDialog("Route Error", "Could not calculate route. Please try again.");
          }
        });
  }

  void _startGuidance(HERE.Route route) {
    try {
      _visualNavigator = HERE.VisualNavigator();
    } on InstantiationException {
      throw Exception("Initialization of VisualNavigator failed.");
    }

    // This enables a navigation view including a rendered navigation arrow.
    _visualNavigator!.startRendering(_hereMapController!);

    // Set up maneuver instructions listener
    _visualNavigator!.eventTextListener = HERE.EventTextListener((HERE.EventText eventText) {
      print("Voice maneuver text: ${eventText.text}");
      setState(() {
        _navigationInstruction = eventText.text;
      });
    });

    // Set up distance to maneuver listener
    // _visualNavigator!.maneuverEventListener = HERE.ManeuverEventListener((HERE.ManeuverEventData data) {
    //   setState(() {
    //     _distanceToNextManeuver = data.distanceToNextManeuverInMeters;
    //   });
    // });

    // Set a route to follow
    _visualNavigator!.route = route;

    // Use location simulator for demo, in real app use real location
    _setupLocationSource(_visualNavigator!, route);
  }

  void _setupLocationSource(HERE.LocationListener locationListener, HERE.Route route) {
    try {
      // Provides fake GPS signals based on the route geometry.
      _locationSimulator = HERE.LocationSimulator.withRoute(route, HERE.LocationSimulatorOptions());
    } on InstantiationException {
      throw Exception("Initialization of LocationSimulator failed.");
    }

    _locationSimulator!.listener = locationListener;
    _locationSimulator!.start();
  }

  void _stopNavigation() {
    _visualNavigator?.stopRendering();
    _locationSimulator?.stop();

    setState(() {
      _isNavigating = false;
      _navigationInstruction = "";
    });
  }

  @override
  void initState() {
    super.initState();
    _listener = AppLifecycleListener(
      onDetach: () {
        print('AppLifecycleListener detached.');
        _disposeHERESDK();
      },
    );
    _startNavigation();
  }

  @override
  void dispose() {
    _disposeHERESDK();
    super.dispose();
  }

  void _disposeHERESDK() async {
    // Free HERE SDK resources before the application shuts down.
    _locationEngine?.stop();
    await SDKNativeEngine.sharedInstance?.dispose();
    HERE.SdkContext.release();
    _listener.dispose();
  }

  // A helper method to show a dialog.
  Future<void> _showDialog(String title, String message) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(message),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}