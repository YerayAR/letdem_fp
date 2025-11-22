import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart' as geolocator;
import 'package:here_sdk/core.dart';
import 'package:here_sdk/location.dart';
import 'package:here_sdk/mapview.dart';
import 'package:letdem/features/activities/activities_state.dart';

import '../cubit/track_location_cubit.dart';

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

  // Animación del marker
  AnimationController? _markerAnimController;
  Animation<GeoCoordinates>? _markerAnimation;
  GeoCoordinates? _markerAnimationStart;
  GeoCoordinates? _markerAnimationEnd;

  @override
  void initState() {
    super.initState();
    trackLocationCubit = context.read<TrackLocationCubit>();
    trackLocationCubit.connect(reservationId: widget.spaceId);
    _loadUserMarkerImage();
    _initMyLocation(); // opcional: obtener tu ubicación
  }

  @override
  void dispose() {
    _markerAnimController?.dispose();
    if (_locationListener != null && _locationEngine != null) {
      _locationEngine!.removeLocationListener(_locationListener!);
    }
    _locationIndicator?.disable();
    _mapController = null;
    super.dispose();
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
      });
      _locationEngine!.addLocationListener(_locationListener!);
      _locationEngine!.startWithLocationAccuracy(LocationAccuracy.navigation);
    } catch (e) {
      debugPrint('Error location engine: $e');
    }
  }

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
    final int size = 32;
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
  // Build - escucha cambios de cubit
  // -----------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return BlocListener<TrackLocationCubit, TrackLocationState>(
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
    );
  }
}
