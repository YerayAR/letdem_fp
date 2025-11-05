import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart' as geolocator;
import 'package:here_sdk/animation.dart' as map_animation;
import 'package:here_sdk/core.dart';
import 'package:here_sdk/mapview.dart';
import 'package:here_sdk/navigation.dart' as navigation;
import 'package:here_sdk/routing.dart' as routing;
import 'package:iconly/iconly.dart';
import 'package:intl/intl.dart';
import 'package:letdem/common/popups/date_time_picker.widget.dart';
import 'package:letdem/common/popups/popup.dart';
import 'package:letdem/common/popups/success_dialog.dart';
import 'package:letdem/common/widgets/button.dart';
import 'package:letdem/common/widgets/chip.dart';
import 'package:letdem/core/constants/colors.dart';
import 'package:letdem/core/constants/dimens.dart';
import 'package:letdem/core/constants/typo.dart';
import 'package:letdem/core/extensions/locale.dart';
import 'package:letdem/core/extensions/user.dart';
import 'package:letdem/core/utils/dates.dart';
import 'package:letdem/core/utils/parsers.dart';
import 'package:letdem/features/activities/presentation/shimmers/home_page_shimmer.widget.dart';
import 'package:letdem/features/auth/models/nearby_payload.model.dart';
import 'package:letdem/features/map/presentation/views/navigate/navigate.view.dart';
import 'package:letdem/features/scheduled_notifications/schedule_notifications_bloc.dart';
import 'package:letdem/features/users/presentation/widgets/settings_container.widget.dart';
import 'package:letdem/infrastructure/api/api/api.service.dart';
import 'package:letdem/infrastructure/api/api/endpoints.dart';
import 'package:letdem/infrastructure/services/location/location.service.dart';
import 'package:letdem/infrastructure/services/map/map_asset_provider.service.dart';
import 'package:letdem/infrastructure/services/mapbox_search/models/service.dart';
import 'package:letdem/infrastructure/services/res/navigator.dart';
import 'package:letdem/infrastructure/toast/toast/toast.dart';
import 'package:letdem/models/map/coordinate.model.dart';

class NavigationMapScreen extends StatefulWidget {
  final double? latitude;
  final double? longitude;
  final String? destinationStreetName;
  final bool hideToggle;

  final String? spaceID;
  final Space? spaceDetails;

  final Function(Space space)? onPremiumSpaceViewed;

  final String? googlePlaceID;

  const NavigationMapScreen({
    super.key,
    required this.latitude,
    this.spaceID,
    this.onPremiumSpaceViewed,
    required this.longitude,
    required this.hideToggle,
    required this.googlePlaceID,
    required this.destinationStreetName,
    this.spaceDetails,
  });

  @override
  State<NavigationMapScreen> createState() => _NavigationMapScreenState();
}

class _NavigationMapScreenState extends State<NavigationMapScreen> {
  final List<MapMarker> _mapMarkers = [];
  final List<MapPolyline> _mapPolylines = [];
  final MapAssetsProvider _assetsProvider = MapAssetsProvider();
  RouteInfo? _routeInfo;
  late geolocator.Position _currentLocation;
  routing.Route? _currentRoute;
  HereMapController? _hereMapController;
  routing.RoutingEngine? _routingEngine;
  navigation.VisualNavigator? _visualNavigator;
  bool _isLoading = true;
  List<routing.Waypoint> _waypoints = [];

  List<routing.Route> _alternativeRoutes = [];
  List<RouteInfo> _alternativeRoutesInfo = [];
  int _selectedRouteIndex = 0;

  double? _latitude;
  double? _longitude;
  String? _destinationStreetName;
  Space? _spaceDetails;

  @override
  void initState() {
    super.initState();

    print("Google Place ID: ${widget.googlePlaceID}");
    print("Space ID: ${widget.spaceID}");
    print("Latitude: ${widget.latitude}");
    print("Longitude: ${widget.longitude}");

    if (widget.latitude == null && widget.longitude == null) {
      getInfoFromSpaceID(widget.spaceID);
    } else {
      _initializeRouting();
    }
  }

  bool isError = false;

  void getInfoFromSpaceID(String? spaceID) async {
    try {
      print("Fetching space details for ID: $spaceID");
      setState(() {
        _isLoading = true;
      });

      late double _latitudeDelta;
      late double _longitudeDelta;

      if (widget.googlePlaceID != null) {
        var spaceInfo = await HereSearchApiService().getPlaceDetailsLatLng(
          widget.googlePlaceID ?? '',
        );
        if (spaceInfo != null) {
          _latitudeDelta = spaceInfo['lat'] as double;
          _longitudeDelta = spaceInfo['lng'] as double;
        }
      }

      if (spaceID != null) {
        var response = await ApiService.sendRequest(
          endpoint: EndPoints.getSpaceDetails(widget.spaceID!),
        );

        var spaceDetails = Space.fromJson(response.data);
        _latitudeDelta = spaceDetails.location.point.lat;
        _longitudeDelta = spaceDetails.location.point.lng;

        if (spaceDetails.isPremium) {
          widget.onPremiumSpaceViewed?.call(spaceDetails);
          NavigatorHelper.pop();
          return;
        }

        setState(() {
          _spaceDetails = spaceDetails;
          _destinationStreetName = spaceDetails.location.streetName;
        });
      }

      setState(() {
        _latitude = _latitudeDelta;
        _longitude = _longitudeDelta;
      });

      if (_latitude != null && _longitude != null) {
        _initializeRouting();
      } else {
        Toast.showError("Could not retrieve location data for the space.");
        throw Exception("Latitude or Longitude is null");
      }
    } catch (e, st) {
      print(st);

      setState(() {
        isError = true;
        _isLoading = false;
      });

      Toast.showError("Could not retrieve space details.");
      return;
    }
  }

  void _initializeRouting() async {
    _routingEngine = routing.RoutingEngine();
    await _loadMapData();
  }

  @override
  void dispose() {
    _visualNavigator?.stopRendering();
    _clearMapResources();
    super.dispose();
  }

  Future<void> _loadMapData() async {
    setState(() => _isLoading = true);
    try {
      await _assetsProvider.loadAssets();

      final currentPosition = await geolocator.Geolocator.getCurrentPosition();
      _currentLocation = currentPosition;

      setState(() => _isLoading = false);
    } catch (e) {
      print("Error loading map data: $e");
      setState(() => _isLoading = false);
    }
  }

  void _onMapCreated(HereMapController controller) {
    _hereMapController = controller;
    _hereMapController!.mapScene.loadSceneForMapScheme(MapScheme.normalDay, (
      error,
    ) {
      if (error != null) {
        print('Map scene loading failed: $error');
        return;
      }

      _hereMapController!.camera.lookAtPointWithMeasure(
        GeoCoordinates(_currentLocation.latitude, _currentLocation.longitude),
        MapMeasure(MapMeasureKind.distanceInMeters, 1000),
      );

      _buildRoute();
    });
  }

  Future<void> _buildRoute() async {
    _clearMapResources();

    final start = GeoCoordinates(
      _currentLocation.latitude,
      _currentLocation.longitude,
    );
    final end = GeoCoordinates(
      widget.latitude ?? _latitude!,
      widget.longitude ?? _longitude!,
    );

    _waypoints = [
      routing.Waypoint.withDefaults(start),
      routing.Waypoint.withDefaults(end),
    ];

    try {
      _calculateRoute(_waypoints);
    } catch (e) {
      print("Error building route: $e");
    }
  }

  RouteInfo retrieveRouteInfoFromHereMap() {
    final durationSeconds = _currentRoute!.duration.inSeconds;
    final trafficDelaySeconds = _currentRoute!.trafficDelay.inSeconds;

    double distanceMeters = _currentRoute!.lengthInMeters / 1;
    TrafficLevel trafficCongestion = parseTrafficCongestion(
      trafficDelaySeconds,
      durationSeconds,
    );
    int durationMinutes = (durationSeconds / 60).round();
    DateTime arrivingAt = DateTime.now().add(
      Duration(minutes: durationMinutes),
    );
    return RouteInfo(
      tafficLevel: trafficCongestion,
      distance: distanceMeters,
      duration: durationMinutes,
      arrivingAt: arrivingAt,
    );
  }

  void _calculateRoute(List<routing.Waypoint> waypoints) async {
    if (_routingEngine == null) return;

    final carOptions = routing.CarOptions();
    carOptions.routeOptions.enableTolls = true;
    carOptions.routeOptions.optimizationMode = routing.OptimizationMode.fastest;

    carOptions.routeOptions.departureTime = DateTime.now();
    carOptions.routeOptions.trafficOptimizationMode =
        routing.TrafficOptimizationMode.timeDependent;

    carOptions.routeOptions.alternatives = 3;
    _routingEngine!.calculateCarRoute(waypoints, carOptions, (
      routing.RoutingError? error,
      List<routing.Route>? routes,
    ) {
      if (error == null && routes != null && routes.isNotEmpty) {
        setState(() {
          _alternativeRoutes = routes;
          _alternativeRoutesInfo = [];

          for (var route in routes) {
            _currentRoute = route;
            _alternativeRoutesInfo.add(retrieveRouteInfoFromHereMap());
          }

          _selectedRouteIndex = 0;
          _currentRoute = routes[0];
          _routeInfo = _alternativeRoutesInfo[0];
        });

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;

          _displayAllRoutesWithTraffic();

          _addMarker(
            GeoCoordinates(
              _currentRoute!.geometry.vertices.last.latitude,
              _currentRoute!.geometry.vertices.last.longitude,
            ),
            _assetsProvider.destinationMarker,
          );
          _addMarker(
            GeoCoordinates(
              _currentRoute!.geometry.vertices.first.latitude,
              _currentRoute!.geometry.vertices.first.longitude,
            ),
            _assetsProvider.currentLocationMarker,
          );

          _zoomToRoute(_currentRoute!);
        });
      }
    });
  }

  bool _isUpdatingRoutes = false;

  void _displayAllRoutesWithTraffic() {
    if (_hereMapController == null) return;
    _isUpdatingRoutes = true;

    print('🚦 Adding all alternative routes with traffic coloring...');

    if (_mapPolylines.isNotEmpty) {
      _hereMapController!.mapScene.removeMapPolylines(_mapPolylines);
      _mapPolylines.clear();
    }

    for (
      int routeIndex = 0;
      routeIndex < _alternativeRoutes.length;
      routeIndex++
    ) {
      final route = _alternativeRoutes[routeIndex];
      final isSelected = routeIndex == _selectedRouteIndex;

      for (var section in route.sections) {
        for (var span in section.spans) {
          GeoPolyline spanGeometry = span.geometry;

          Color lineColor;
          double lineWidth;

          if (isSelected) {
            lineColor = _getTrafficColorFromSpan(span);
            lineWidth = 17;
          } else {
            lineColor = const Color.fromARGB(160, 128, 128, 128);
            lineWidth = 10;
          }

          try {
            MapPolyline polyline = MapPolyline.withRepresentation(
              spanGeometry,
              MapPolylineSolidRepresentation(
                MapMeasureDependentRenderSize.withSingleSize(
                  RenderSizeUnit.pixels,
                  lineWidth,
                ),
                lineColor,
                LineCap.round,
              ),
            );

            _hereMapController!.mapScene.addMapPolyline(polyline);
            _mapPolylines.add(polyline);
          } catch (e) {
            print('❌ Error adding traffic polyline for span: $e');
          }
        }
      }
    }

    print(
      '✅ Added ${_mapPolylines.length} traffic polylines for ${_alternativeRoutes.length} routes',
    );
    _isUpdatingRoutes = false;
  }

  void _selectRoute(int index) {
    if (index >= _alternativeRoutes.length) return;

    setState(() {
      _selectedRouteIndex = index;
      _currentRoute = _alternativeRoutes[index];
      _routeInfo = _alternativeRoutesInfo[index];
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _displayAllRoutesWithTraffic();
      _zoomToRoute(_currentRoute!);
    });
  }

  Widget _buildAlternativeRoutesSelector() {
    if (_alternativeRoutes.length <= 1) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Alternative Routes',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 90,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _alternativeRoutes.length,
              itemBuilder: (context, index) {
                final routeInfo = _alternativeRoutesInfo[index];
                final isSelected = index == _selectedRouteIndex;

                return GestureDetector(
                  onTap: () => _selectRoute(index),
                  child: Container(
                    width: 150,
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? Colors.blue.withOpacity(0.08)
                              : Colors.grey.withOpacity(0.05),
                      border: Border.all(
                        color: isSelected ? Colors.blue : Colors.grey.shade300,
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 16,
                              color:
                                  isSelected
                                      ? Colors.blue
                                      : Colors.grey.shade600,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                parseHours(context, routeInfo.duration),
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight:
                                      isSelected
                                          ? FontWeight.bold
                                          : FontWeight.w600,
                                  color:
                                      isSelected ? Colors.blue : Colors.black87,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),

                        Row(
                          children: [
                            Icon(
                              Icons.route,
                              size: 16,
                              color:
                                  isSelected
                                      ? Colors.blue
                                      : Colors.grey.shade600,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              parseMeters(routeInfo.distance),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color:
                                    isSelected
                                        ? Colors.blue.shade700
                                        : Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),

                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: _getTrafficColorForLevel(
                                  routeInfo.tafficLevel,
                                ),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                formatTrafficLevel(
                                      routeInfo.tafficLevel,
                                      context,
                                    ) ??
                                    '--',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: _getTrafficColorForLevel(
                                    routeInfo.tafficLevel,
                                  ),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Color _getTrafficColorForLevel(TrafficLevel level) {
    switch (level) {
      case TrafficLevel.low:
        return AppColors.green500;
      case TrafficLevel.moderate:
        return AppColors.neutral500;
      case TrafficLevel.heavy:
        return AppColors.red500;
      default:
        return Colors.grey;
    }
  }

  void _displayTrafficAwareRoutePolyline(routing.Route route) {
    if (_hereMapController == null) return;

    print('🚦 Adding traffic-aware route visualization...');

    if (_mapPolylines.isNotEmpty) {
      _hereMapController!.mapScene.removeMapPolylines(_mapPolylines);
      _mapPolylines.clear();
    }

    for (var section in route.sections) {
      for (var span in section.spans) {
        GeoPolyline spanGeometry = span.geometry;

        Color trafficColor = _getTrafficColorFromSpan(span);

        try {
          MapPolyline polyline = MapPolyline.withRepresentation(
            spanGeometry,
            MapPolylineSolidRepresentation(
              MapMeasureDependentRenderSize.withSingleSize(
                RenderSizeUnit.pixels,
                17,
              ),
              trafficColor,
              LineCap.round,
            ),
          );

          _hereMapController!.mapScene.addMapPolyline(polyline);
          _mapPolylines.add(polyline);
        } catch (e) {
          print('❌ Error adding traffic polyline for span: $e');
        }
      }
    }

    print('✅ Added ${_mapPolylines.length} traffic polylines');
  }

  Color _getTrafficColorFromSpan(routing.Span span) {
    if (span.duration.inSeconds > 0 && span.baseDuration.inSeconds > 0) {
      double trafficDelay =
          span.duration.inSeconds / span.baseDuration.inSeconds;

      if (trafficDelay <= 1.1) {
        return Colors.green;
      } else if (trafficDelay <= 1.3) {
        return Colors.yellow;
      } else if (trafficDelay <= 1.6) {
        return Colors.orange;
      } else {
        return Colors.red;
      }
    }

    if (span.dynamicSpeedInfo != null) {
      final speedInfo = span.dynamicSpeedInfo!;

      if (speedInfo.trafficSpeedInMetersPerSecond != null &&
          speedInfo.baseSpeedInMetersPerSecond != null) {
        double speedRatio =
            speedInfo.trafficSpeedInMetersPerSecond! /
            speedInfo.baseSpeedInMetersPerSecond!;

        if (speedRatio >= 0.8) {
          return Colors.green;
        } else if (speedRatio >= 0.6) {
          return Colors.yellow;
        } else if (speedRatio >= 0.4) {
          return Colors.orange;
        } else {
          return Colors.red;
        }
      }
    }

    return const Color(0xFF4A90E2);
  }

  void _zoomToRoute(routing.Route route) {
    if (_hereMapController == null) return;

    try {
      final update =
          MapCameraUpdateFactory.lookAtAreaWithGeoOrientationAndViewRectangle(
            route.boundingBox,
            GeoOrientationUpdate(0, 0),
            Rectangle2D(
              Point2D(50, 50),
              Size2D(
                _hereMapController!.viewportSize.width - 100,
                _hereMapController!.viewportSize.height - 100,
              ),
            ),
          );

      final animation =
          MapCameraAnimationFactory.createAnimationFromUpdateWithEasing(
            update,
            const Duration(seconds: 2),
            map_animation.Easing(map_animation.EasingFunction.inCubic),
          );

      _hereMapController!.camera.startAnimation(animation);
    } catch (e) {
      print("Error zooming to route: $e");
    }
  }

  void _addMarker(GeoCoordinates coordinates, Uint8List icon) {
    if (_hereMapController == null) return;

    try {
      final marker = MapMarker(
        coordinates,
        MapImage.withPixelDataAndImageFormat(icon, ImageFormat.png),
      );
      _hereMapController!.mapScene.addMapMarker(marker);
      _mapMarkers.add(marker);
    } catch (e) {
      print("Marker addition failed: $e");
    }
  }

  void _clearMapResources() {
    _mapMarkers.forEach(_hereMapController!.mapScene.removeMapMarker);
    _mapMarkers.clear();

    _mapPolylines.forEach(_hereMapController!.mapScene.removeMapPolyline);
    _mapPolylines.clear();
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
              icon: const Icon(Icons.close, size: 20),
              onPressed: () => NavigatorHelper.pop(),
            ),
          ),
          Dimens.space(2),
        ],
      ),
      body:
          isError
              ? SizedBox(
                child: Center(
                  child: Text(
                    "Could not retrieve location data for the space.",
                    style: Typo.largeBody.copyWith(color: Colors.red),
                  ),
                ),
              )
              : Stack(
                children: [
                  Positioned.fill(
                    child:
                        _isLoading
                            ? const Center(child: CupertinoActivityIndicator())
                            : HereMap(onMapCreated: _onMapCreated),
                  ),

                  Positioned(
                    left: 0,
                    bottom: 0,
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child:
                          _isLoading ||
                                  _routingEngine == null ||
                                  _routeInfo == null
                              ? Container(
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(16),
                                  ),
                                ),
                                child: const HomePageShimmer(),
                              )
                              : Column(
                                children: [
                                  NavigateNotificationCard(
                                    selectedRoute:
                                        _alternativeRoutes[_selectedRouteIndex],
                                    alt: _buildAlternativeRoutesSelector(),

                                    spaceInfo:
                                        widget.spaceDetails ?? _spaceDetails,
                                    hideToggle: widget.hideToggle,
                                    routeInfo: _routeInfo!,
                                    notification: ScheduledNotification(
                                      id: "1",
                                      startsAt: DateTime.now(),
                                      endsAt: DateTime.now(),
                                      isExpired: false,
                                      location: LocationData(
                                        streetName:
                                            widget.destinationStreetName ??
                                            _destinationStreetName ??
                                            '',
                                        point: CoordinatesData(
                                          latitude:
                                              widget.latitude ?? _latitude!,
                                          longitude:
                                              widget.longitude ?? _longitude!,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                    ),
                  ),
                ],
              ),
    );
  }
}

class NavigateNotificationCard extends StatefulWidget {
  final ScheduledNotification notification;
  final RouteInfo? routeInfo;
  final Widget alt;
  final bool hideToggle;
  final Space? spaceInfo;
  final routing.Route selectedRoute;

  const NavigateNotificationCard({
    super.key,
    required this.notification,
    required this.hideToggle,
    required this.routeInfo,
    required this.alt,
    required this.selectedRoute,
    this.spaceInfo,
  });

  @override
  State<NavigateNotificationCard> createState() =>
      _NavigateNotificationCardState();
}

class _NavigateNotificationCardState extends State<NavigateNotificationCard> {
  bool notifyAvailableSpace = false;
  bool isNotificationScheduled = false;
  bool isLocationAvailable = false;

  double radius = 100;
  TimeOfDay _fromTime = TimeOfDay.now();
  TimeOfDay _toTime = TimeOfDay.now();
  DateTime _fromDate = DateTime.now();
  DateTime _toDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ScheduleNotificationsBloc, ScheduleNotificationsState>(
      listener: (context, state) {
        if (state is ScheduleNotificationCreated) {
          setState(() => isNotificationScheduled = true);
          AppPopup.showDialogSheet(
            context,
            SuccessDialog(
              title: context.l10n.notificationScheduled,
              subtext: context.l10n.notificationScheduledDescription,
              onProceed: () => Navigator.pop(context),
            ),
          );
        }
      },
      builder: (context, state) {
        final routeInfo = widget.routeInfo;
        final location = widget.notification.location;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                spreadRadius: 1,
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: _buildContent(context, routeInfo, location, state),
        );
      },
    );
  }

  Widget _buildContent(
    BuildContext context,
    RouteInfo? routeInfo,
    LocationData location,
    ScheduleNotificationsState state,
  ) {
    if (routeInfo!.distance <
        context.userProfile!.constantsSettings.metersToShowTooCloseModal) {
      return _buildTooCloseMessage();
    }

    if (isLocationAvailable) {
      return const SizedBox(
        height: 100,
        child: Center(child: CupertinoActivityIndicator()),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRouteDetails(routeInfo),
        const SizedBox(height: 22),
        widget.alt,
        _buildLocationInfo(location, widget.spaceInfo),
        const SizedBox(height: 16),
        _buildArrivalInfo(routeInfo),
        const SizedBox(height: 16),
        Divider(color: Colors.grey.withValues(alpha: 0.2)),
        const SizedBox(height: 16),
        _buildNotificationOptions(),
        const SizedBox(height: 24),
        _buildPrimaryActionButton(state),
        Dimens.space(2),
      ],
    );
  }

  Widget _buildTooCloseMessage() {
    return Padding(
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
          Text(
            context.l10n.tooCloseToLocation,
            style: Typo.heading4,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.closeToLocationDescription(
              context.userProfile!.constantsSettings.metersToShowTooCloseModal,
            ),
            style: Typo.mediumBody,
            textAlign: TextAlign.center,
          ),
          Dimens.space(4),
          PrimaryButton(
            onTap: () => Navigator.pop(context),
            text: context.l10n.close,
          ),
          Dimens.space(4),
        ],
      ),
    );
  }

  Widget _buildRouteDetails(RouteInfo? routeInfo) {
    return Row(
      children: [
        Text(
          "${parseHours(context, routeInfo!.duration)} (${parseMeters(routeInfo!.distance)})",
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const Spacer(),
        Row(
          children: [
            Text(
              context.l10n.trafficLevel,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 8),
            DecoratedChip(
              text: formatTrafficLevel(routeInfo.tafficLevel, context) ?? "--",
              textStyle: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color:
                    routeInfo.tafficLevel == TrafficLevel.low
                        ? AppColors.green500
                        : routeInfo.tafficLevel == TrafficLevel.moderate
                        ? AppColors.neutral500
                        : AppColors.red500,
              ),

              color:
                  routeInfo.tafficLevel == TrafficLevel.low
                      ? AppColors.green500
                      : routeInfo.tafficLevel == TrafficLevel.moderate
                      ? AppColors.neutral500
                      : AppColors.red500,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLocationInfo(LocationData location, Space? spaceInfo) {
    return Row(
      children: [
        const Icon(IconlyLight.location, color: Colors.grey),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            location.streetName.isNotEmpty
                ? location.streetName
                : spaceInfo!.location.streetName ?? '',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  Widget _buildArrivalInfo(RouteInfo? routeInfo) {
    return Row(
      children: [
        const Icon(IconlyLight.time_circle, color: Colors.grey),
        const SizedBox(width: 8),
        Text(
          context.l10n.toArriveBy(
            DateFormat('HH:mm').format(routeInfo!.arrivingAt.toLocal()),
          ),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildNotificationOptions() {
    if (isNotificationScheduled || widget.hideToggle) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        Row(
          children: [
            const Icon(IconlyLight.notification, color: Colors.grey),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                context.l10n.notifyAvailableSpace,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ToggleSwitch(
              value: notifyAvailableSpace,
              onChanged:
                  (value) => setState(() => notifyAvailableSpace = value),
            ),
          ],
        ),
        if (notifyAvailableSpace) _buildNotificationForm(),
      ],
    );
  }

  Widget _buildNotificationForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(color: Colors.grey.withOpacity(0.2)),
        Dimens.space(1),
        Text(context.l10n.dateAndTime),
        Dimens.space(3),
        Row(
          children: [
            PlatformDatePickerButton(
              initialDate: _fromDate,
              onDateSelected: (date) => setState(() => _fromDate = date),
            ),
            Dimens.space(1),
            PlatformTimePickerButton(
              initialTime: _fromTime,
              onTimeSelected: (time) => setState(() => _fromTime = time),
            ),
          ],
        ),
        Row(
          children: [
            Dimens.space(5),
            Flexible(child: Divider(color: Colors.grey.withOpacity(0.2))),
            Dimens.space(1),
            Text(
              context.l10n.toDate,
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
            Dimens.space(1),
            Flexible(child: Divider(color: Colors.grey.withOpacity(0.2))),
            Dimens.space(5),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            PlatformDatePickerButton(
              initialDate: _toDate,
              onDateSelected: (date) => setState(() => _toDate = date),
            ),
            Dimens.space(1),
            PlatformTimePickerButton(
              initialTime: _toTime,
              onTimeSelected: (time) => setState(() => _toTime = time),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildRadiusSlider(),
      ],
    );
  }

  Widget _buildRadiusSlider() {
    return Column(
      children: [
        Row(
          children: [
            Text(
              context.l10n.notificationRadius,
              style: const TextStyle(fontSize: 14),
            ),
            const Spacer(),
            Text(
              radius.toStringAsFixed(0),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: Colors.purple,
            inactiveTrackColor: Colors.purple.withOpacity(0.2),
            thumbColor: Colors.white,
            overlayColor: Colors.purple.withOpacity(0.2),
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
          ),
          child: Slider(
            value: radius,
            min: 100,
            max: 9000,
            divisions: 89,
            onChanged: (value) {
              final roundedValue = (value / 100).round() * 100;
              setState(() => radius = roundedValue.toDouble());
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPrimaryActionButton(ScheduleNotificationsState state) {
    final isLoading = state is ScheduleNotificationsLoading;
    final shouldSchedule = notifyAvailableSpace && !isNotificationScheduled;

    return PrimaryButton(
      isLoading: isLoading,
      onTap:
          () =>
              shouldSchedule
                  ? _handleScheduleNotification()
                  : _navigateToDestination(),
      icon: !shouldSchedule ? IconlyBold.location : null,
      text: shouldSchedule ? context.l10n.save : context.l10n.startRoute,
    );
  }

  void _handleScheduleNotification() {
    final start = DateTime(
      _fromDate.year,
      _fromDate.month,
      _fromDate.day,
      _fromTime.hour,
      _fromTime.minute,
    );
    final end = DateTime(
      _toDate.year,
      _toDate.month,
      _toDate.day,
      _toTime.hour,
      _toTime.minute,
    );

    if (!validateDateTime(context, start, end)) return;
    if (radius < 100) {
      Toast.showError(context.l10n.radiusLessThan(100));
      return;
    }

    context.read<ScheduleNotificationsBloc>().add(
      CreateScheduledNotificationEvent(
        startsAt: start,
        endsAt: end,
        radius: radius,
        location: widget.notification.location,
      ),
    );
  }

  void _navigateToDestination() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => NavigationView(
              parkingSpaceID: widget.spaceInfo?.id,
              isNavigatingToParking: widget.spaceInfo != null,
              destinationLat: widget.notification.location.point.latitude,
              destinationLng: widget.notification.location.point.longitude,
              preCalculatedRoute: widget.selectedRoute,
            ),
      ),
    );
  }
}
