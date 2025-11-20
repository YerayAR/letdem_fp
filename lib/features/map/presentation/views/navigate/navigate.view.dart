// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:here_sdk/core.dart' as HERE;
import 'package:here_sdk/core.errors.dart';
import 'package:here_sdk/gestures.dart';
import 'package:here_sdk/location.dart' as HERE;
import 'package:here_sdk/mapview.dart' as HERE;
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
import 'package:letdem/core/utils/parsers.dart';
import 'package:letdem/features/activities/presentation/modals/space.popup.dart';
import 'package:letdem/features/auth/models/map_options.model.dart';
import 'package:letdem/features/auth/models/nearby_payload.model.dart';
import 'package:letdem/features/map/map_bloc.dart';
import 'package:letdem/features/map/presentation/views/navigate/widgets/navigate_content.dart';
import 'package:letdem/features/map/presentation/widgets/navigation/event_feedback.widget.dart';
import 'package:letdem/features/map/presentation/widgets/navigation/space_feedback.widget.dart';
import 'package:letdem/infrastructure/services/map/map_asset_provider.service.dart';
import 'package:letdem/infrastructure/services/res/navigator.dart';
import 'package:letdem/infrastructure/toast/toast/tone.dart';
import 'package:letdem/infrastructure/tts/tts/tts.dart';
import 'package:letdem/infrastructure/ws/web_socket.service.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import 'widgets/navigate_notification_widget.dart';

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
  static const double _initialZoomDistanceInMeters = 500;
  // static const double _mapPadding = 20;
  // static const double _buttonRadius = 26;
  // static const double _containerPadding = 15;
  // static const double _borderRadius = 20;
  static const int _distanceTriggerThreshold = 120;
  static const double _heightContainer = 130;
  static const int DISTANCE_THREESHOLD = 5;
  bool _isLocationEngineReady = false;
  // bool _isVisualNavigatorReady = false;
  Timer? _locationStabilityTimer;
  int _stableLocationCount = 0;
  static const int _requiredStableUpdates = 3;
  DateTime? _navigationStartTime;
  bool _hasShownFatigueAlert = false;
  bool _isMapReady = false;
  bool _isLocationReady = false;

  HereMapController? _hereMapController;
  HERE.RoutingEngine? _routingEngine;
  HERE.VisualNavigator? _visualNavigator;
  HERE.LocationEngine? _locationEngine;

  HERE.GeoCoordinates? _currentLocation;
  double _currentSpeed = 0;
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
  HERE.SpeedLimit? _roadSpeedLimit;
  bool _isSpeedLimitAlertShown = false;
  bool _isOverSpeedLimit = false;
  bool _isPopupDisplayed = false;
  bool _isUserPanning = false;
  bool _isCameraLocked = true;
  bool _isRecalculatingRoute = false;
  MapMarker? _destinationMarker;

  late double _actualDestinationLat;
  late double _actualDestinationLng;

  int indexRouteSelected = 0;

  String _lastSpokenInstruction = "";
  final ValueNotifier<int> _distanceNotifier = ValueNotifier<int>(0);
  final LocationWebSocketService _locationWebSocketService =
      LocationWebSocketService();

  int _nextManuoverDistance = 0;
  Timer? _rerouteDebounceTimer;
  int _lastRerouteTime = 0;
  String normalManuevers = "";

  // final Map<String, IconData> _directionIcons = {
  //   'turn right': Icons.turn_right,
  //   'turn left': Icons.turn_left,
  //   'go straight': Icons.arrow_upward,
  //   'make a u-turn': Icons.u_turn_left,
  // };

  final MapAssetsProvider _assetsProvider = MapAssetsProvider();
  final Map<MapMarker, Space> _spaceMarkers = {};
  final Map<MapMarker, Event> _eventMarkers = {};
  final Map<String, MapMarker> _spaceMarkersById = {};
  final Map<String, MapMarker> _eventMarkersById = {};

  final speech = SpeechService();

  // Lista para guardar referencias a los MapPolyline que están en el mapa
  final List<HERE.MapPolyline> _routePolylines = [];

  // Lista para guardar los objetos Route (útil si luego quieres que el usuario elija una ruta)
  final List<HERE.Route> _routesOnMap = [];

  StreamSubscription<ServiceStatus>? _gpsSubscription;
  bool _gpsSnackbarShown = false;

  StreamSubscription<List<ConnectivityResult>>? _connectionSubscription;

  bool _isConnected = true;

  bool _isOpenRoutes = false;

  List<HERE.Route> routesList = [];

  @override
  void initState() {
    print("IS navigating to parking: ${widget.isNavigatingToParking}");
    print("Parking space ID: ${widget.parkingSpaceID}");
    WakelockPlus.enable();

    super.initState();

    _listenGpsStatus(context);
    _listenConnectionStatus(context);

    _actualDestinationLat = widget.destinationLat;
    _actualDestinationLng = widget.destinationLng;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _configureTTSLanguage();
      _requestLocationPermission();
    });
  }

  /// 🔹 Listener para el estado del GPS
  void _listenGpsStatus(BuildContext context) {
    _gpsSubscription = Geolocator.getServiceStatusStream().listen((status) {
      if (status == ServiceStatus.disabled && !_gpsSnackbarShown) {
        _gpsSnackbarShown = true;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          AlertHelper.showWarning(
            context: context,
            title: 'GPS desactivado',
            subtext:
                'Tu GPS está desactivado. Actívalo para continuar usando las funciones de ubicación.',
          );
        });
      } else if (status == ServiceStatus.enabled) {
        _gpsSnackbarShown = false;
      }
    });
  }

  void _listenConnectionStatus(BuildContext context) {
    // 🔹 Escucha cambios de red del sistema
    _connectionSubscription = Connectivity().onConnectivityChanged.listen((
      results,
    ) async {
      final hasInternet = await _hasInternetConnection();
      _handleConnectionChange(context, hasInternet);
    });
  }

  void _handleConnectionChange(BuildContext context, bool hasInternet) {
    if (!hasInternet && _isConnected) {
      print('🔴 Sin conexión detectada');
      _isConnected = false;

      AlertHelper.showWarning(
        context: context,
        title: 'Sin conexión a Internet',
        subtext:
            'Parece que perdiste la conexión. Verifica tu red Wi-Fi o tus datos móviles.',
      );
    } else if (hasInternet && !_isConnected) {
      print('🟢 Conexión restablecida');
      _isConnected = true;
    }
  }

  Future<bool> _hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup(
        'google.com',
      ).timeout(const Duration(seconds: 3));
      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  void _configureTTSLanguage() {
    String languageCode = Localizations.localeOf(context).languageCode;
    speech.setLanguage(languageCode);
    debugPrint('🗣️ TTS language configured to: $languageCode');
  }

  @override
  void dispose() {
    _gpsSubscription?.cancel();
    _connectionSubscription?.cancel();
    debugPrint('🗑️ Disposing NavigationView...');
    _locationStabilityTimer?.cancel();
    _locationStabilityTimer = null;

    _rerouteDebounceTimer?.cancel();
    _rerouteDebounceTimer = null;

    _cleanupNavigation();

    _spaceMarkers.clear();
    _eventMarkers.clear();
    _spaceMarkersById.clear();
    _eventMarkersById.clear();

    _distanceNotifier.dispose();

    WakelockPlus.disable();

    debugPrint('✅ NavigationView disposed');
    super.dispose();
  }

  Future<void> _requestLocationPermission() async {
    setState(() => _isLoading = true);

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

    await _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      var currentLocationGeo = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.bestForNavigation,
          timeLimit: Duration(seconds: 15),
        ),
      );

      debugPrint(
        '📍 Current location: ${currentLocationGeo.latitude}, ${currentLocationGeo.longitude}',
      );

      _currentLocation = HERE.GeoCoordinates(
        currentLocationGeo.latitude,
        currentLocationGeo.longitude,
      );

      _lastLatitude = currentLocationGeo.latitude;
      _lastLongitude = currentLocationGeo.longitude;
      _distanceTraveled = 0;
      _lastTriggerDistance = 0;

      setState(() {
        _isLocationReady = true;
        _isLoading = false;
      });

      _initializeWebSocketConnection();
    } catch (e) {
      debugPrint('❌ Error getting current location: $e');
      setState(() {
        _errorMessage = "Failed to get current location";
        _isLoading = false;
        _isLocationReady = false;
      });
    }
  }

  void _attemptToStartNavigation() {
    debugPrint('🚀 Attempting to start navigation...');
    debugPrint('  - Is navigating: $_isNavigating');
    debugPrint('  - Is loading: $_isLoading');
    debugPrint('  - Map ready: $_isMapReady');
    debugPrint('  - Location ready: $_isLocationReady');
    debugPrint('  - Location engine ready: $_isLocationEngineReady');
    debugPrint('  - Current location: ${_currentLocation != null}');

    if (_isNavigating || _isLoading) {
      debugPrint('⚠️ Navigation already in progress, skipping...');
      return;
    }

    if (!_isMapReady || !_isLocationReady || !_isLocationEngineReady) {
      debugPrint('⏳ Not all prerequisites ready, waiting...');
      return;
    }
    if (_isMapReady &&
        _isLocationReady &&
        _isLocationEngineReady &&
        _currentLocation != null) {
      debugPrint('🚀 All systems ready, starting navigation...');
      _calculateRoute(
        _currentLocation!,
        HERE.GeoCoordinates(_actualDestinationLat, _actualDestinationLng),
      );
    } else {
      debugPrint(
        '⏳ Waiting for prerequisites: Map ready: $_isMapReady, Location ready: $_isLocationReady, Engine ready: $_isLocationEngineReady',
      );
    }
  }

  void _onMapCreated(HereMapController hereMapController) async {
    debugPrint('🗺️ Map created!');

    setState(() => _isLoading = true);

    await _assetsProvider.loadAssets();
    _hereMapController = hereMapController;

    _configureMapSettings();

    _loadMapScene();
  }

  void _configureMapSettings() {
    if (_hereMapController == null) return;

    _hereMapController?.gestures.enableDefaultAction(GestureType.pan);
    _hereMapController?.gestures.enableDefaultAction(GestureType.pinchRotate);
    _hereMapController?.gestures.enableDefaultAction(GestureType.twoFingerPan);

    final features = {
      MapFeatures.buildingFootprints: MapFeatureModes.buildingFootprintsAll,
      MapFeatures.trafficFlow: MapFeatureModes.trafficFlowWithFreeFlow,
      MapFeatures.trafficIncidents: MapFeatureModes.trafficIncidentsAll,
      MapFeatures.roadExitLabels: MapFeatureModes.roadExitLabelsAll,

      MapFeatures.vehicleRestrictions:
          MapFeatureModes.vehicleRestrictionsActiveAndInactive,
      MapFeatures.landmarks: MapFeatureModes.landmarksTextured,
      MapFeatures.shadows: MapFeatureModes.shadowsAll,
      MapFeatures.safetyCameras: MapFeatureModes.defaultMode,
    };

    for (final entry in features.entries) {
      _hereMapController?.mapScene.enableFeatures({entry.key: entry.value});
    }

    _setupGestureListeners();

    // _addInitialDestinationMarker();
  }

  void _setupGestureListeners() {
    _hereMapController?.gestures.tapListener = TapListener((
      HERE.Point2D touchPoint,
    ) {
      _pickMapMarker(touchPoint);
    });

    _hereMapController?.gestures.panListener = PanListener((
      GestureState state,
      HERE.Point2D point1,
      HERE.Point2D point2,
      double distanceInPixels,
    ) {
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
  }

  // void _addInitialDestinationMarker() {
  //   var icon = _assetsProvider.destinationMarkerLarge;
  //   final marker = MapMarker(
  //     HERE.GeoCoordinates(widget.destinationLat, widget.destinationLng),
  //     MapImage.withPixelDataAndImageFormat(icon, ImageFormat.png),
  //   );
  //   _hereMapController!.mapScene.addMapMarker(marker);
  // }

  void _loadMapScene() {
    if (_hereMapController == null) return;

    _hereMapController!.mapScene.loadSceneForMapScheme(MapScheme.normalDay, (
      error,
    ) {
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
        MapMeasureKind.distanceInMeters,
        _initialZoomDistanceInMeters,
      );

      _hereMapController!.camera.lookAtPointWithMeasure(
        HERE.GeoCoordinates(widget.destinationLat, widget.destinationLng),
        mapMeasureZoom,
      );

      _initLocationEngine();
    });
  }

  void _waitForLocationEngineStability() {
    debugPrint('⏳ Waiting for location engine stability...');

    _locationStabilityTimer = Timer.periodic(
      const Duration(milliseconds: 500),
      (timer) {
        if (_currentLocation != null) {
          _stableLocationCount++;
          debugPrint('📍 Stable location count: $_stableLocationCount');

          if (_stableLocationCount >= _requiredStableUpdates) {
            timer.cancel();
            setState(() {
              _isLocationEngineReady = true;
              _isMapReady = true;
            });
            debugPrint(
              '✅ Location engine is stable, attempting navigation start',
            );
            _attemptToStartNavigation();
          }
        } else {
          _stableLocationCount = 0;
        }
      },
    );
  }

  void _initLocationEngine() {
    debugPrint('🛰️ Initializing Location Engine...');
    try {
      _locationEngine = HERE.LocationEngine();
      debugPrint('✅ Location Engine initialized.');

      _waitForLocationEngineStability();
    } on InstantiationException {
      debugPrint('❌ Initialization of LocationEngine failed.');
      setState(() {
        _errorMessage = context.l10n.failedToInitializeLocation;
        _isLoading = false;
        _isMapReady = false;
        _isLocationEngineReady = false;
      });
    }
  }

  void _calculateRoute(
    HERE.GeoCoordinates start,
    HERE.GeoCoordinates destination,
  ) {
    debugPrint('🧭 Calculating routes (with alternatives)...');
    debugPrint('📍 Start: ${start.latitude}, ${start.longitude}');
    debugPrint(
      '🎯 Destination: ${destination.latitude}, ${destination.longitude}',
    );

    setState(() => _isLoading = true);

    // Inicializar motor de rutas
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
    carOptions.routeOptions.alternatives = 2;

    carOptions.routeOptions.departureTime = DateTime.now();
    carOptions.routeOptions.trafficOptimizationMode =
        HERE.TrafficOptimizationMode.timeDependent;

    _routingEngine!.calculateCarRoute(
      [startWaypoint, destinationWaypoint],
      carOptions,
      (HERE.RoutingError? routingError, List<HERE.Route>? routeList) async {
        if (routingError == null && routeList != null && routeList.isNotEmpty) {
          debugPrint('✅ Found ${routeList.length} routes');

          // Limpia polylines anteriores si hace falta
          _clearPreviousRoutes();

          for (int i = 0; i < routeList.length; i++) {
            final route = routeList[i];

            // Duración y distancia de cada ruta
            debugPrint(
              "🚗 Ruta $i: "
              "${route.duration.inMinutes} min, "
              "${(route.lengthInMeters / 1000).toStringAsFixed(1)} km",
            );

            // Estilo de polyline
            final polylineColor =
                (i == 0)
                    ? const Color.fromARGB(200, 0, 0, 255)
                    : const Color.fromARGB(160, 0, 200, 0);

            final sizesMap = {
              0.0: i == 0 ? 10.0 : 5.0, // ancho en zoom bajo
              20.0: i == 0 ? 10.0 : 5.0, // ancho en zoom alto
            };

            final renderSize = HERE.MapMeasureDependentRenderSize(
              HERE.MapMeasureKind.zoomLevel,
              HERE.RenderSizeUnit.pixels,
              sizesMap,
            );

            final representation = HERE.MapPolylineSolidRepresentation(
              renderSize,
              polylineColor,
              HERE.LineCap.round,
            );

            final polyline = HERE.MapPolyline.withRepresentation(
              route.geometry,
              representation,
            );

            _hereMapController!.mapScene.addMapPolyline(polyline);

            // Guardar referencias
            _routePolylines.add(polyline);
            _routesOnMap.add(route);
          }

          // Actualiza estado
          setState(() {
            _isNavigating = true;
            _isLoading = false;
          });

          print('routeList ==> 1 // ${routeList.length}');
          // Por ahora tomamos la primera ruta como activa
          routesList = routeList;
          final selectedRoute = routeList.first;
          indexRouteSelected = 0;
          _totalRouteTime = selectedRoute.duration.inSeconds;
          _distanceNotifier.value = selectedRoute.lengthInMeters;
          _addDestinationMarker(selectedRoute);
          _setMapCameraFocus();

          _navigationStartTime = DateTime.now();
          print('se esta ejecutando...');
          _startGuidance(selectedRoute);
        } else {
          final error = routingError?.toString() ?? "Unknown error";
          debugPrint('❌ Error while calculating routes: $error');
          setState(() {
            _errorMessage = context.l10n.navigationError;
            _isLoading = false;
          });
        }
      },
    );
  }

  void _clearPreviousRoutes() {
    for (final polyline in _routePolylines) {
      _hereMapController!.mapScene.removeMapPolyline(polyline);
    }
    _routePolylines.clear();
    _routesOnMap.clear();
    debugPrint("🧹 Rutas previas eliminadas del mapa.");
  }

  // void _calculateRoute(
  //   HERE.GeoCoordinates start,
  //   HERE.GeoCoordinates destination,
  // ) {
  //   debugPrint('🧭 Calculating route...');
  //   debugPrint('📍 Start: ${start.latitude}, ${start.longitude}');
  //   debugPrint(
  //     '🎯 Destination: ${destination.latitude}, ${destination.longitude}',
  //   );

  //   setState(() => _isLoading = true);

  //   // Initialize routing engine if needed
  //   if (_routingEngine == null) {
  //     try {
  //       _routingEngine = HERE.RoutingEngine();
  //       debugPrint('✅ Routing Engine initialized.');
  //     } on InstantiationException {
  //       debugPrint('❌ Initialization of RoutingEngine failed.');
  //       setState(() {
  //         _errorMessage = "Failed to initialize routing";
  //         _isLoading = false;
  //       });
  //       return;
  //     }
  //   }

  //   HERE.Waypoint startWaypoint = HERE.Waypoint(start);
  //   HERE.Waypoint destinationWaypoint = HERE.Waypoint(destination);

  //   final carOptions = HERE.CarOptions();
  //   carOptions.routeOptions.enableTolls = true;
  //   carOptions.routeOptions.optimizationMode = HERE.OptimizationMode.fastest;

  //   _routingEngine!.calculateCarRoute(
  //     [startWaypoint, destinationWaypoint],
  //     carOptions,
  //     (HERE.RoutingError? routingError, List<HERE.Route>? routeList) async {
  //       if (routingError == null && routeList != null && routeList.isNotEmpty) {
  //         HERE.Route calculatedRoute = routeList.first;

  //         _totalRouteTime = calculatedRoute.duration.inSeconds;
  //         _distanceNotifier.value = calculatedRoute.lengthInMeters;

  //         _addDestinationMarker(calculatedRoute);
  //         _setMapCameraFocus();

  //         setState(() {
  //           _isNavigating = true;
  //           _isLoading = false;
  //         });

  //         // IMPORTANT: Set navigation start time here
  //         _navigationStartTime = DateTime.now();
  //         debugPrint('🕐 Navigation started at: $_navigationStartTime');

  //         debugPrint('✅ Route calculated successfully');
  //         _startGuidance(calculatedRoute);
  //       } else {
  //         final error = routingError?.toString() ?? "Unknown error";
  //         debugPrint('❌ Error while calculating route: $error');
  //         setState(() {
  //           _errorMessage = context.l10n.navigationError;
  //           _isLoading = false;
  //         });
  //       }
  //     },
  //   );
  // }

  void _startGuidance(HERE.Route route) {
    if (_hereMapController == null) {
      _handleNavigationSetupError('Map controller not ready');
      return;
    }

    debugPrint('🧭 Starting visual guidance...');
    _configureTTSLanguage();

    try {
      // Inicializar VisualNavigator
      _visualNavigator = HERE.VisualNavigator();
      debugPrint('✅ VisualNavigator initialized.');

      // CRITICAL: Establecer la ruta inicial
      _visualNavigator!.route = route;
      debugPrint('✅ Route set on visual navigator');

      // Iniciar renderizado en el mapa
      _visualNavigator!.startRendering(_hereMapController!);
      debugPrint('📡 Started rendering navigator.');

      // Escuchar desviaciones de ruta para recalcular
      _visualNavigator!.routeDeviationListener = HERE.RouteDeviationListener((
        deviation,
      ) {
        debugPrint("⚠️ Usuario se desvió de la ruta");

        final currentLocation =
            deviation.currentLocation.originalLocation.coordinates;
        HERE.GeoCoordinates? destination = HERE.GeoCoordinates(
          widget.destinationLat,
          widget.destinationLng,
        );

        print('_routingEngine $_routingEngine');

        _routingEngine?.calculateCarRoute(
          [HERE.Waypoint(currentLocation), HERE.Waypoint(destination)],
          HERE.CarOptions(),
          (HERE.RoutingError? error, List<HERE.Route>? routes) {
            debugPrint("✅ Nueva ruta recalculada");
            if (error == null && routes != null && routes.isNotEmpty) {
              _visualNavigator!.route = routes.first;

              _clearPreviousRoutes();
              _drawRouteOnMap(routes);

              setState(() {
                _totalRouteTime = routes.first.duration.inSeconds;
                _distanceNotifier.value = routes.first.lengthInMeters;
              });
            } else {
              debugPrint("❌ Error recalculando ruta: $error");
            }
          },
        );
      });

      // Marcar navigator como listo
      // setState(() {
      //   _isVisualNavigatorReady = true;
      // });

      // Delay para setup estable
      Future.delayed(const Duration(seconds: 2), () {
        if (_visualNavigator != null && mounted) {
          _setupNavigationWithStableConnection();
          debugPrint('✅ Navigation guidance setup completed');
        }
      });
    } on InstantiationException catch (e) {
      debugPrint('❌ Initialization of VisualNavigator failed: $e');
      _handleNavigationSetupError('Failed to initialize navigation: $e');
    } catch (e) {
      debugPrint('❌ Unexpected error starting guidance: $e');
      _handleNavigationSetupError('Unexpected navigation error: $e');
    }
  }

  void _resetNavigation() {
    // Detener navigator anterior
    if (_visualNavigator != null) {
      _visualNavigator!.stopRendering();
      _visualNavigator!.route = null;
      _visualNavigator = null;
    }

    // Quitar polylines previas
    _clearPreviousRoutes();

    // Quitar marcadores si usas
    _removeDestinationMarker();

    debugPrint('🔄 Navegación reseteada correctamente');
  }

  void _removeDestinationMarker() {
    if (_destinationMarker != null) {
      _hereMapController?.mapScene.removeMapMarker(_destinationMarker!);
      _destinationMarker = null;
    }
  }

  /// Dibuja una lista de rutas en el mapa.
  /// - `routes`: lista de HERE.Route devueltas por el RoutingEngine.
  /// - `highlightIndex`: índice de la ruta a resaltar (por defecto 0).
  /// - `clearPrevious`: si es true limpia las polylines previas antes de dibujar.
  void _drawRouteOnMap(
    List<HERE.Route> routes, {
    int highlightIndex = 0,
    bool clearPrevious = false,
  }) {
    if (_hereMapController == null) {
      debugPrint('❌ _drawRouteOnMap: map controller is null');
      return;
    }

    if (routes.isEmpty) {
      debugPrint('⚠️ _drawRouteOnMap: no routes to draw');
      return;
    }

    if (clearPrevious) {
      _clearPreviousRoutes();
    }

    for (int i = 0; i < routes.length; i++) {
      final route = routes[i];

      try {
        final bool isHighlighted = i == highlightIndex;

        // Colores y grosores (ajusta a tu gusto)
        final polylineColor =
            isHighlighted
                ? const Color.fromARGB(200, 0, 0, 255)
                : const Color.fromARGB(160, 0, 200, 0);

        // Ancho dependiente del zoom (mismo ancho en todo el rango de zoom)
        final sizesMap = <double, double>{
          0.0: isHighlighted ? 10.0 : 5.0,
          20.0: isHighlighted ? 10.0 : 5.0,
        };

        final renderSize = HERE.MapMeasureDependentRenderSize(
          HERE.MapMeasureKind.zoomLevel,
          HERE.RenderSizeUnit.pixels,
          sizesMap,
        );

        final representation = HERE.MapPolylineSolidRepresentation(
          renderSize,
          polylineColor,
          HERE.LineCap.round,
        );

        final polyline = HERE.MapPolyline.withRepresentation(
          route.geometry,
          representation,
        );

        // Añadir al mapa y guardar referencias
        _hereMapController!.mapScene.addMapPolyline(polyline);
        _routePolylines.add(polyline);
        _routesOnMap.add(route);

        debugPrint(
          '🖊️ Dibujada ruta $i (${isHighlighted ? "resaltada" : "alternativa"}): '
          '${route.duration.inMinutes} min, ${(route.lengthInMeters / 1000).toStringAsFixed(1)} km',
        );
      } catch (e, st) {
        debugPrint('❌ Error al dibujar ruta $i: $e\n$st');
      }
    }
  }

  // void _startGuidance(HERE.Route route) {
  //   if (_hereMapController == null) {
  //     _handleNavigationSetupError('Map controller not ready');
  //     return;
  //   }

  //   debugPrint('🧭 Starting visual guidance...');
  //   _configureTTSLanguage();

  //   try {
  //     // Initialize visual navigator
  //     _visualNavigator = HERE.VisualNavigator();
  //     debugPrint('✅ VisualNavigator initialized.');

  //     // CRITICAL: Set the route FIRST
  //     _visualNavigator!.route = route;
  //     debugPrint('✅ Route set on visual navigator');

  //     // Start rendering
  //     _visualNavigator!.startRendering(_hereMapController!);
  //     debugPrint('📡 Started rendering navigator.');

  //     // Mark visual navigator as ready
  //     setState(() {
  //       _isVisualNavigatorReady = true;
  //     });

  //     // Add a small delay to ensure rendering is stable
  //     Future.delayed(const Duration(seconds: 2), () {
  //       if (_visualNavigator != null && mounted) {
  //         _setupNavigationWithStableConnection();
  //         debugPrint('✅ Navigation guidance setup completed');
  //       }
  //     });
  //   } on InstantiationException catch (e) {
  //     debugPrint('❌ Initialization of VisualNavigator failed: $e');
  //     _handleNavigationSetupError('Failed to initialize navigation: $e');
  //   } catch (e) {
  //     debugPrint('❌ Unexpected error starting guidance: $e');
  //     _handleNavigationSetupError('Unexpected navigation error: $e');
  //   }
  // }

  // void _setupNavigationWithStableConnection() {
  //   debugPrint('🔧 Setting up navigation with stable connection...');
  //
  //   // Setup listeners first
  //   _setupNavigationListeners();
  //   _setupRouteDeviationListener();
  //
  //   // Setup location source with callback for when it's ready
  //   _setupLocationSourceWithCallback(_visualNavigator!, () {
  //     debugPrint('✅ Location source is connected and stable');
  //
  //     // Now setup camera behavior
  //     if (_isCameraLocked) {
  //       _visualNavigator!.cameraBehavior = HERE.FixedCameraBehavior();
  //     }
  //
  //     // Set camera orientation for 3D navigation view
  //     _hereMapController!.camera.setOrientationAtTarget(
  //       HERE.GeoOrientationUpdate(0, 65),
  //     );
  //
  //     // Force initial location update after everything is ready
  //     _forceInitialLocationUpdate();
  //
  //     debugPrint('✅ Navigation guidance started successfully');
  //   });
  // }

  void _setupNavigationWithStableConnection() {
    debugPrint('🔧 Setting up navigation with stable connection...');

    _setupRouteDeviationListener();

    _startLocationEngineForNavigation();

    Future.delayed(const Duration(milliseconds: 1000), () {
      if (_visualNavigator != null && mounted) {
        _setupNavigationListeners();
        debugPrint('🎯 Navigation listeners set up after delay');
      }
    });
  }

  void _startLocationEngineForNavigation() {
    debugPrint('📍 Starting location engine for navigation...');

    if (_locationEngine == null || _visualNavigator == null) {
      debugPrint('❌ Location engine or visual navigator is null');
      _handleNavigationSetupError(
        'Critical navigation components not initialized',
      );
      return;
    }

    try {
      _locationEngine!.addLocationListener(
        HERE.LocationListener((HERE.Location location) {
          debugPrint('📍 NAVIGATION LOCATION UPDATE:');
          debugPrint('  - Lat: ${location.coordinates.latitude}');
          debugPrint('  - Lng: ${location.coordinates.longitude}');
          debugPrint('  - Accuracy: ${location.horizontalAccuracyInMeters}');

          _currentLocation = location.coordinates;
          double? speed = location.speedInMetersPerSecond;

          if (mounted) {
            setState(() {
              _currentSpeed = speed ?? 0;
              _checkSpeedLimit();
            });
          }

          if (_lastLatitude == 0 && _lastLongitude == 0) {
            _lastLatitude = location.coordinates.latitude;
            _lastLongitude = location.coordinates.longitude;
          }
          _checkDistanceTrigger(
            location.coordinates.latitude,
            location.coordinates.longitude,
          );

          try {
            _visualNavigator!.onLocationUpdated(location);
            debugPrint('✅ Location sent to visual navigator successfully');
          } catch (e) {
            debugPrint('❌ Error sending location to visual navigator: $e');
          }
        }),
      );

      _locationEngine!.startWithLocationAccuracy(
        HERE.LocationAccuracy.navigation,
      );

      _setupCameraBehavior();

      debugPrint('✅ Location engine started for navigation');
    } catch (e) {
      debugPrint('❌ Failed to start location engine for navigation: $e');
      _handleNavigationSetupError('Failed to start location tracking: $e');
    }
  }

  void _setupCameraBehavior() {
    if (_visualNavigator == null || _hereMapController == null) return;

    try {
      if (_isCameraLocked) {
        _visualNavigator!.cameraBehavior = HERE.FixedCameraBehavior();
        debugPrint('📷 Camera behavior set to fixed');
      }

      _hereMapController!.camera.setOrientationAtTarget(
        HERE.GeoOrientationUpdate(0, 65),
      );
      debugPrint('📷 Camera orientation set for navigation');

      if (_currentLocation != null) {
        _hereMapController!.camera.lookAtPointWithMeasure(
          _currentLocation!,
          MapMeasure(MapMeasureKind.distanceInMeters, 500),
        );
        debugPrint('📷 Camera positioned at current location');
      }
    } catch (e) {
      debugPrint('⚠️ Error setting up camera behavior: $e');
    }
  }

  void _handleNavigationSetupError(String errorMessage) {
    debugPrint('❌ Navigation setup error: $errorMessage');

    if (mounted) {
      setState(() {
        _errorMessage = errorMessage;
        _isNavigating = false;
        _isLoading = false;
        // _isVisualNavigatorReady = false;
      });
    }
  }

  void _setupNavigationListeners() {
    DateTime lastUpdateTime = DateTime.now();

    _visualNavigator!.routeProgressListener = HERE.RouteProgressListener((
      HERE.RouteProgress routeProgress,
    ) {
      debugPrint('🎯 ROUTE PROGRESS UPDATE RECEIVED');

      final now = DateTime.now();
      HERE.SectionProgress lastSectionProgress =
          routeProgress.sectionProgress.last;
      int remainingDistance = lastSectionProgress.remainingDistanceInMeters;

      if (now.difference(lastUpdateTime).inMilliseconds < 500) {
        return;
      }

      if (!_isMuted &&
          normalManuevers != _lastSpokenInstruction &&
          normalManuevers.isNotEmpty) {
        _lastSpokenInstruction = normalManuevers;
        speech.speak(normalManuevers, context);
      }

      if (routeProgress.maneuverProgress.isNotEmpty) {
        _nextManuoverDistance =
            routeProgress.maneuverProgress.first.remainingDistanceInMeters
                .floor();
      }

      final remainingDurationInSeconds =
          lastSectionProgress.remainingDuration.inSeconds;
      _distanceNotifier.value = remainingDistance;

      bool isAtDestination = remainingDistance <= DISTANCE_THREESHOLD;
      bool isParkingNavigation =
          _currentSpace != null || widget.isNavigatingToParking;

      if (isAtDestination && !_hasShownArrivalNotification) {
        debugPrint('✅ Arrived at destination!');
        _handleArrival(isParkingNavigation);
      }

      lastUpdateTime = now;

      if (mounted) {
        setState(() {
          _totalRouteTime = remainingDurationInSeconds;
        });

        _checkFatigueAlert();
      }
    });

    _visualNavigator!.eventTextListener = HERE.EventTextListener((
      HERE.EventText eventText,
    ) {
      debugPrint('🗣️ EVENT TEXT UPDATE RECEIVED');

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

    _setupSpeedLimitListener();
  }

  void _handleArrival(bool isParkingNavigation) {
    setState(() {
      _hasShownArrivalNotification = true;
    });

    if (!isParkingNavigation) {
      AppPopup.showDialogSheet(
        context,
        NavigateNotificationWidget(
          onClose: () {
            NavigatorHelper.pop();
          },
        ),
      );
    } else if (!_hasShownParkingRating && !_isPopupDisplayed) {
      _showParkingRatingDialog();
    }

    if (!isParkingNavigation) {
      _showToast(
        context.l10n.arrivedAtDestination,
        backgroundColor: AppColors.green600,
      );
      putParkingSpacesOnMap();
    }
  }

  void _showParkingRatingDialog() {
    setState(() {
      _hasShownParkingRating = true;
      _isPopupDisplayed = true;
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted && _currentSpace != null) {
        if (_currentSpace!.isPremium) {
          AppPopup.showBottomSheet(
            context,
            SpacePopupSheet(
              space: _currentSpace!,
              currentPosition: HERE.GeoCoordinates(
                _currentLocation!.latitude,
                _currentLocation!.longitude,
              ),
              onRefreshTrigger: () {
                NavigatorHelper.pop();
                _isPopupDisplayed = false;
                _hasShownParkingRating = false;
              },
            ),
          );
        } else {
          AppPopup.showBottomSheet(
            context,
            ParkingRatingWidget(
              isOwner: _currentSpace!.isOwner,
              spaceID: _currentSpace!.id,
              onSubmit: () {
                NavigatorHelper.pop();
                _isPopupDisplayed = false;
                _hasShownParkingRating = false;
              },
            ),
          );
        }
      }
    });
  }

  void _checkFatigueAlert() {
    if (context.isFatigueAlertEnabled &&
        _navigationStartTime != null &&
        !_hasShownFatigueAlert &&
        DateTime.now().difference(_navigationStartTime!).inSeconds >= 10800) {
      _hasShownFatigueAlert = true;
      AlertHelper.showWarning(
        context: context,
        title: context.l10n.fatigueAlertTitle,
        subtext: context.l10n.fatigueAlertMessage,
      );

      if (!_isMuted) {
        speech.speak(context.l10n.fatigueAlertVoice, context);
      }
    }
  }

  void _checkSpeedLimit() {
    if (_currentSpeed > 0 && _roadSpeedLimit != null) {
      final buffer = _roadSpeedLimit!.speedLimitInMetersPerSecond! * 0.05;
      _isOverSpeedLimit =
          _currentSpeed >
          (_roadSpeedLimit!.speedLimitInMetersPerSecond! + buffer);

      if (_isOverSpeedLimit && !_isMuted && !_isSpeedLimitAlertShown) {
        _showSpeedLimitAlert();
        _isSpeedLimitAlertShown = true;
      } else if (!_isOverSpeedLimit) {
        _isSpeedLimitAlertShown = false;
      }
    }
  }

  // void _forceInitialLocationUpdate() async {
  //   if (_visualNavigator == null || _currentLocation == null) return;

  //   try {
  //     // Create a location object with current position
  //     final initialLocation = HERE.Location.withCoordinates(_currentLocation!);

  //     // Force the visual navigator to process this location
  //     _visualNavigator!.onLocationUpdated(initialLocation);

  //     // Move camera to current location
  //     _hereMapController?.camera.lookAtPointWithMeasure(
  //       _currentLocation!,
  //       MapMeasure(MapMeasureKind.distanceInMeters, 500),
  //     );

  //     debugPrint('✅ Forced initial location update sent to navigator');
  //   } catch (e) {
  //     debugPrint('❌ Error forcing initial location update: $e');
  //   }
  // }

  void _setupSpeedLimitListener() {
    if (_visualNavigator == null) return;

    debugPrint('🚗 Setting up speed limit listener...');

    _visualNavigator!.speedLimitListener = HERE.SpeedLimitListener((
      HERE.SpeedLimit? speedLimit,
    ) {
      if (speedLimit == null) {
        debugPrint('⚠️ No speed limit information available');
        setState(() {
          _roadSpeedLimit = null;
        });
        return;
      }

      debugPrint(
        '🛑 Speed limit updated: ${speedLimit.speedLimitInMetersPerSecond} m/s',
      );

      setState(() {
        _roadSpeedLimit = speedLimit;
        _checkSpeedLimit();
      });
    });

    debugPrint('✅ Speed limit listener set up successfully');
  }

  void _showSpeedLimitAlert() {
    if (_roadSpeedLimit == null || !context.isSpeedAlertEnabled) return;

    final speedLimitKmh =
        (_roadSpeedLimit!.speedLimitInMetersPerSecond! * 3.6).round();

    AlertHelper.showWarning(
      context: context,
      title: context.l10n.speedLimitAlert,
      subtext: context.l10n.speedLimitWarning,
    );

    if (!_isMuted) {
      speech.speak(
        context.l10n.speedLimitVoiceAlert(speedLimitKmh.toString()),
        context,
      );
    }
  }

  void _setupRouteDeviationListener() {
    if (_visualNavigator == null) return;

    debugPrint('🛰️ Setting up route deviation listener...');

    _visualNavigator!.routeDeviationListener = HERE.RouteDeviationListener((
      HERE.RouteDeviation routeDeviation,
    ) {
      debugPrint('🛰️ Route deviation detected');

      if (_navigationStartTime == null) {
        _navigationStartTime = DateTime.now();
        debugPrint('🕐 Navigation start time recorded');
      }

      final timeSinceStart =
          DateTime.now().difference(_navigationStartTime!).inSeconds;
      final now = DateTime.now().millisecondsSinceEpoch;
      final timeSinceLastReroute = now - _lastRerouteTime;

      if (timeSinceStart < 30) {
        debugPrint(
          '⏳ Within startup grace period (${timeSinceStart}s), ignoring deviation',
        );
        return;
      }

      if (_isRecalculatingRoute) {
        debugPrint('⏳ Already recalculating route. Skipping...');
        return;
      }

      if (timeSinceLastReroute < 10000) {
        debugPrint(
          '⏳ Too soon since last reroute (${timeSinceLastReroute}ms), ignoring',
        );
        return;
      }

      final minimumDeviationDistance = 50;
      final distanceFromRoute =
          routeDeviation.traveledDistanceOnLastSectionInMeters?.toInt() ?? 0;
      final remainingRouteDistance = _distanceNotifier.value;

      debugPrint('📏 Deviation analysis:');
      debugPrint('  - Distance from route: ${distanceFromRoute}m');
      debugPrint('  - Remaining route distance: ${remainingRouteDistance}m');
      debugPrint(
        '  - Minimum deviation threshold: ${minimumDeviationDistance}m',
      );

      bool isSignificantDeviation =
          distanceFromRoute >= minimumDeviationDistance;
      bool isFarFromDestination = remainingRouteDistance > 200;
      bool shouldRecalculate = isSignificantDeviation && isFarFromDestination;

      if (shouldRecalculate) {
        debugPrint(
          '⚠️ Significant deviation confirmed, recalculating route...',
        );

        _rerouteDebounceTimer?.cancel();
        _isRecalculatingRoute = true;
        _lastRerouteTime = now;

        _showToast(
          context.l10n.recalculatingRoute,
          backgroundColor: AppColors.red500,
        );

        _rerouteDebounceTimer = Timer(const Duration(milliseconds: 2000), () {
          if (_isRecalculatingRoute && mounted) {
            _recalculateRouteFromCurrentLocation(
              routeDeviation.currentLocation.originalLocation.coordinates,
            );
          }
        });
      } else {
        debugPrint('✅ Deviation not significant enough for recalculation');
        debugPrint('  - Significant deviation: $isSignificantDeviation');
        debugPrint('  - Far from destination: $isFarFromDestination');
      }
    });

    debugPrint('✅ Route deviation listener setup completed');
  }

  void _recalculateRouteFromCurrentLocation(
    HERE.GeoCoordinates currentPosition,
  ) {
    if (_routingEngine == null || !mounted) {
      debugPrint(
        '❌ Cannot recalculate: routing engine null or widget disposed',
      );
      setState(() {
        _isRecalculatingRoute = false;
      });
      return;
    }

    try {
      debugPrint(
        '🧭 Recalculating route from: ${currentPosition.latitude}, ${currentPosition.longitude}',
      );

      HERE.Waypoint startWaypoint = HERE.Waypoint(currentPosition);
      HERE.Waypoint destinationWaypoint = HERE.Waypoint(
        HERE.GeoCoordinates(_actualDestinationLat, _actualDestinationLng),
      );

      final carOptions = HERE.CarOptions();
      carOptions.routeOptions.enableTolls = true;
      carOptions.routeOptions.optimizationMode = HERE.OptimizationMode.fastest;

      _routingEngine!.calculateCarRoute(
        [startWaypoint, destinationWaypoint],
        carOptions,
        (HERE.RoutingError? routingError, List<HERE.Route>? routeList) async {
          if (!mounted) return;

          if (routingError == null &&
              routeList != null &&
              routeList.isNotEmpty) {
            print('routeList ==> ${routeList.length}');

            HERE.Route calculatedRoute = routeList.first;

            debugPrint('✅ Route recalculated successfully');
            debugPrint(
              '  - New route length: ${calculatedRoute.lengthInMeters}m',
            );
            debugPrint(
              '  - New route duration: ${calculatedRoute.duration.inMinutes}min',
            );

            if (_visualNavigator != null && mounted) {
              _visualNavigator!.route = calculatedRoute;

              _totalRouteTime = calculatedRoute.duration.inSeconds;
              _distanceNotifier.value = calculatedRoute.lengthInMeters;
              _addTrafficAwareRoutePolyline(calculatedRoute);

              _addDestinationMarker(calculatedRoute);

              setState(() {
                _isNavigating = true;
                _isRecalculatingRoute = false;
              });

              debugPrint('✅ Visual navigator updated with new route');
            }
          } else {
            final error = routingError?.toString() ?? "Unknown routing error";
            debugPrint('❌ Route recalculation failed: $error');

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
      if (mounted) {
        setState(() {
          _isRecalculatingRoute = false;
        });
      }
    }
  }

  String getStreetNameFromManeuver(
    HERE.Maneuver maneuver, {
    List<Locale> preferredLocales = const [],
  }) {
    String? name = maneuver.nextRoadTexts.names.getDefaultValue();
    name ??= maneuver.roadTexts.names.getDefaultValue();
    return name ?? context.l10n.unnamedRoad;
  }

  void _addDestinationMarker(HERE.Route calculatedRoute) {
    if (_destinationMarker != null) {
      _hereMapController!.mapScene.removeMapMarker(_destinationMarker!);
      _destinationMarker = null;
    }

    var icon = _assetsProvider.destinationMarkerLarge;
    _destinationMarker = MapMarker(
      HERE.GeoCoordinates(
        calculatedRoute.geometry.vertices.last.latitude,
        calculatedRoute.geometry.vertices.last.longitude,
      ),
      MapImage.withPixelDataAndImageFormat(icon, ImageFormat.png),
    );
    _hereMapController!.mapScene.addMapMarker(_destinationMarker!);
  }

  void _setMapCameraFocus() {
    if (_currentLocation == null) return;

    MapMeasure mapMeasureZoom = MapMeasure(
      MapMeasureKind.distanceInMeters,
      _initialZoomDistanceInMeters,
    );

    _hereMapController!.camera.lookAtPointWithMeasure(
      HERE.GeoCoordinates(
        _currentLocation!.latitude,
        _currentLocation!.longitude,
      ),
      mapMeasureZoom,
    );
  }

  void _cleanupNavigation() {
    debugPrint('🧹 Starting comprehensive navigation cleanup...');

    try {
      _locationStabilityTimer?.cancel();
      _locationStabilityTimer = null;
      if (_routePolylines.isNotEmpty) {
        _hereMapController?.mapScene.removeMapPolylines(_routePolylines);
        _routePolylines.clear();
        debugPrint('✅ Route polylines cleared');
      }

      if (_visualNavigator != null) {
        _visualNavigator!.stopRendering();
        _visualNavigator!.routeProgressListener = null;
        _visualNavigator!.speedLimitListener = null;
        _visualNavigator!.routeDeviationListener = null;
        _visualNavigator!.eventTextListener = null;
        _visualNavigator!.cameraBehavior = null;
        _visualNavigator!.route = null;
        _visualNavigator = null;
        debugPrint('✅ VisualNavigator cleaned up');
      }

      if (_locationEngine != null) {
        _locationEngine!.stop();
        _locationEngine = null;
        debugPrint('✅ LocationEngine stopped and cleaned up');
      }

      if (_hereMapController != null) {
        final allMarkers = [..._spaceMarkers.keys, ..._eventMarkers.keys];
        if (allMarkers.isNotEmpty) {
          _hereMapController!.mapScene.removeMapMarkers(allMarkers);
        }

        _hereMapController!.camera.setOrientationAtTarget(
          HERE.GeoOrientationUpdate(0, 0),
        );
        debugPrint('✅ Map scene cleaned up');
      }

      if (mounted) {
        setState(() {
          _isNavigating = false;
          _isLoading = false;
          _navigationInstruction = "";
          _roadSpeedLimit = null;
          _isOverSpeedLimit = false;
          _hasShownArrivalNotification = false;
          _hasShownParkingRating = false;
          _isPopupDisplayed = false;
          _isRecalculatingRoute = false;
          _isCameraLocked = true;
          _isUserPanning = false;
          _currentSpeed = 0;
          _isLocationEngineReady = false;
          // _isVisualNavigatorReady = false;
          _stableLocationCount = 0;
          _totalRouteTime = 0;
          _nextManuoverDistance = 0;
          normalManuevers = "";
          _lastSpokenInstruction = "";
          _errorMessage = "";

          _isMapReady = false;
          _isLocationReady = false;
        });
      }
    } catch (e) {
      debugPrint('⚠️ Error during cleanup: $e');
    }

    debugPrint('🧹 Navigation cleanup completed');
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

  Future<bool> _handleBackPress() async {
    debugPrint('🔙 Back button pressed.');
    _cleanupNavigation();
    return true;
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

  void _cleanupCurrentRoute() {
    debugPrint('🧹 Cleaning up current route for destination switch...');

    try {
      if (_routePolylines.isNotEmpty) {
        _hereMapController?.mapScene.removeMapPolylines(_routePolylines);
        _routePolylines.clear();
        debugPrint('✅ Route polylines cleared');
      }

      if (_visualNavigator != null) {
        _visualNavigator!.stopRendering();

        _visualNavigator!.routeProgressListener = null;
        _visualNavigator!.eventTextListener = null;
        _visualNavigator!.routeDeviationListener = null;

        _visualNavigator!.route = null;

        debugPrint('✅ Current route cleared from visual navigator');
      }

      if (_destinationMarker != null) {
        _hereMapController!.mapScene.removeMapMarker(_destinationMarker!);
        _destinationMarker = null;
        debugPrint('✅ Old destination marker removed');
      }

      setState(() {
        _navigationInstruction = "";
        _totalRouteTime = 0;
        _nextManuoverDistance = 0;
        normalManuevers = "";
        _lastSpokenInstruction = "";
        _hasShownArrivalNotification = false;
        _hasShownParkingRating = false;
        _isPopupDisplayed = false;
        _isRecalculatingRoute = false;
      });

      debugPrint('✅ Route cleanup completed successfully');
    } catch (e) {
      debugPrint('⚠️ Error during route cleanup: $e');
    }
  }

  void _switchToNewDestination(Space space) {
    debugPrint('🔄 Switching to new destination: ${space.location.streetName}');

    if (_currentLocation != null) {
      _cleanupCurrentRoute();

      _actualDestinationLat = space.location.point.lat;
      _actualDestinationLng = space.location.point.lng;

      _calculateRoute(
        _currentLocation!,
        HERE.GeoCoordinates(space.location.point.lat, space.location.point.lng),
      );

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

  void _initializeWebSocketConnection() {
    if (_currentLocation == null) {
      debugPrint('⚠️ Current location is null, cannot initialize WebSocket');
      return;
    }

    debugPrint('🔌 Initializing WebSocket connection...');

    _locationWebSocketService.connectAndSendInitialLocation(
      latitude: _currentLocation!.latitude,
      longitude: _currentLocation!.longitude,
      onEvent: (MapNearbyPayload payload) {
        debugPrint(
          '📥 Received WebSocket data: ${payload.spaces.length} spaces, ${payload.events.length} events',
        );
        if (mounted) {
          _addMapMarkers(payload.events, payload.spaces);
        }
      },
      onError: (error) {
        debugPrint('❌ WebSocket error: $error');
      },
      onDone: () {
        debugPrint('🔌 WebSocket connection closed');
      },
    );
  }

  void _addTrafficAwareRoutePolyline(HERE.Route route) {
    if (_hereMapController == null) return;

    debugPrint('🚦 Adding traffic-aware route visualization...');

    if (_routePolylines.isNotEmpty) {
      _hereMapController!.mapScene.removeMapPolylines(_routePolylines);
      _routePolylines.clear();
    }

    for (var section in route.sections) {
      for (var span in section.spans) {
        HERE.GeoPolyline spanGeometry = span.geometry;

        Color trafficColor = _getTrafficColorFromSpan(span);

        try {
          MapPolyline polyline = MapPolyline.withRepresentation(
            spanGeometry,
            MapPolylineSolidRepresentation(
              MapMeasureDependentRenderSize.withSingleSize(
                RenderSizeUnit.pixels,
                16,
              ),
              trafficColor,
              LineCap.round,
            ),
          );

          _hereMapController!.mapScene.addMapPolyline(polyline);
          _routePolylines.add(polyline);
        } catch (e) {
          debugPrint('❌ Error adding traffic polyline for span: $e');
        }
      }
    }

    debugPrint('✅ Added ${_routePolylines.length} traffic polylines');
  }

  Color _getTrafficColorFromSpan(HERE.Span span) {
    if (span.duration.inSeconds > 0 && span.baseDuration.inSeconds > 0) {
      double trafficDelay =
          span.duration.inSeconds / span.baseDuration.inSeconds;

      debugPrint('🚦 Span traffic ratio: $trafficDelay');

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

  Color _getSimpleTrafficColor(HERE.Span span) {
    double delayPercentage =
        ((span.duration.inSeconds - span.baseDuration.inSeconds) /
            span.baseDuration.inSeconds) *
        100;

    if (delayPercentage < 10) return Colors.green;
    if (delayPercentage < 30) return Colors.yellow;
    if (delayPercentage < 60) return Colors.orange;
    return Colors.red;
  }

  void _sendLocationUpdateViaWebSocket(double latitude, double longitude) {
    if (_locationWebSocketService.isConnected) {
      _locationWebSocketService.sendLocation(latitude, longitude);
    } else {
      debugPrint('⚠️ WebSocket not connected, attempting to connect...');
      _locationWebSocketService.connectAndSendInitialLocation(
        latitude: latitude,
        longitude: longitude,
        onEvent: (MapNearbyPayload payload) {
          if (mounted) {
            _addMapMarkers(payload.events, payload.spaces);
          }
        },
        onError: (error) {
          debugPrint('❌ WebSocket error during reconnect: $error');
        },
      );
    }
  }

  void _checkDistanceTrigger(double latitude, double longitude) {
    final distanceBetweenPoints =
        Geolocator.distanceBetween(
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
    _sendLocationUpdateViaWebSocket(_lastLatitude, _lastLongitude);

    context.read<MapBloc>().add(
      GetNearbyPlaces(
        queryParams: MapQueryParams(
          currentPoint: "$_lastLatitude,$_lastLongitude",
          previousPoint: "$_lastLatitude,$_lastLongitude",
          radius: 400,
          drivingMode: true,
          options: ['alerts'],
        ),
      ),
    );
  }

  void putParkingSpacesOnMap() {
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

  void _addMapMarkers(List<Event> events, List<Space> spaces) {
    _updateEventMarkers(events);
    _updateSpaceMarkers(spaces);
  }

  void _updateEventMarkers(List<Event> newEvents) {
    Set<String> newEventIds = newEvents.map((e) => e.id).toSet();
    Set<String> existingEventIds = _eventMarkersById.keys.toSet();
    Set<String> eventsToRemove = existingEventIds.difference(newEventIds);

    for (String eventId in eventsToRemove) {
      MapMarker? marker = _eventMarkersById[eventId];
      if (marker != null) {
        _hereMapController?.mapScene.removeMapMarker(marker);
        _eventMarkers.remove(marker);
        _eventMarkersById.remove(eventId);
        debugPrint("🗑️ Removed outdated event marker: $eventId");
      }
    }

    for (var event in newEvents) {
      MapMarker? existingMarker = _eventMarkersById[event.id];

      if (existingMarker != null) {
        HERE.GeoCoordinates existingCoords = existingMarker.coordinates;
        bool positionChanged =
            existingCoords.latitude != event.location.point.lat ||
            existingCoords.longitude != event.location.point.lng;

        if (positionChanged) {
          _hereMapController?.mapScene.removeMapMarker(existingMarker);
          _eventMarkers.remove(existingMarker);
          _createEventMarker(event);
          debugPrint("📍 Updated event marker position: ${event.id}");
        }
      } else {
        _createEventMarker(event);
        debugPrint("🆕 Added new event marker: ${event.id}");
      }
    }
  }

  void _updateSpaceMarkers(List<Space> newSpaces) {
    Set<String> newSpaceIds = newSpaces.map((s) => s.id).toSet();
    Set<String> existingSpaceIds = _spaceMarkersById.keys.toSet();
    Set<String> spacesToRemove = existingSpaceIds.difference(newSpaceIds);

    for (var space in newSpaces) {
      MapMarker? existingMarker = _spaceMarkersById[space.id];

      if (existingMarker != null) {
        HERE.GeoCoordinates existingCoords = existingMarker.coordinates;
        bool positionChanged =
            existingCoords.latitude != space.location.point.lat ||
            existingCoords.longitude != space.location.point.lng;

        Space? existingSpace = _spaceMarkers[existingMarker];
        bool typeChanged = existingSpace?.type != space.type;

        if (positionChanged || typeChanged) {
          _hereMapController?.mapScene.removeMapMarker(existingMarker);
          _spaceMarkers.remove(existingMarker);
          _spaceMarkersById.remove(space.id);
          _createSpaceMarker(space);
          debugPrint("📍 Updated space marker: ${space.id}");
        } else {
          _spaceMarkers[existingMarker] = space;
          debugPrint("✅ Space marker unchanged: ${space.id}");
        }
      } else {
        _createSpaceMarker(space);
        debugPrint("🆕 Added new space marker: ${space.id}");
      }
    }
  }

  void _createSpaceMarker(Space space) {
    try {
      final imageData = _assetsProvider.getImageForType(space.type);
      final marker = MapMarker(
        HERE.GeoCoordinates(space.location.point.lat, space.location.point.lng),
        MapImage.withPixelDataAndImageFormat(imageData, ImageFormat.png),
      );
      marker.fadeDuration = const Duration(seconds: 1);

      _hereMapController?.mapScene.addMapMarker(marker);
      _spaceMarkers[marker] = space;
      _spaceMarkersById[space.id] = marker;
    } catch (e) {
      debugPrint("Error adding space marker: $e");
    }
  }

  void _createEventMarker(Event event) {
    try {
      Uint8List imageData = _assetsProvider.getEventIcon(event.type);
      MapImage mapImage = MapImage.withPixelDataAndImageFormat(
        imageData,
        ImageFormat.png,
      );

      final marker = MapMarker(
        HERE.GeoCoordinates(event.location.point.lat, event.location.point.lng),
        mapImage,
      );
      marker.fadeDuration = const Duration(milliseconds: 300);

      _hereMapController?.mapScene.addMapMarker(marker);
      _eventMarkers[marker] = event;
      _eventMarkersById[event.id] = marker;
    } catch (e) {
      debugPrint("Error adding event marker: $e");
    }
  }

  void _pickMapMarker(HERE.Point2D touchPoint) {
    final rectangle = HERE.Rectangle2D(touchPoint, HERE.Size2D(1, 1));
    final filter = MapSceneMapPickFilter([
      MapSceneMapPickFilterContentType.mapItems,
    ]);

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

  void showSpacePopup({required Space space}) {
    if (space.isPremium) {
      AppPopup.showBottomSheet(
        context,
        SpacePopupSheet(
          space: space,
          currentPosition: HERE.GeoCoordinates(
            _currentLocation!.latitude,
            _currentLocation!.longitude,
          ),
          onRefreshTrigger: () {
            context.read<MapBloc>().add(
              GetNearbyPlaces(
                queryParams: MapQueryParams(
                  currentPoint:
                      "${_currentLocation!.latitude},${_currentLocation!.longitude}",
                  radius: 8000,
                  drivingMode: false,
                  options: ['spaces', 'events'],
                ),
              ),
            );
            NavigatorHelper.pop();
            NavigatorHelper.pop();
          },
        ),
      );
      return;
    }

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
                                  space.type,
                                  context,
                                ),
                                style: Typo.largeBody.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            space.location.streetName,
                            style: Typo.largeBody.copyWith(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: AppColors.neutral600,
                            ),
                          ),
                          Dimens.space(1),
                          DecoratedChip(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 5,
                            ),
                            text:
                                '${parseMeters(Geolocator.distanceBetween(_currentLocation!.latitude, _currentLocation!.longitude, space.location.point.lat, space.location.point.lng))} away',
                            textStyle: Typo.smallBody.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.green600,
                            ),
                            icon: Iconsax.clock,
                            color: AppColors.green500,
                          ),
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

  void _showToast(String message, {Color backgroundColor = Colors.black}) {
    // Toast implementation
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
                title:
                    alert.type.toLowerCase() == "camera"
                        ? context.l10n.cameraAlertTitle
                        : context.l10n.radarAlertTitle,
                subtext:
                    alert.type.toLowerCase() == "camera"
                        ? context.l10n.cameraAlertMessage
                        : context.l10n.radarAlertMessage,
              );
            }
          }
        }
      },
      builder: (context, state) {
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) async {
            if (!didPop) {
              final shouldExit = await _handleBackPress();
              if (shouldExit) {
                Navigator.of(context).pop(result);
              }
            }
          },
          child: Scaffold(
            body: NavigateContent(
              onMapCreated: _onMapCreated,
              isLimit: _isOverSpeedLimit,
              isOpenRoutes: _isOpenRoutes,
              isCameraLocked: _isCameraLocked,
              speed: _currentSpeed,
              heightContainer: _heightContainer,
              isLoading: _isLoading,
              routesList: routesList,
              toggleCameraTracking: _toggleCameraTracking,
              isNavigating: _isNavigating,
              errorMessage: _errorMessage,
              isMuted: _isMuted,
              navigationInstruction: _navigationInstruction,
              normalManuevers: normalManuevers,
              distanceNotifier: _distanceNotifier,
              nextManuoverDistance: _nextManuoverDistance,
              isLocationReady: _isLocationReady,
              isMapReady: _isMapReady,
              isRecalculatingRoute: _isRecalculatingRoute,
              stopNavigation: _stopNavigation,
              indexRoute: indexRouteSelected,
              openRouter: () async {
                if (routesList.length > 1) {
                  _isOpenRoutes = !_isOpenRoutes;
                  setState(() {});
                } else {
                  await AppPopup.showDialogSheet(
                    context,
                    ConfirmationDialog(
                      isError: true,
                      title: 'Rutas alternativas',
                      subtext:
                          'No se encontraron más opciones de ruta disponibles.',
                      onProceed: () {
                        NavigatorHelper.pop();
                      },
                    ),
                  );
                }
              },
              startGuidance: (i) {
                final value = routesList[i];
                _totalRouteTime = value.duration.inSeconds;
                _distanceNotifier.value = value.lengthInMeters;
                _addDestinationMarker(value);
                _setMapCameraFocus();
                // _resetNavigation();
                _cleanupCurrentRoute();
                _startGuidance(value);
                indexRouteSelected = i;
                // setState(() {});
              },
              totalRouteTime: _totalRouteTime.toFormattedTime(),
              distanceValue: _distanceNotifier.value.toFormattedDistance(),
              onError: () {
                setState(() {
                  _errorMessage = "";
                  _isLoading = false;
                  _isMapReady = false;
                  _isLocationReady = false;
                });
                _requestLocationPermission();
              },
              onMuted: () {
                setState(() {
                  _isMuted = !_isMuted;
                  if (_visualNavigator != null) {
                    debugPrint('🔊 Voice ${_isMuted ? 'muted' : 'unmuted'}');
                  }
                });
                if (_isMuted) {
                  speech.mute();
                } else {
                  speech.unmute();
                  _configureTTSLanguage();
                }
              },
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
