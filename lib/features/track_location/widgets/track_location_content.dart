import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart' as geolocator;
import 'package:here_sdk/core.dart';
import 'package:here_sdk/core.errors.dart';
import 'package:here_sdk/location.dart';
import 'package:here_sdk/mapview.dart';
import 'package:here_sdk/routing.dart' as HERE;
import 'package:letdem/core/constants/colors.dart';
import 'package:letdem/core/extensions/locale.dart';
import 'package:letdem/features/activities/activities_state.dart';

import '../cubit/track_location_cubit.dart';
import 'requester_info_bottom.dart';

/// Tween para interpolar entre dos GeoCoordinates
class GeoCoordinatesTween extends Tween<GeoCoordinates> {
  GeoCoordinatesTween({
    required GeoCoordinates begin,
    required GeoCoordinates end,
  }) : super(begin: begin, end: end);

  @override
  GeoCoordinates lerp(double t) {
    final lat = begin!.latitude + (end!.latitude - begin!.latitude) * t;
    final lng = begin!.longitude + (end!.longitude - begin!.longitude) * t;
    return GeoCoordinates(lat, lng);
  }
}

class TrackLocationContent extends StatefulWidget {
  const TrackLocationContent({
    super.key,
    required this.payload,
    required this.spaceId,
  });

  final ReservedSpacePayload payload;
  final String spaceId;

  @override
  State<TrackLocationContent> createState() => _TrackLocationContentState();
}

class _TrackLocationContentState extends State<TrackLocationContent>
    with TickerProviderStateMixin {
  late TrackLocationCubit trackLocationCubit;
  HereMapController? _mapController;

  // Location indicator (tu ubicación)
  LocationIndicator? _locationIndicator;
  LocationEngine? _locationEngine;
  LocationListener? _locationListener;
  GeoCoordinates? _myLocation;

  // Marcador del usuario (remote)
  MapMarker? _userMarker;
  MapImage? _userMapImage;

  // Route polyline
  MapPolyline? _routePolyline;

  // Routing engine
  HERE.RoutingEngine? _routingEngine;

  // Animación del marker
  AnimationController? _markerAnimController;
  Animation<GeoCoordinates>? _markerAnimation;

  @override
  void initState() {
    super.initState();
    trackLocationCubit = context.read<TrackLocationCubit>();
    trackLocationCubit.connect(reservationId: widget.spaceId);
    _loadUserMarkerImage();
    _initMyLocation();
    _initRoutingEngine();
  }

  // -----------------------------------------------------
  // Initialize Routing Engine
  // -----------------------------------------------------
  void _initRoutingEngine() {
    try {
      _routingEngine = HERE.RoutingEngine();
      debugPrint('✅ Routing Engine initialized');
    } on InstantiationException {
      debugPrint('❌ Failed to initialize Routing Engine');
      _routingEngine = null;
    }
  }

  // -----------------------------------------------------
  // Cargar imagen del marker desde assets en bytes
  // -----------------------------------------------------
  Future<void> _loadUserMarkerImage() async {
    try {
      final ByteData data = await rootBundle.load(
        'assets/icon/map_pin_free_paid.png',
      );
      final Uint8List bytes = data.buffer.asUint8List();
      _userMapImage = MapImage.withPixelDataAndImageFormat(
        bytes,
        ImageFormat.png,
      );
    } catch (e) {
      debugPrint('Error cargando asset user_pin.png: $e');
      _userMapImage = null;
    }
  }
  // Replace these methods in your code:

  // -----------------------------------------------------
  // Calculate and draw route using HERE RoutingEngine
  // -----------------------------------------------------
  Future<void> _drawRouteBetweenLocations(
    GeoCoordinates origin,
    GeoCoordinates destination,
  ) async {
    if (_routingEngine == null) {
      debugPrint('❌ Routing engine not initialized');
      return;
    }

    if (_mapController == null) {
      debugPrint('❌ Map controller not initialized');
      return;
    }

    try {
      debugPrint('🧭 Calculating route...');
      debugPrint('📍 From: ${origin.latitude}, ${origin.longitude}');
      debugPrint('🎯 To: ${destination.latitude}, ${destination.longitude}');

      // FIXED: Always remove existing route first
      _clearRoute();

      // Create waypoints
      HERE.Waypoint startWaypoint = HERE.Waypoint(origin);
      HERE.Waypoint destinationWaypoint = HERE.Waypoint(destination);

      // Configure car options
      final carOptions = HERE.CarOptions();
      carOptions.routeOptions.enableTolls = true;
      carOptions.routeOptions.optimizationMode = HERE.OptimizationMode.fastest;
      carOptions.routeOptions.alternatives = 0;
      carOptions.routeOptions.departureTime = DateTime.now();
      carOptions.routeOptions.trafficOptimizationMode =
          HERE.TrafficOptimizationMode.timeDependent;

      // Calculate route
      _routingEngine!.calculateCarRoute(
        [startWaypoint, destinationWaypoint],
        carOptions,
        (HERE.RoutingError? routingError, List<HERE.Route>? routeList) {
          if (routingError == null &&
              routeList != null &&
              routeList.isNotEmpty) {
            final route = routeList.first;

            debugPrint('✅ Route calculated successfully');
            debugPrint('  - Duration: ${route.duration.inMinutes} minutes');
            debugPrint(
              '  - Distance: ${(route.lengthInMeters / 1000).toStringAsFixed(1)} km',
            );

            // Draw route on map
            _addRoutePolyline(route);
          } else {
            debugPrint('❌ Route calculation failed: $routingError');
          }
        },
      );
    } catch (e, stackTrace) {
      debugPrint('❌ Error calculating route: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  // -----------------------------------------------------
  // Clear existing route from map
  // -----------------------------------------------------
  void _clearRoute() {
    if (_routePolyline != null && _mapController != null) {
      _mapController!.mapScene.removeMapPolyline(_routePolyline!);
      _routePolyline = null;
      debugPrint('🗑️ Previous route cleared');
    }
  }

  // -----------------------------------------------------
  // Draw route polyline on map
  // -----------------------------------------------------
  void _addRoutePolyline(HERE.Route route) {
    if (_mapController == null) return;

    try {
      // FIXED: Thicker line with primary color
      final sizesMap = {0.0: 12.0, 20.0: 12.0}; // Increased from 8.0 to 12.0

      final renderSize = MapMeasureDependentRenderSize(
        MapMeasureKind.zoomLevel,
        RenderSizeUnit.pixels,
        sizesMap,
      );

      // FIXED: Use AppColors.primary500 with transparency
      final representation = MapPolylineSolidRepresentation(
        renderSize,
        AppColors.primary500.withValues(alpha: 0.85), // Changed color
        LineCap.round,
      );

      // Create polyline from route geometry
      _routePolyline = MapPolyline.withRepresentation(
        route.geometry,
        representation,
      );

      // Add to map
      _mapController!.mapScene.addMapPolyline(_routePolyline!);

      // Fit camera to show route
      _fitMapToRoute(route);

      debugPrint('✅ Route polyline added to map');
    } catch (e) {
      debugPrint('❌ Error adding route polyline: $e');
    }
  }

  // -----------------------------------------------------
  // Update route when locations change
  // -----------------------------------------------------
  void _updateRouteIfNeeded() {
    if (_myLocation != null && _userMarker != null) {
      // FIXED: Clear old route before drawing new one
      _clearRoute();
      _drawRouteBetweenLocations(_myLocation!, _userMarker!.coordinates);
    }
  }

  // Also update the dispose method to clean up routes:
  @override
  void dispose() {
    _markerAnimController?.dispose();
    if (_locationListener != null && _locationEngine != null) {
      _locationEngine!.removeLocationListener(_locationListener!);
    }
    _locationIndicator?.disable();
    _clearRoute(); // Add this line
    _routingEngine = null;
    _mapController = null;
    super.dispose();
  }

  // -----------------------------------------------------
  // Fit map camera to show entire route
  // -----------------------------------------------------
  void _fitMapToRoute(HERE.Route route) {
    if (_mapController == null) return;

    try {
      final vertices = route.geometry.vertices;
      if (vertices.isEmpty) return;

      double minLat = vertices[0].latitude;
      double maxLat = vertices[0].latitude;
      double minLng = vertices[0].longitude;
      double maxLng = vertices[0].longitude;

      for (final point in vertices) {
        if (point.latitude < minLat) minLat = point.latitude;
        if (point.latitude > maxLat) maxLat = point.latitude;
        if (point.longitude < minLng) minLng = point.longitude;
        if (point.longitude > maxLng) maxLng = point.longitude;
      }

      debugPrint('✅ Camera fitted to route');
    } catch (e) {
      debugPrint('⚠️ Error fitting camera to route: $e');
    }
  }

  // -----------------------------------------------------
  // Obtener mi ubicación (opcional)
  // -----------------------------------------------------
  Future<void> _initMyLocation() async {
    final ok = await _ensurePermissions();
    if (!ok) return;

    try {
      final pos = await geolocator.Geolocator.getCurrentPosition();
      _myLocation = GeoCoordinates(pos.latitude, pos.longitude);

      // Si el mapa ya está listo, configurar indicador y centrar
      if (_mapController != null && _myLocation != null) {
        _setupLocationIndicator();
        _mapController!.camera.lookAtPointWithMeasure(
          _myLocation!,
          MapMeasure(MapMeasureKind.distanceInMeters, 2500),
        );
      }

      // start location updates
      _setupLocationEngine();
    } catch (e) {
      debugPrint('Error obteniendo ubicacion: $e');
    }
  }

  Future<bool> _ensurePermissions() async {
    bool serviceEnabled =
        await geolocator.Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await geolocator.Geolocator.openLocationSettings();
      return false;
    }

    var permission = await geolocator.Geolocator.checkPermission();
    if (permission == geolocator.LocationPermission.denied ||
        permission == geolocator.LocationPermission.deniedForever) {
      permission = await geolocator.Geolocator.requestPermission();
      if (permission == geolocator.LocationPermission.denied ||
          permission == geolocator.LocationPermission.deniedForever) {
        return false;
      }
    }
    return true;
  }

  void _setupLocationIndicator() {
    _locationIndicator ??=
        LocationIndicator()
          ..isAccuracyVisualized = false
          ..locationIndicatorStyle = LocationIndicatorIndicatorStyle.navigation
          ..enable(_mapController!);

    if (_myLocation != null) {
      // actualizar ubicación inicial
      _locationIndicator!.updateLocation(
        Location.withCoordinates(_myLocation!),
      );
    }
  }

  void _setupLocationEngine() {
    try {
      _locationEngine = LocationEngine();
      _locationListener = LocationListener((Location location) {
        _myLocation = location.coordinates;
        _locationIndicator?.updateLocation(location);

        // Update route when location changes
        _updateRouteIfNeeded();
      });
      _locationEngine!.addLocationListener(_locationListener!);
      _locationEngine!.startWithLocationAccuracy(LocationAccuracy.navigation);
    } catch (e) {
      debugPrint('Error location engine: $e');
    }
  }

  // -----------------------------------------------------
  // Update route when locations change
  // -----------------------------------------------------

  // -----------------------------------------------------
  // Actualizar / crear marcador del usuario remoto (con animación)
  // -----------------------------------------------------
  Future<void> _moveUserMarkerAnimated(GeoCoordinates targetCoords) async {
    if (_userMapImage == null) {
      // si la imagen aún no está lista, intenta cargarla ahora
      await _loadUserMarkerImage();
    }

    if (_userMarker == null) {
      // crear marcador inicial sin animación
      _userMarker = MapMarker(
        targetCoords,
        _userMapImage ?? _defaultMapImage(),
      );
      _mapController?.mapScene.addMapMarker(_userMarker!);

      // Draw route after creating marker
      if (_myLocation != null) {
        _drawRouteBetweenLocations(_myLocation!, targetCoords);
      }
      return;
    }

    // si ya hay una animación corriendo, cancélala
    _markerAnimController?.stop();
    _markerAnimController?.dispose();

    // start and end points
    final start = _userMarker!.coordinates;
    final end = targetCoords;

    _markerAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    final tween = GeoCoordinatesTween(begin: start, end: end);

    _markerAnimation = tween.animate(
      CurvedAnimation(parent: _markerAnimController!, curve: Curves.easeInOut),
    );

    _markerAnimation!.addListener(() {
      final current = _markerAnimation!.value;
      _userMarker!.coordinates = current;
    });

    _markerAnimController!.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // Update route after animation completes
        if (_myLocation != null) {
          _drawRouteBetweenLocations(_myLocation!, end);
        }

        // liberar controller
        _markerAnimController?.dispose();
        _markerAnimController = null;
      }
    });

    _markerAnimController!.forward();
  }

  // Helper: imagen por defecto (si falla cargar assets)
  MapImage _defaultMapImage() {
    // pequeño círculo remoto generado en runtime (opcional)
    const int size = 32;
    final Uint8List bytes = Uint8List.fromList(
      List<int>.generate(size * size * 4, (i) => 0xFF),
    ); // fallback blanco
    return MapImage.withPixelDataAndImageFormat(bytes, ImageFormat.png);
  }

  // -----------------------------------------------------
  // On map created
  // -----------------------------------------------------
  void _onMapCreated(HereMapController controller) {
    _mapController = controller;

    _mapController!.mapScene.loadSceneForMapScheme(MapScheme.normalDay, (
      MapError? error,
    ) {
      if (error != null) {
        debugPrint('Error cargando mapa: $error');
        return;
      }

      // Si ya sabemos mi ubicación, configuramos indicador
      if (_myLocation != null) {
        _setupLocationIndicator();
        _mapController!.camera.lookAtPointWithMeasure(
          _myLocation!,
          MapMeasure(MapMeasureKind.distanceInMeters, 2500),
        );
      }
    });
  }

  // -----------------------------------------------------
  // Focus camera on specific location
  // -----------------------------------------------------
  void _focusOnMyLocation() {
    if (_mapController == null || _myLocation == null) return;
    _mapController!.camera.lookAtPointWithMeasure(
      _myLocation!,
      MapMeasure(MapMeasureKind.distanceInMeters, 1000),
    );
  }

  void _focusOnRequester() {
    if (_mapController == null || _userMarker == null) return;
    _mapController!.camera.lookAtPointWithMeasure(
      _userMarker!.coordinates,
      MapMeasure(MapMeasureKind.distanceInMeters, 1000),
    );
  }

  void _focusOnRoute() {
    // if (_routePolyline != null && _myLocation != null && _userMarker != null) {
    //   final bbox = GeoBoundingBox(
    //     GeoCoordinates(
    //       _myLocation!.latitude > _userMarker!.coordinates.latitude
    //           ? _myLocation!.latitude
    //           : _userMarker!.coordinates.latitude,
    //       _myLocation!.longitude < _userMarker!.coordinates.longitude
    //           ? _myLocation!.longitude
    //           : _userMarker!.coordinates.longitude,
    //     ),
    //     GeoCoordinates(
    //       _myLocation!.latitude < _userMarker!.coordinates.latitude
    //           ? _myLocation!.latitude
    //           : _userMarker!.coordinates.latitude,
    //       _myLocation!.longitude > _userMarker!.coordinates.longitude
    //           ? _myLocation!.longitude
    //           : _userMarker!.coordinates.longitude,
    //     ),
    //   );
    //
    //   _mapController!.camera.lookAtAreaWithGeoOrientation(
    //     bbox,
    //     GeoOrientationUpdate(null, null),
    //   );
    // }
  }

  // -----------------------------------------------------
  // Build - escucha cambios de cubit
  // -----------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TrackLocationCubit, TrackLocationState>(
      builder: (context, state) {
        return Stack(
          fit: StackFit.expand,
          children: [
            // Map
            BlocListener<TrackLocationCubit, TrackLocationState>(
              listenWhen:
                  (prev, curr) =>
                      prev.requesterLat != curr.requesterLat ||
                      prev.requesterLng != curr.requesterLng,
              listener: (context, state) {
                if (state.requesterLat != null && state.requesterLng != null) {
                  final target = GeoCoordinates(
                    state.requesterLat!,
                    state.requesterLng!,
                  );
                  _moveUserMarkerAnimated(target);
                }
              },
              child: HereMap(onMapCreated: _onMapCreated),
            ),

            // Back button
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              left: 16,
              child: _buildCircleButton(
                icon: Icons.arrow_back_rounded,
                onPressed: () => Navigator.pop(context),
                tooltip: 'Back',
              ),
            ),

            // Focus buttons
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              right: 16,
              child: Column(
                children: [
                  // Focus on my location
                  _buildCircleButton(
                    icon: Icons.my_location_rounded,
                    onPressed: _focusOnMyLocation,
                    enabled: _myLocation != null,
                    tooltip: context.l10n.myLocation,
                  ),
                  const SizedBox(height: 12),
                  // Focus on requester
                  _buildCircleButton(
                    icon: Icons.person_pin_circle_rounded,
                    onPressed: _focusOnRequester,
                    enabled: _userMarker != null,
                    tooltip: context.l10n.requester,
                  ),
                  const SizedBox(height: 12),
                  // Focus on route
                  _buildCircleButton(
                    icon: Icons.route_rounded,
                    onPressed: _focusOnRoute,
                    enabled: _routePolyline != null,
                    tooltip: 'View Route',
                  ),
                ],
              ),
            ),

            // Floating info card
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SafeArea(
                child: RequesterInfoBottom(
                  payload: widget.payload,
                  requesterLat: state.requesterLat,
                  requesterLng: state.requesterLng,
                  isConnected: state.isConnected,
                  onClose: () => Navigator.pop(context),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required VoidCallback onPressed,
    bool enabled = true,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: AppColors.neutral200.withValues(alpha: 0.5),
            width: 0.5,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: enabled ? onPressed : null,
            child: Center(
              child: Icon(
                icon,
                color: enabled ? AppColors.neutral700 : AppColors.neutral400,
                size: 22,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
