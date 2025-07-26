import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart' as geolocator;
import 'package:here_sdk/core.dart';
import 'package:here_sdk/gestures.dart';
import 'package:here_sdk/location.dart';
import 'package:here_sdk/mapview.dart';
import 'package:letdem/core/constants/colors.dart';
import 'package:letdem/core/extensions/user.dart';
import 'package:letdem/features/activities/presentation/modals/space.popup.dart';
import 'package:letdem/features/activities/presentation/shimmers/home_bottom_section.widget.dart';
import 'package:letdem/features/activities/presentation/shimmers/home_page_shimmer.widget.dart';
import 'package:letdem/features/activities/presentation/shimmers/no_connection.widget.dart';
import 'package:letdem/features/auth/models/map_options.model.dart';
import 'package:letdem/features/auth/models/nearby_payload.model.dart'
    hide Location;
import 'package:letdem/features/map/map_bloc.dart';
import 'package:letdem/features/map/presentation/widgets/navigation/event_feedback.widget.dart';
import 'package:letdem/infrastructure/services/notification/notification.service.dart';
import 'package:letdem/infrastructure/ws/web_socket.service.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import '../../../../common/popups/popup.dart';
import '../../../../infrastructure/services/map/map_asset_provider.service.dart';

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
  bool _isFollowingLocation = true; // Track if we should follow user location
  bool _isUserInteracting =
      false; // Track if user is manually interacting with map

  late LocationEngine _locationEngine;
  LocationIndicator? _locationIndicator;
  LocationListener? _locationListener;

  static const double TRIGGER_DISTANCE_METERS = 200.0;

  // ---------------------------------------------------------------------------
  // Refresh Button State
  // ---------------------------------------------------------------------------
  bool _showRefreshButton = false;
  // Timer? _refreshButtonTimer;
  GeoCoordinates? _lastCameraPosition;
  static const Duration _refreshButtonHideDuration = Duration(seconds: 3);

  // ---------------------------------------------------------------------------
  // Marker & Asset State
  // ---------------------------------------------------------------------------
  final MapAssetsProvider _assetsProvider = MapAssetsProvider();

  MapMarker? _currentLocationMarker;
  final Map<MapMarker, Space> _spaceMarkers = {};
  final Map<MapMarker, Event> _eventMarkers = {};

  late LocationWebSocketService _locationWebSocketService;

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------
  @override
  void initState() {
    super.initState();
    _loadAssets();
    _getCurrentLocation();

    OneSignal.Notifications.addClickListener((event) {
      final data = event.notification.additionalData;
      final handler = NotificationHandler(context);

      handler.handleNotification(data);
    });
    OneSignal.Notifications.addForegroundWillDisplayListener(
      (event) {
        event.preventDefault();

        // Extract title and body
        final data = event.notification.additionalData;

        if (data != null && data['page_to_redirect'] != null) {
          if (data['page_to_redirect'] == 'wallet') {
            context.loadUser();
          }
        }

        // Handle in-app messages if needed
      },
    );
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
    // _refreshButtonTimer?.cancel();
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

  initializeWebSocketService() {
    _locationWebSocketService = LocationWebSocketService();
    _locationWebSocketService.connectAndSendInitialLocation(
      latitude: _currentPosition?.latitude ?? 37.3318,
      longitude: _currentPosition?.longitude ?? -122.0312,
      onEvent: (event) {
        var payload = event;
        _addMapMarkers(payload.spaces!, payload.events!);
        // Handle incoming WebSocket events if needed
        debugPrint("WebSocket event received: $event");
      },
      onDone: () {
        debugPrint("WebSocket connection closed.");
      },
      onError: (error) {
        debugPrint("WebSocket error: $error");
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Refresh Button Logic
  // ---------------------------------------------------------------------------
  // void _showRefreshButtonTemporarily() {
  //   // _refreshButtonTimer?.cancel();
  //
  //   if (!_showRefreshButton) {
  //     setState(() => _showRefreshButton = true);
  //   }
  //
  //   _refreshButtonTimer = Timer(_refreshButtonHideDuration, () {
  //     if (mounted) {
  //       setState(() => _showRefreshButton = false);
  //     }
  //   });
  // }
  //
  // void _hideRefreshButton() {
  //   _refreshButtonTimer?.cancel();
  //   if (_showRefreshButton) {
  //     setState(() => _showRefreshButton = false);
  //   }
  // }

  void _onCameraPositionChanged(GeoCoordinates newPosition) {
    // Only show refresh button if map was manually moved (not by location updates)
    // if (_lastCameraPosition != null) {
    //   // final distance = geolocator.Geolocator.distanceBetween(
    //   //   _lastCameraPosition!.latitude,
    //   //   _lastCameraPosition!.longitude,
    //   //   newPosition.latitude,
    //   //   newPosition.longitude,
    //   );

    // Show refresh button if camera moved more than 10 meters
    // if (distance > 10) {
    //   _showRefreshButtonTemporarily();
    // }
    // }
    _lastCameraPosition = newPosition;
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
      initializeWebSocketService();

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

        // Auto-align map to current location if following mode is enabled
        if (_isFollowingLocation &&
            !_isUserInteracting &&
            _mapController != null) {
          _mapController!.camera.lookAtPoint(location.coordinates);
          _lastCameraPosition = location.coordinates;
        }

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
      _lastCameraPosition = myLocation.coordinates;
    }
  }

  // ---------------------------------------------------------------------------
  // Location Following Control
  // ---------------------------------------------------------------------------
  void _enableLocationFollowing() {
    setState(() {
      _isFollowingLocation = true;
    });
    if (_currentPosition != null && _mapController != null) {
      _mapController!.camera.lookAtPoint(_currentPosition!);
      _lastCameraPosition = _currentPosition;
      // _hideRefreshButton();
    }
  }

  // ---------------------------------------------------------------------------
  // Data Fetching
  // ---------------------------------------------------------------------------
  void _fetchNearbyPlaces(GeoCoordinates position) {
    _lastFetchPosition = position;
    _locationWebSocketService.sendLocation(
        position.latitude, position.longitude);
  }

  void _onRefreshPressed() {
    if (_mapController != null) {
      final cameraPosition = _mapController!.camera.state.targetCoordinates;
      _fetchNearbyPlaces(cameraPosition);
      // _hideRefreshButton();
    }
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

    // Add pan gesture listener to detect map movement
    _mapController!.gestures.panListener = PanListener(
      (GestureState state, Point2D origin, Point2D translation,
          double velocity) {
        if (state == GestureState.begin) {
          // User started interacting with map - disable auto-follow
          setState(() {
            _isUserInteracting = true;
            _isFollowingLocation = false;
          });
        } else if (state == GestureState.end) {
          setState(() {
            _isUserInteracting = false;
          });
          // Get current camera position when pan ends
          final currentCameraPosition =
              _mapController!.camera.state.targetCoordinates;
          _onCameraPositionChanged(currentCameraPosition);
        }
      },
    );
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
      _lastCameraPosition = target;

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
                  // if (state is MapLoaded && _mapController != null) {
                  //   _addMapMarkers(state.payload.spaces, state.payload.events);
                  // }
                },
                builder: (context, state) {
                  return Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      _currentPosition != null
                          ? HereMap(onMapCreated: _onMapCreated)
                          : const Center(child: CircularProgressIndicator()),
                      HomeMapBottomSection(
                        onRefreshTriggered: () {
                          if (_currentPosition != null) {
                            // context.read<MapBloc>().add(GetNearbyPlaces(
                            //       queryParams: MapQueryParams(
                            //         currentPoint:
                            //             "${_currentPosition!.latitude},${_currentPosition!.longitude}",
                            //         radius: 8000,
                            //         drivingMode: false,
                            //         options: ['spaces', 'events'],
                            //       ),
                            //     ));
                          }
                        },
                      ),
                      // Refresh chip on top - only shown when map is moved
                      if (_showRefreshButton)
                        Positioned(
                          top: 10,
                          child: SafeArea(
                            child: Center(
                              child: AnimatedOpacity(
                                opacity: _showRefreshButton ? 1.0 : 0.0,
                                duration: const Duration(milliseconds: 300),
                                child: GestureDetector(
                                  onTap: _onRefreshPressed,
                                  child: FittedBox(
                                    child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.grey.withOpacity(0.5),
                                              spreadRadius: 1,
                                              blurRadius: 7,
                                              offset: const Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 10),
                                        child: Row(
                                          children: [
                                            Icon(Icons.refresh,
                                                color: AppColors.primary500,
                                                size: 17),
                                            const SizedBox(width: 4),
                                            Text(
                                              "Refresh",
                                              style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        )),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      // My Location button - shown when not following location
                      if (!_isFollowingLocation && _currentPosition != null)
                        Positioned(
                          bottom:
                              265, // Adjust based on your bottom section height
                          right: 16,
                          child: FloatingActionButton(
                            mini: true,
                            onPressed: _enableLocationFollowing,
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.primary500,
                            elevation: 4,
                            child: Icon(Icons.my_location, size: 20),
                          ),
                        ),
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
      EventFeedback(event: event, currentDistance: _distanceToEvent(event)),
    );
  }

  double _distanceToEvent(Event event) {
    if (_currentPosition == null) return 0.0;

    final eventCoords = GeoCoordinates(
      event.location.point.lat,
      event.location.point.lng,
    );
    return geolocator.Geolocator.distanceBetween(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      eventCoords.latitude,
      eventCoords.longitude,
    );
  }

  showSpacePopup({
    required Space space,
  }) {
    AppPopup.showBottomSheet(
      context,
      SpacePopupSheet(
        space: space,
        currentPosition: _currentPosition!,
        onRefreshTrigger: () {
          if (_currentPosition != null) {
            context.read<MapBloc>().add(GetNearbyPlaces(
                  queryParams: MapQueryParams(
                    currentPoint:
                        "${_currentPosition!.latitude},${_currentPosition!.longitude}",
                    radius: 8000,
                    drivingMode: false,
                    options: ['spaces', 'events'],
                  ),
                ));
          }
        },
      ),
    );
  }
}
