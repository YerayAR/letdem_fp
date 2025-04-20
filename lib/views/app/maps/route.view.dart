import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart' as geolocator;
import 'package:here_sdk/animation.dart' as an;
import 'package:here_sdk/core.dart';
import 'package:here_sdk/mapview.dart';
import 'package:here_sdk/navigation.dart' as navigation;
import 'package:here_sdk/routing.dart' as routing;
import 'package:iconly/iconly.dart';
import 'package:intl/intl.dart';
import 'package:letdem/constants/ui/colors.dart';
import 'package:letdem/constants/ui/dimens.dart';
import 'package:letdem/constants/ui/typo.dart';
import 'package:letdem/features/scheduled_notifications/schedule_notifications_bloc.dart';
import 'package:letdem/global/popups/popup.dart';
import 'package:letdem/global/widgets/button.dart';
import 'package:letdem/global/widgets/chip.dart';
import 'package:letdem/models/map/coordinate.model.dart';
import 'package:letdem/services/location/location.service.dart';
import 'package:letdem/services/map/map_asset_provider.service.dart';
import 'package:letdem/services/res/navigator.dart';
import 'package:letdem/services/toast/toast.dart';
import 'package:letdem/views/app/home/widgets/home/shimmers/home_page_shimmer.widget.dart';
import 'package:letdem/views/app/maps/navigate.view.dart';
import 'package:letdem/views/app/profile/screens/scheduled_notifications/scheduled_notifications.view.dart';
import 'package:letdem/views/app/profile/widgets/settings_container.widget.dart';
import 'package:letdem/views/auth/views/onboard/verify_account.view.dart';

class TrafficRouteLineExample extends StatefulWidget {
  final double lat;
  final double lng;
  final String? streetName;
  final bool hideToggle;

  const TrafficRouteLineExample(
      {super.key,
      required this.lat,
      required this.lng,
      required this.hideToggle,
      required this.streetName});

  @override
  State createState() => TrafficRouteLineExampleState();
}

class TrafficRouteLineExampleState extends State<TrafficRouteLineExample> {
  RouteInfo? routeInfo;
  bool isDataLoading = true;

  HereMapController? _hereMapController;
  routing.RoutingEngine? _routingEngine;
  navigation.VisualNavigator? _visualNavigator;

  // London Heath coordinates

  @override
  void initState() {
    super.initState();
    getMapData();
    _routingEngine = routing.RoutingEngine();
  }

  // Initialize _currentRoute as nullable
  routing.Route? _currentRoute;

  @override
  void dispose() {
    _visualNavigator?.stopRendering();
    // Clear map resources
    _clearMapResources();
    super.dispose();
  }

  List<MapMarker> _mapMarkers = [];
  final List<MapPolyline> _mapPolylines = [];

  void _addMapMarker(GeoCoordinates geoCoordinates, Uint8List icon) {
    if (_hereMapController == null) return;

    try {
      // Create a map marker with the image
      final marker = MapMarker(
        geoCoordinates,
        MapImage.withPixelDataAndImageFormat(icon, ImageFormat.png),
      );
      // Add the marker to the map
      _hereMapController!.mapScene.addMapMarker(marker);

      // var destination = _assetsProvider.destinationMarker;
      //
      // // Create a map marker with the image
      // final destinationMarker = MapMarker(
      //   geoCoordinates,
      //   MapImage.withPixelDataAndImageFormat(destination, ImageFormat.png),
      // );
      // Add the marker to the map
      // _hereMapController!.mapScene.addMapMarker(destinationMarker);
    } catch (e) {
      print("Error adding map marker: $e");
    }
  }

  void _showRouteOnMap(routing.Route route) {
    if (_hereMapController == null) return;

    // Show route as polyline.
    GeoPolyline routeGeoPolyline = route.geometry;
    double widthInPixels = 20;
    Color polylineColor = AppColors.primary300;

    try {
      MapPolyline routeMapPolyline = MapPolyline.withRepresentation(
          routeGeoPolyline,
          MapPolylineSolidRepresentation(
            MapMeasureDependentRenderSize.withSingleSize(
                RenderSizeUnit.pixels, widthInPixels),
            polylineColor,
            LineCap.round,
          ));
      _hereMapController!.mapScene.addMapPolyline(routeMapPolyline);
      _mapPolylines.add(routeMapPolyline);
    } on MapPolylineRepresentationInstantiationException catch (e) {
      print("MapPolylineRepresentation Exception: ${e.error.name}");
      return;
    } on MapMeasureDependentRenderSizeInstantiationException catch (e) {
      print("MapMeasureDependentRenderSize Exception: ${e.error.name}");
      return;
    } catch (e) {
      print("Error showing route on map: $e");
      return;
    }

    // Optionally, render traffic on route.
    // _showTrafficOnRoute(route);
  }

  void _calculateRoute(List<routing.Waypoint> waypoints) {
    if (_routingEngine == null) {
      print("RoutingEngine not initialized");
      return;
    }

    // Print waypoints for debugging
    print("Calculating route with waypoints:");
    for (var waypoint in waypoints) {
      print(
          "Waypoint: ${waypoint.coordinates.latitude}, ${waypoint.coordinates.longitude}");
    }

    routing.CarOptions carOptions = routing.CarOptions();
    carOptions.routeOptions.enableTolls = true;
    carOptions.routeOptions.enableRouteHandle = true;
    carOptions.routeOptions.trafficOptimizationMode =
        routing.TrafficOptimizationMode.timeDependent;

    _routingEngine?.calculateCarRoute(waypoints, carOptions,
        (routing.RoutingError? routingError,
            List<routing.Route>? routeList) async {
      if (routingError == null && routeList != null && routeList.isNotEmpty) {
        _currentRoute = routeList.first;
        _showRouteOnMap(_currentRoute!);
        _animateToRoute(_currentRoute!);
      } else {
        var error = routingError?.toString() ?? "Unknown routing error";
        print("Error calculating route: $error");

        // Handle "no route found" case specifically
        if (routingError == routing.RoutingError.noRouteFound) {
          // Consider showing a user-friendly message
          print(
              "Could not find a route between the specified locations. Try different coordinates.");

          // Optionally, you could try with different routing options
          // such as disabling toll roads or trying a different transport mode
        }
      }
    });
  }

  // Implement clearMap function to remove previous routes and markers
  void _clearMapResources() {
    if (_hereMapController == null) return;

    // Clear markers
    for (var marker in _mapMarkers) {
      _hereMapController?.mapScene.removeMapMarker(marker);
    }
    _mapMarkers.clear();

    // Clear polylines
    for (var polyline in _mapPolylines) {
      _hereMapController?.mapScene.removeMapPolyline(polyline);
    }
    _mapPolylines.clear();
  }

  List<routing.Waypoint> waypoints = [];

  void _animateToRoute(routing.Route route) {
    if (_hereMapController == null) return;

    try {
      // The animation results in an untilted and unrotated map.
      double bearing = 0;
      double tilt = 0;
      // We want to show the route fitting in the map view with an additional padding of 50 pixels.
      Point2D origin = Point2D(50, 50);
      Size2D sizeInPixels = Size2D(_hereMapController!.viewportSize.width - 100,
          _hereMapController!.viewportSize.height - 100);
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
        an.Easing(
          an.EasingFunction.inCubic,
        ),
      );
      _hereMapController!.camera.startAnimation(animation);
    } catch (e) {
      print("Error animating to route: $e");
    }
  }

  Future<void> addRoute() async {
    // Clear any previous route.
    _clearMapResources();

    var currentLocation = await geolocator.Geolocator.getCurrentPosition();

    var startGeoCoordinates =
        GeoCoordinates(currentLocation.latitude, currentLocation.longitude);
    var destinationGeoCoordinates = GeoCoordinates(widget.lat, widget.lng);
    var startWaypoint = routing.Waypoint.withDefaults(startGeoCoordinates);
    var destinationWaypoint =
        routing.Waypoint.withDefaults(destinationGeoCoordinates);

    waypoints = [startWaypoint, destinationWaypoint];

    // Check if assets exist before adding markers
    try {
      var startMarker = _assetsProvider.currentLocationMarker;
      var destinationMarker = _assetsProvider.destinationMarker;

      _addMapMarker(startGeoCoordinates, startMarker);
      _addMapMarker(destinationGeoCoordinates, destinationMarker);
      _calculateRoute(waypoints);
    } catch (e) {
      print("Error adding route: $e");
    }
  }

  void _onHereMapCreated(HereMapController hereMapController) {
    _hereMapController = hereMapController;

    // focus on the current location
    _hereMapController!.camera.lookAtPointWithMeasure(
      GeoCoordinates(currentLocation.latitude, currentLocation.longitude),
      MapMeasure(MapMeasureKind.distanceInMeters, 1000),
    );

    // Set map scheme
    _hereMapController!.mapScene.loadSceneForMapScheme(MapScheme.normalDay,
        (MapError? error) {
      if (error != null) {
        print('Map scene loading failed: ${error.toString()}');
        return;
      }

      // Add route once map is ready
      addRoute();
    });
  }

  late geolocator.Position currentLocation;
  final MapAssetsProvider _assetsProvider = MapAssetsProvider();

  Future<void> getMapData() async {
    setState(() {
      isDataLoading = true;
    });

    try {
      await _assetsProvider.loadAssets();

      var currentLocationInfo =
          await geolocator.Geolocator.getCurrentPosition();

      print("Current Location");
      print(currentLocationInfo.latitude);
      print(currentLocationInfo.longitude);

      print("Destination Location");
      print(widget.lat);
      print(widget.lng);

      print("Street Name");
      print(widget.streetName);

      routeInfo = await MapboxService.getRoutes(
        currentPointLatitude: currentLocationInfo.latitude,
        currentPointLongitude: currentLocationInfo.longitude,
        destinationLatitude: widget.lat,
        destinationLongitude: widget.lng,
        destination: widget.streetName,
      );

      setState(() {
        currentLocation = currentLocationInfo;
        isDataLoading = false;
      });
    } catch (e) {
      print("Error getting map data: $e");
      setState(() {
        isDataLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          leading: const SizedBox(),
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            CircleAvatar(
              backgroundColor: Colors.white,
              child: IconButton(
                icon: const Icon(
                  Icons.close,
                  size: 20,
                ),
                onPressed: () {
                  NavigatorHelper.pop();
                },
              ),
            ),
            Dimens.space(2),
          ],
        ),
        floatingActionButton: const Padding(
          padding: EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              SizedBox(height: 10),
            ],
          ),
        ),
        body: Stack(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: isDataLoading
                  ? const Center(
                      child: CupertinoActivityIndicator(),
                    )
                  : HereMap(
                      key: UniqueKey(),
                      onMapCreated: _onHereMapCreated,
                    ),
            ),
            Positioned(
                left: 0,
                bottom: 0,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: isDataLoading && routeInfo == null
                      ? Container(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(16),
                              topRight: Radius.circular(16),
                            ),
                          ),
                          //   add shimmer here
                          child: const Column(
                            children: [
                              SizedBox(
                                  child: Column(
                                children: [
                                  HomePageShimmer(),
                                ],
                              )),
                            ],
                          ),
                        )
                      : NavigateNotificationCard(
                          hideToggle: widget.hideToggle,
                          routeInfo: routeInfo,
                          notification: ScheduledNotification(
                              id: "1",
                              startsAt: DateTime.now(),
                              endsAt: DateTime.now(),
                              isExpired: false,
                              location: LocationData(
                                streetName: widget.streetName ?? '',
                                point: CoordinatesData(
                                  longitude: widget.lng,
                                  latitude: widget.lat,
                                ),
                              )),
                        ),
                )),
          ],
        ));
  }
}

class NavigateNotificationCard extends StatefulWidget {
  final ScheduledNotification notification;
  final RouteInfo? routeInfo;

  final bool hideToggle;
  const NavigateNotificationCard(
      {super.key,
      required this.notification,
      required this.hideToggle,
      this.routeInfo});

  @override
  State<NavigateNotificationCard> createState() =>
      _NavigateNotificationCardState();
}

class _NavigateNotificationCardState extends State<NavigateNotificationCard> {
  bool notifyAvailableSpace = false;
  double radius = 100;

  bool isNotificationScheduled = false;

  bool isLocationAvailable = false;

  TimeOfDay _fromTime = TimeOfDay.now();
  TimeOfDay _toTime = TimeOfDay.now();

  DateTime _fromDate = DateTime.now();
  DateTime _toDate = DateTime.now();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ScheduleNotificationsBloc, ScheduleNotificationsState>(
      listener: (context, state) {
        if (state is ScheduleNotificationCreated) {
          setState(() {
            isNotificationScheduled = true;
          });
          AppPopup.showDialogSheet(
            context,
            SuccessDialog(
              title: "Notification Scheduled",
              subtext:
                  "You will be notified when a space is available in this area",
              onProceed: () {
                Navigator.pop(context);
              },
            ),
          );
        }

        // TODO: implement listener
      },
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: widget.routeInfo != null && widget.routeInfo!.distance < 500
              ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Dimens.space(4),
                      CircleAvatar(
                        radius: 43,
                        backgroundColor: AppColors.green50,
                        child: Icon(
                          IconlyBold.location,
                          color: AppColors.green600,
                          size: 36,
                        ),
                      ),
                      Dimens.space(2),
                      const Text(
                        "Close to Location",
                        style: Typo.heading4,
                      ),
                      const SizedBox(height: 8),
                      const Center(
                        child: Text(
                          "You are close to the location, Please select a different location",
                          style: Typo.mediumBody,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Dimens.space(4),
                      PrimaryButton(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        text: "Close",
                      ),
                      Dimens.space(4),
                    ],
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: isLocationAvailable
                      ? [
                          const SizedBox(
                            height: 100,
                            child: Center(
                              child: CupertinoActivityIndicator(),
                            ),
                          ),
                        ]
                      : [
                          // Time and distance row
                          Row(
                            children: [
                              Text(
                                // Format distance to miles to kilometers

                                "${parseHours((widget.routeInfo!.duration))} (${parseMeters(widget.routeInfo!.distance)})",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              Row(
                                children: [
                                  const Text(
                                    "Traffic Level",
                                    style: TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  DecoratedChip(
                                    text: toBeginningOfSentenceCase(
                                            widget.routeInfo?.tafficLevel) ??
                                        "--",
                                    textStyle: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primary500,
                                    ),
                                    color: AppColors.primary500,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 22),

                          // Location
                          Row(
                            children: [
                              const Icon(IconlyLight.location,
                                  color: Colors.grey),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  widget.notification.location.streetName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Arrival time
                          Row(
                            children: [
                              const Icon(IconlyLight.time_circle,
                                  color: Colors.grey),
                              const SizedBox(width: 8),
                              Text(
                                "To Arrived by ${DateFormat('HH:mm').format(widget.routeInfo!.arrivingAt.toLocal())}",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          Divider(color: Colors.grey.withOpacity(0.2)),
                          const SizedBox(height: 16),

                          // Notification toggle
                          Column(
                            children: isNotificationScheduled
                                ? []
                                : [
                                    Row(
                                      children: widget.hideToggle
                                          ? []
                                          : [
                                              const Icon(
                                                  IconlyLight.notification,
                                                  color: Colors.grey),
                                              const SizedBox(width: 8),
                                              const Expanded(
                                                child: Text(
                                                  "Notify me of available space in this area",
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                              ToggleSwitch(
                                                value: notifyAvailableSpace,
                                                onChanged: (value) {
                                                  setState(() {
                                                    notifyAvailableSpace =
                                                        value;
                                                  });
                                                },
                                              ),
                                            ],
                                    ),
                                    SizedBox(
                                        height: widget.hideToggle ? 0 : 16),

                                    // Time selection buttons
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: !notifyAvailableSpace
                                          ? []
                                          : [
                                              Divider(
                                                  color: Colors.grey
                                                      .withOpacity(0.2)),
                                              Dimens.space(1),

                                              const Text(
                                                "Date & Time",
                                              ),
                                              Dimens.space(3),
                                              Row(
                                                spacing: 15,
                                                children: [
                                                  PlatformDatePickerButton(
                                                      initialDate: _fromDate,
                                                      onDateSelected: (date) {
                                                        setState(() {
                                                          _fromDate = date;
                                                        });
                                                      }),
                                                  PlatformTimePickerButton(
                                                      initialTime: _fromTime,
                                                      onTimeSelected: (time) {
                                                        setState(() {
                                                          _fromTime = time;
                                                        });
                                                      }),
                                                ],
                                              ),
                                              Dimens.space(1),

                                              Row(
                                                spacing: 15,
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  PlatformDatePickerButton(
                                                      initialDate: _toDate,
                                                      onDateSelected: (date) {
                                                        setState(() {
                                                          _toDate = date;
                                                        });
                                                      }),
                                                  PlatformTimePickerButton(
                                                      initialTime: _toTime,
                                                      onTimeSelected: (time) {
                                                        setState(() {
                                                          _toTime = time;
                                                        });
                                                      }),
                                                ],
                                              ),
                                              const SizedBox(height: 24),

                                              // Radius slider
                                              Row(
                                                children: [
                                                  const Text(
                                                    "Receive notifications up to (meters)",
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                  const Spacer(),
                                                  Text(
                                                    radius.toStringAsFixed(0),
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 8),
                                              SliderTheme(
                                                data: SliderTheme.of(context)
                                                    .copyWith(
                                                  activeTrackColor:
                                                      Colors.purple,
                                                  inactiveTrackColor: Colors
                                                      .purple
                                                      .withOpacity(0.2),
                                                  thumbColor: Colors.white,
                                                  overlayColor: Colors.purple
                                                      .withOpacity(0.2),
                                                  thumbShape:
                                                      const RoundSliderThumbShape(
                                                          enabledThumbRadius:
                                                              8),
                                                ),
                                                child: Slider(
                                                  value: radius,
                                                  min: 100,
                                                  max: 9000,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      radius = value;
                                                    });
                                                  },
                                                ),
                                              ),
                                            ],
                                    ),
                                    const SizedBox(height: 24),
                                  ],
                          ),

                          // Reschedule button
                          PrimaryButton(
                            isLoading: state is ScheduleNotificationsLoading,
                            onTap: () {
                              if (notifyAvailableSpace &&
                                  !isNotificationScheduled) {
                                DateTime start = DateTime(
                                  _fromDate.year,
                                  _fromDate.month,
                                  _fromDate.day,
                                  _fromTime.hour,
                                  _fromTime.minute,
                                );

                                DateTime end = DateTime(
                                  _toDate.year,
                                  _toDate.month,
                                  _toDate.day,
                                  _toTime.hour,
                                  _toTime.minute,
                                );

                                if (!validateDateTime(start, end)) {
                                  return;
                                }
                                if (radius < 100) {
                                  Toast.showError(
                                      'Radius cannot be less than 100 meters');
                                  return;
                                }

                                context
                                    .read<ScheduleNotificationsBloc>()
                                    .add(CreateScheduledNotificationEvent(
                                      startsAt: DateTime(
                                        _fromDate.year,
                                        _fromDate.month,
                                        _fromDate.day,
                                        _fromTime.hour,
                                        _fromTime.minute,
                                      ),
                                      endsAt: DateTime(
                                        _toDate.year,
                                        _toDate.month,
                                        _toDate.day,
                                        _toTime.hour,
                                        _toTime.minute,
                                      ),
                                      radius: radius.toDouble(),
                                      location: widget.notification.location,
                                    ));
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => NavigationView(
                                      destinationLat: widget
                                          .notification.location.point.latitude,
                                      destinationLng: widget.notification
                                          .location.point.longitude,
                                    ),
                                  ),
                                );
                              }
                              // Schedule notification
                              // Navigator.pop(context);
                            },
                            icon:
                                !notifyAvailableSpace || isNotificationScheduled
                                    ? IconlyBold.location
                                    : null,
                            text:
                                notifyAvailableSpace && !isNotificationScheduled
                                    ? "Save"
                                    : "Start Route",
                          ),
                          Dimens.space(2)
                        ],
                ),
        );
      },
    );
  }
}

String parseMeters(double distance) {
  if (distance < 1000) {
    return "${distance.toStringAsFixed(0)}m";
  } else {
    return "${(distance / 1000).toStringAsFixed(1)}km";
  }

//   if
}

parseHours(int min) {
  if (min < 60) {
    return "$min mins";
  } else {
    return "${(min / 60).toStringAsFixed(0)} hrs";
  }
}

bool validateDateTime(DateTime? start, DateTime? end) {
  DateTime now = DateTime.now();

  if (start == null || end == null) {
    Toast.showError('Start and end times are required');
    return false;
  }

  if (start.isAfter(end) || start.isAtSameMomentAs(end)) {
    Toast.showError('Start time should be before end time');
    return false;
  }

  if (start.isBefore(now) || end.isBefore(now)) {
    Toast.showError(
        'Start and end times should be greater than the current time');
    return false;
  }

  // Ensure difference is not greater than 5 days (including milliseconds rounding)
  if (end.difference(start).inMilliseconds >
      const Duration(days: 5).inMilliseconds) {
    Toast.showError('You can only schedule up to 5 days');
    return false;
  }

  return true;
}
