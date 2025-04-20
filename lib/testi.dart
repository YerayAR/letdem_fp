/*
 * Copyright (C) 2019-2025 HERE Europe B.V.
 *
 * Licensed under the Apache License, Version 2.0 (the "License")
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * SPDX-License-Identifier: Apache-2.0
 * License-Filename: LICENSE
 */

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:here_sdk/animation.dart' as here;
import 'package:here_sdk/core.dart';
import 'package:here_sdk/core.engine.dart';
import 'package:here_sdk/core.errors.dart';
import 'package:here_sdk/mapview.dart';
import 'package:here_sdk/routing.dart' as here;
import 'package:here_sdk/routing.dart';
import 'package:intl/intl.dart';

// A callback to notify the hosting widget.
typedef ShowDialogFunction = void Function(String title, String message);

class RoutingExample {
  final HereMapController _hereMapController;
  List<MapMarker> _mapMarkers = [];
  final List<MapPolyline> _mapPolylines = [];
  late RoutingEngine _routingEngine;
  bool _trafficOptimization = true;
  final ShowDialogFunction _showDialog;
  List<Waypoint> waypoints = [];
  final _timeUtils = TimeUtils();
  late here.Route _currentRoute;

  RoutingExample(ShowDialogFunction showDialogCallback,
      HereMapController hereMapController)
      : _showDialog = showDialogCallback,
        _hereMapController = hereMapController {
    double distanceToEarthInMeters = 10000;
    MapMeasure mapMeasureZoom =
        MapMeasure(MapMeasureKind.distanceInMeters, distanceToEarthInMeters);
    _hereMapController.camera.lookAtPointWithMeasure(
        GeoCoordinates(52.520798, 13.409408), mapMeasureZoom);

    try {
      _routingEngine = RoutingEngine();
    } on InstantiationException {
      throw ("Initialization of RoutingEngine failed.");
    }
  }

  Future<void> addRoute() async {
    // Optionally, clear any previous route.
    clearMap();

    var startGeoCoordinates = _createRandomGeoCoordinatesInViewport();
    var destinationGeoCoordinates = _createRandomGeoCoordinatesInViewport();
    var startWaypoint = Waypoint.withDefaults(startGeoCoordinates);
    var destinationWaypoint = Waypoint.withDefaults(destinationGeoCoordinates);

    waypoints = [startWaypoint, destinationWaypoint];

    _addMapMarker(startGeoCoordinates, "assets/poi_start.png");
    _addMapMarker(destinationGeoCoordinates, "assets/poi_destination.png");

    _calculateRoute(waypoints);
  }

  void onUpdateTrafficOnRouteButtonClick() {
    updateTrafficOnRoute(_currentRoute);
  }

  void updateTrafficOnRoute(here.Route route) {
    if (!_trafficOptimization) {
      _showDialog("Traffic", "Disabled traffic optimization.");
      return;
    }

    // Since traffic is being calculated for the entire route,
    // lastTraveledSectionIndex and traveledDistanceOnLastSectionInMeters are set to 0.
    int lastTraveledSectionIndex = 0;
    int traveledDistanceOnLastSectionInMeters = 0;

    _routingEngine.calculateTrafficOnRoute(
      route,
      lastTraveledSectionIndex,
      traveledDistanceOnLastSectionInMeters,
      (RoutingError? routingError, TrafficOnRoute? trafficOnRoute) {
        if (routingError != null) {
          print("CalculateTrafficOnRoute error: ${routingError.name}");
        } else {
          showUpdatedETA(trafficOnRoute!);
        }
      },
    );
  }

  void showUpdatedETA(TrafficOnRoute trafficOnRoute) {
    for (var section in trafficOnRoute.trafficSections) {
      List<TrafficOnSpan> spans = section.trafficSpans;

      int updatedETAInSeconds =
          spans.fold(0, (sum, span) => sum + span.duration.inSeconds);
      int updatedTrafficDelayInSeconds =
          spans.fold(0, (sum, span) => sum + span.trafficDelay.inSeconds);

      String updatedETAString =
          "Updated travel duration ${_timeUtils.formatTime(updatedETAInSeconds)}\n"
          "Updated traffic delay ${_timeUtils.formatTime(updatedTrafficDelayInSeconds)}";

      _showDialog("Updated traffic", updatedETAString);
    }
  }

  void toggleTrafficOptimization() {
    _trafficOptimization = !_trafficOptimization;
    if (waypoints.isNotEmpty) {
      _calculateRoute(waypoints);
    }
  }

  void _calculateRoute(List<Waypoint> waypoints) {
    CarOptions carOptions = CarOptions();
    carOptions.routeOptions.enableTolls = true;
    // This is needed when e.g. requesting TrafficOnRoute data.
    carOptions.routeOptions.enableRouteHandle = true;
    // Disabled - Traffic optimization is completely disabled, including long-term road closures. It helps in producing stable routes.
    // Time dependent - Traffic optimization is enabled, the shape of the route will be adjusted according to the traffic situation which depends on departure time and arrival time.
    carOptions.routeOptions.trafficOptimizationMode = _trafficOptimization
        ? TrafficOptimizationMode.timeDependent
        : TrafficOptimizationMode.disabled;

    _routingEngine.calculateCarRoute(waypoints, carOptions,
        (RoutingError? routingError, List<here.Route>? routeList) async {
      if (routingError == null) {
        // When error is null, then the list guaranteed to be not null.
        _currentRoute = routeList!.first;
        _showRouteDetails(_currentRoute);
        _showRouteOnMap(_currentRoute);
        _logRouteRailwayCrossingDetails(_currentRoute);
        _logRouteSectionDetails(_currentRoute);
        _logRouteViolations(_currentRoute);
        _logTollDetails(_currentRoute);
        _animateToRoute(_currentRoute);
      } else {
        var error = routingError.toString();
        _showDialog('Error', 'Error while calculating a route: $error');
      }
    });
  }

  // A route may contain several warnings, for example, when a certain route option could not be fulfilled.
  // An implementation may decide to reject a route if one or more violations are detected.
  void _logRouteViolations(here.Route route) {
    for (var section in route.sections) {
      for (var span in section.spans) {
        List<GeoCoordinates> spanGeometryVertices = span.geometry.vertices;
        // This route violation spreads across the whole span geometry.
        GeoCoordinates violationStartPoint = spanGeometryVertices[0];
        GeoCoordinates violationEndPoint =
            spanGeometryVertices[spanGeometryVertices.length - 1];
        for (var index in span.noticeIndexes) {
          SectionNotice spanSectionNotice = section.sectionNotices[index];
          // The violation code such as "violatedVehicleRestriction".
          var violationCode = spanSectionNotice.code.toString();
          print("The violation $violationCode starts at "
              "${_toString(violationStartPoint)} and ends at ${_toString(violationEndPoint)} .");
        }
      }
    }
  }

  String _toString(GeoCoordinates geoCoordinates) {
    return "${geoCoordinates.latitude},  ${geoCoordinates.longitude}";
  }

  void _logTollDetails(here.Route route) {
    for (Section section in route.sections) {
      // The spans that make up the polyline along which tolls are required or
      // where toll booths are located.
      List<Span> spans = section.spans;
      List<Toll> tolls = section.tolls;
      if (tolls.isNotEmpty) {
        print("Attention: This route may require tolls to be paid.");
      }
      for (Toll toll in tolls) {
        print("Toll information valid for this list of spans:");
        print("Toll systems: ${toll.tollSystems.join(', ')}");
        print("Toll country code (ISO-3166-1 alpha-3): ${toll.countryCode}");
        print("Toll fare information: ");
        for (TollFare tollFare in toll.fares) {
          // A list of possible toll fares which may depend on time of day, payment method and
          // vehicle characteristics. For further details please consult the local
          // authorities.
          print("Toll price: ${tollFare.price} ${tollFare.currency}");
          for (PaymentMethod paymentMethod in tollFare.paymentMethods) {
            print("Accepted payment methods for this price: $paymentMethod");
          }
        }
      }
    }
  }

  void clearMap() {
    _clearWaypointMapMarker();
    _clearRoute();
  }

  void _clearWaypointMapMarker() {
    for (MapMarker mapMarker in _mapMarkers) {
      _hereMapController.mapScene.removeMapMarker(mapMarker);
    }
    _mapMarkers.clear();
  }

  void _clearRoute() {
    for (var mapPolyline in _mapPolylines) {
      _hereMapController.mapScene.removeMapPolyline(mapPolyline);
    }
    _mapPolylines.clear();
  }

  void _logRouteSectionDetails(here.Route route) {
    DateFormat dateFormat = DateFormat().add_Hm();

    for (int i = 0; i < route.sections.length; i++) {
      Section section = route.sections.elementAt(i);

      print("Route Section : ${i + 1}");
      print(
          "Route Section Departure Time: ${dateFormat.format(section.departureLocationTime!.localTime)}");
      print(
          "Route Section Arrival Time: ${dateFormat.format(section.arrivalLocationTime!.localTime)}");
      print("Route Section length: ${section.lengthInMeters} m");
      print("Route Section duration: ${section.duration.inSeconds} s");
    }
  }

  void _logRouteRailwayCrossingDetails(here.Route route) {
    for (var routeRailwayCrossing in route.railwayCrossings) {
      // Coordinates of the route offset.
      var routeOffsetCoordinates = routeRailwayCrossing.coordinates;
      // Index of the corresponding route section. The start of the section indicates the start of the offset.
      var routeOffsetSectionIndex =
          routeRailwayCrossing.routeOffset.sectionIndex;
      // Offset from the start of the specified section to the specified location along the route.
      var routeOffsetInMeters = routeRailwayCrossing.routeOffset.offsetInMeters;

      print('A railway crossing of type ${routeRailwayCrossing.type.name} '
          'is situated $routeOffsetInMeters '
          'meters away from start of section: $routeOffsetSectionIndex');
    }
  }

  Future<void> addWaypoints() async {
    // Optionally, clear any previous route.
    clearMap();

    var startGeoCoordinates = _createRandomGeoCoordinatesInViewport();
    var destinationGeoCoordinates = _createRandomGeoCoordinatesInViewport();
    var waypoint1GeoCoordinates = _createRandomGeoCoordinatesInViewport();
    var waypoint2GeoCoordinates = _createRandomGeoCoordinatesInViewport();
    var startWaypoint = Waypoint.withDefaults(startGeoCoordinates);
    var waypoint1 = Waypoint.withDefaults(waypoint1GeoCoordinates);
    var waypoint2 = Waypoint.withDefaults(waypoint2GeoCoordinates);
    var destinationWaypoint = Waypoint.withDefaults(destinationGeoCoordinates);

    waypoints = [startWaypoint, waypoint1, waypoint2, destinationWaypoint];

    _addMapMarker(startGeoCoordinates, "assets/poi_start.png");
    _addMapMarker(waypoint1GeoCoordinates, "assets/waypoint_one.png");
    _addMapMarker(waypoint2GeoCoordinates, "assets/waypoint_two.png");
    _addMapMarker(destinationGeoCoordinates, "assets/poi_destination.png");

    _calculateRoute(waypoints);
  }

  void _showRouteDetails(here.Route route) {
    // estimatedTravelTimeInSeconds includes traffic delay.
    int estimatedTravelTimeInSeconds = route.duration.inSeconds;
    int estimatedTrafficDelayInSeconds = route.trafficDelay.inSeconds;
    int lengthInMeters = route.lengthInMeters;

    // Timezones can vary depending on the device's geographic location.
    // For instance, when calculating a route, the device's current timezone may differ from that of the destination.
    // Consider a scenario where a user calculates a route from Berlin to London — each city operates in a different timezone.
    // To address this, you can display the Estimated Time of Arrival (ETA) in multiple timezones:
    // the device's current timezone (Berlin), the destination's timezone (London),
    // and UTC (Coordinated Universal Time), which serves as a global reference.
    String routeDetails =
        'Travel Time: ${_timeUtils.formatTime(estimatedTravelTimeInSeconds)}, '
        'Traffic Delay: ${_timeUtils.formatTime(estimatedTrafficDelayInSeconds)}, '
        'Length: ${_timeUtils.formatLength(lengthInMeters)}'
        '\nETA in device timezone: ${_timeUtils.getETAinDeviceTimeZone(route)}'
        '\nETA in destination timezone: ${_timeUtils.getETAinDestinationTimeZone(route)}'
        '\nETA in UTC: ${_timeUtils.getEstimatedTimeOfArrivalInUTC(route)}';

    _showDialog('Route Details', routeDetails);
  }

  _showRouteOnMap(here.Route route) {
    // Show route as polyline.
    GeoPolyline routeGeoPolyline = route.geometry;
    double widthInPixels = 20;
    Color polylineColor = const Color.fromARGB(160, 0, 144, 138);
    MapPolyline routeMapPolyline;
    try {
      routeMapPolyline = MapPolyline.withRepresentation(
          routeGeoPolyline,
          MapPolylineSolidRepresentation(
              MapMeasureDependentRenderSize.withSingleSize(
                  RenderSizeUnit.pixels, widthInPixels),
              polylineColor,
              LineCap.round));
      _hereMapController.mapScene.addMapPolyline(routeMapPolyline);
      _mapPolylines.add(routeMapPolyline);
    } on MapPolylineRepresentationInstantiationException catch (e) {
      print("MapPolylineRepresentation Exception: ${e.error.name}");
      return;
    } on MapMeasureDependentRenderSizeInstantiationException catch (e) {
      print("MapMeasureDependentRenderSize Exception: ${e.error.name}");
      return;
    }

    // Optionally, render traffic on route.
    _showTrafficOnRoute(route);
  }

  // This renders the traffic jam factor on top of the route as multiple MapPolylines per span.
  _showTrafficOnRoute(here.Route route) {
    if (route.lengthInMeters / 1000 > 5000) {
      print("Skip showing traffic-on-route for longer routes.");
      return;
    }

    for (var section in route.sections) {
      for (var span in section.spans) {
        DynamicSpeedInfo? dynamicSpeed = span.dynamicSpeedInfo;
        Color? lineColor = _getTrafficColor(dynamicSpeed?.calculateJamFactor());
        if (lineColor == null) {
          // We skip rendering low traffic.
          continue;
        }
        double widthInPixels = 10;
        MapPolyline trafficSpanMapPolyline;
        try {
          trafficSpanMapPolyline = MapPolyline.withRepresentation(
              span.geometry,
              MapPolylineSolidRepresentation(
                  MapMeasureDependentRenderSize.withSingleSize(
                      RenderSizeUnit.pixels, widthInPixels),
                  lineColor,
                  LineCap.round));
          _hereMapController.mapScene.addMapPolyline(trafficSpanMapPolyline);
          _mapPolylines.add(trafficSpanMapPolyline);
        } on MapPolylineRepresentationInstantiationException catch (e) {
          print("MapPolylineRepresentation Exception: ${e.error.name}");
          return;
        } on MapMeasureDependentRenderSizeInstantiationException catch (e) {
          print("MapMeasureDependentRenderSize Exception: ${e.error.name}");
          return;
        }
      }
    }
  }

  // Define a traffic color scheme based on the route's jam factor.
  // 0 <= jamFactor < 4: No or light traffic.
  // 4 <= jamFactor < 8: Moderate or slow traffic.
  // 8 <= jamFactor < 10: Severe traffic.
  // jamFactor = 10: No traffic, ie. the road is blocked.
  // Returns null in case of no or light traffic.
  Color? _getTrafficColor(double? jamFactor) {
    if (jamFactor == null || jamFactor < 4) {
      return null;
    } else if (jamFactor >= 4 && jamFactor < 8) {
      return const Color.fromARGB(160, 255, 255, 0); // Yellow
    } else if (jamFactor >= 8 && jamFactor < 10) {
      return const Color.fromARGB(160, 255, 0, 0); // Red
    }
    return const Color.fromARGB(160, 0, 0, 0); // Black
  }

  GeoCoordinates _createRandomGeoCoordinatesInViewport() {
    GeoBox? geoBox = _hereMapController.camera.boundingBox;
    if (geoBox == null) {
      // Happens only when map is not fully covering the viewport as the map is tilted.
      print(
          "The map view is tilted, falling back to fixed destination coordinate.");
      return GeoCoordinates(52.520798, 13.409408);
    }

    GeoCoordinates northEast = geoBox.northEastCorner;
    GeoCoordinates southWest = geoBox.southWestCorner;

    double minLat = southWest.latitude;
    double maxLat = northEast.latitude;
    double lat = _getRandom(minLat, maxLat);

    double minLon = southWest.longitude;
    double maxLon = northEast.longitude;
    double lon = _getRandom(minLon, maxLon);

    return GeoCoordinates(lat, lon);
  }

  double _getRandom(double min, double max) {
    return min + Random().nextDouble() * (max - min);
  }

  void _animateToRoute(here.Route route) {
    // The animation results in an untilted and unrotated map.
    double bearing = 0;
    double tilt = 0;
    // We want to show the route fitting in the map view with an additional padding of 50 pixels.
    Point2D origin = Point2D(50, 50);
    Size2D sizeInPixels = Size2D(_hereMapController.viewportSize.width - 100,
        _hereMapController.viewportSize.height - 100);
    Rectangle2D mapViewport = Rectangle2D(origin, sizeInPixels);

    // Animate to the route within a duration of 3 seconds.
    MapCameraUpdate update =
        MapCameraUpdateFactory.lookAtAreaWithGeoOrientationAndViewRectangle(
            route.boundingBox,
            GeoOrientationUpdate(bearing, tilt),
            mapViewport);
    MapCameraAnimation animation =
        MapCameraAnimationFactory.createAnimationFromUpdateWithEasing(
            update,
            const Duration(milliseconds: 3000),
            here.Easing(here.EasingFunction.inCubic));
    _hereMapController.camera.startAnimation(animation);
  }

  void _addMapMarker(GeoCoordinates geoCoordinates, String imageName) {
    // For this app, we only add images of size 100x100 pixels.
    int imageWidth = 100;
    int imageHeight = 100;
    // Note that you can optionally optimize by reusing the mapImage instance for other MapMarker instance.
    MapImage mapImage = MapImage.withFilePathAndWidthAndHeight(
        imageName, imageWidth, imageHeight);
    MapMarker mapMarker = MapMarker(geoCoordinates, mapImage);
    _hereMapController.mapScene.addMapMarker(mapMarker);
    _mapMarkers.add(mapMarker);
  }
}
/*
 * Copyright (C) 2019-2025 HERE Europe B.V.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * SPDX-License-Identifier: Apache-2.0
 * License-Filename: LICENSE
 */

class TimeUtils {
  /// Converts time in seconds to a formatted string in "HH:mm" format.
  ///
  /// @param sec the time in seconds to be converted.
  /// @return a string representing the time in "HH:mm" format.
  String formatTime(int sec) {
    // Calculate the number of hours from the given seconds
    int hours = sec ~/ 3600;

    // Calculate the number of minutes remaining after extracting hours
    int minutes = (sec % 3600) ~/ 60;

    // Format the hours and minutes into a string with "HH:mm" format
    return '$hours:$minutes min';
  }

  /// Converts length in meters to a formatted string in "km" format.
  ///
  /// @param meters the length in meters to be converted.
  /// @return a string representing the length in "km" format.
  String formatLength(int meters) {
    // Calculate the number of kilometers from the given meters
    int kilometers = meters ~/ 1000;

    // Calculate the remaining meters after extracting kilometers
    int remainingMeters = meters % 1000;

    // Format the kilometers and remaining meters into a string with "km" format
    return '$kilometers.$remainingMeters km';
  }

  /// Returns the ETA (as a string in ‘HH:mm’ format) in the current device’s timezone,
  /// derived from the estimatedTravelTimeInSeconds, which is sourced from the Route object.
  ///
  /// @param route Original route object from RoutingEngine.
  /// @return A string representing the ETA in "HH:mm" format.
  String getETAinDeviceTimeZone(here.Route route) {
    int estimatedTravelTimeInSeconds = route.duration.inSeconds;

    // Get the current date and time
    DateTime now = DateTime.now();

    // Add the estimated travel time (in seconds) to the current time
    DateTime eta = now.add(Duration(seconds: estimatedTravelTimeInSeconds));

    return DateFormat('hh:mm a').format(eta);
  }

  /// Calculates the estimated time of arrival (ETA) in the destination timezone for a given route.
  /// It is possible that the destination can be in a different timezone compared to the source.
  /// Therefore, we are also calculating the ETA in the destination timezone.
  ///
  /// @param route Original route object from RoutingEngine.
  /// @return A string representing the estimated time of arrival in the destination timezone, formatted as "HH:mm".
  String getETAinDestinationTimeZone(here.Route route) {
    DateTime destinationDate = getArrivalLocationTime(route).localTime;
    return DateFormat('hh:mm a').format(destinationDate);
  }

  /// Calculates the estimated time of arrival (ETA) in Coordinated Universal Time (UTC) for a given route.
  /// UTC (Coordinated Universal Time) is the primary time standard by which the world regulates clocks and time.
  ///
  /// @param route Original route object from RoutingEngine.
  /// @return A string representing the estimated time of arrival in UTC, formatted as "HH:mm".
  String getEstimatedTimeOfArrivalInUTC(here.Route route) {
    DateTime utcDate = getArrivalLocationTime(route).utcTime;

    // The UTC offset represents the difference in hours and minutes between a specific time zone and Coordinated Universal Time (UTC).
    // It indicates whether the local time is ahead (+) or behind (-) UTC.
    return DateFormat('hh:mm a').format(utcDate);
  }

  /// Returns the arrival time at the final location of the route.
  LocationTime getArrivalLocationTime(here.Route route) {
    int lastSectionIndex = route.sections.length - 1;

    // The lastSection contains cumulative duration values that increase sequentially.
    Section lastSection = route.sections[lastSectionIndex];
    return lastSection.arrivalLocationTime!;
  }
}
/*
 * Copyright (C) 2019-2025 HERE Europe B.V.
 *
 * Licensed under the Apache License, Version 2.0 (the "License")
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * SPDX-License-Identifier: Apache-2.0
 * License-Filename: LICENSE
 */

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  RoutingExample? _routingExample;
  HereMapController? _hereMapController;
  final List<bool> _selectedTrafficOptimization = <bool>[true];
  late final AppLifecycleListener _appLifecycleListener;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HERE SDK - Routing Example'),
      ),
      body: Stack(
        children: [
          HereMap(onMapCreated: _onMapCreated),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  button('Add Route', _addRouteButtonClicked),
                  button(' Add\nWaypoints', _addWaypointButtonClicked),
                  button('Clear Map', _clearMapButtonClicked),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ToggleButtons(
                      onPressed: (int index) {
                        _toggleTrafficOptimization();
                        setState(() {
                          _selectedTrafficOptimization[index] =
                              !_selectedTrafficOptimization[index];
                        });
                      },
                      isSelected: _selectedTrafficOptimization,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: Colors.lightBlueAccent,
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          child: Text(
                            _selectedTrafficOptimization[0]
                                ? 'Traffic Optimization-On'
                                : 'Traffic Optimization-OFF',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15.0,
                            ),
                          ),
                        ),
                      ]),
                  button('Update traffic \n on route', _updateTrafficOnRoute),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _onMapCreated(HereMapController hereMapController) {
    _hereMapController = hereMapController;

    // Load the map scene using a map scheme to render the map with.
    _hereMapController?.mapScene.loadSceneForMapScheme(MapScheme.normalDay,
        (MapError? error) {
      if (error == null) {
        _hereMapController?.mapScene.enableFeatures(
            {MapFeatures.lowSpeedZones: MapFeatureModes.lowSpeedZonesAll});
        _routingExample = RoutingExample(_showDialog, hereMapController);
      } else {
        print("Map scene not loaded. MapError: $error");
      }
    });
  }

  void _toggleTrafficOptimization() {
    _routingExample?.toggleTrafficOptimization();
  }

  void _addRouteButtonClicked() {
    _routingExample?.addRoute();
  }

  void _addWaypointButtonClicked() {
    _routingExample?.addWaypoints();
  }

  void _updateTrafficOnRoute() {
    _routingExample?.onUpdateTrafficOnRouteButtonClick();
  }

  void _clearMapButtonClicked() {
    _routingExample?.clearMap();
  }

  @override
  void initState() {
    super.initState();
    _appLifecycleListener = AppLifecycleListener(
      onDetach: () =>
          // Sometimes Flutter may not reliably call dispose(),
          // therefore it is recommended to dispose the HERE SDK
          // also when the AppLifecycleListener is detached.
          // See more details: https://github.com/flutter/flutter/issues/40940
          {print('AppLifecycleListener detached.'), _disposeHERESDK()},
    );
  }

  @override
  void dispose() {
    _disposeHERESDK();
    super.dispose();
  }

  void _disposeHERESDK() async {
    // Free HERE SDK resources before the application shuts down.
    await SDKNativeEngine.sharedInstance?.dispose();
    SdkContext.release();
    _appLifecycleListener.dispose();
  }

  // A helper method to add a button on top of the HERE map.
  Align button(String buttonLabel, Function callbackFunction) {
    return Align(
      alignment: Alignment.topCenter,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.lightBlueAccent,
        ),
        onPressed: () => callbackFunction(),
        child: Text(buttonLabel, style: const TextStyle(fontSize: 15)),
      ),
    );
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
              child: const Text('OK'),
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
