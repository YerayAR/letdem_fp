import 'dart:async';
import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:flashy_flushbar/flashy_flushbar_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart' as geolocator;
import 'package:here_sdk/core.dart';
import 'package:here_sdk/core.engine.dart';
import 'package:here_sdk/core.errors.dart';
import 'package:here_sdk/mapview.dart';
// http
import 'package:http/http.dart' as http;
import 'package:iconly/iconly.dart';
import 'package:letdem/constants/credentials.dart';
import 'package:letdem/constants/ui/colors.dart';
import 'package:letdem/constants/ui/dimens.dart';
import 'package:letdem/enums/EventTypes.dart';
import 'package:letdem/features/activities/activities_bloc.dart';
import 'package:letdem/features/activities/repositories/activity.repository.dart';
import 'package:letdem/features/auth/auth_bloc.dart';
import 'package:letdem/features/auth/repositories/auth.repository.dart';
import 'package:letdem/features/car/car_bloc.dart';
import 'package:letdem/features/car/repository/car.repository.dart';
import 'package:letdem/features/map/map_bloc.dart';
import 'package:letdem/features/map/repository/map.repository.dart';
import 'package:letdem/features/scheduled_notifications/repository/schedule_notifications.repository.dart';
import 'package:letdem/features/scheduled_notifications/schedule_notifications_bloc.dart';
import 'package:letdem/features/search/repository/search_location.repository.dart';
import 'package:letdem/features/search/search_location_bloc.dart';
import 'package:letdem/features/users/repository/user.repository.dart';
import 'package:letdem/features/users/user_bloc.dart';
import 'package:letdem/global/popups/popup.dart';
import 'package:letdem/global/widgets/button.dart';
import 'package:letdem/global/widgets/chip.dart';
import 'package:letdem/models/auth/map/map_options.model.dart';
import 'package:letdem/models/auth/map/nearby_payload.model.dart';
import 'package:letdem/models/map/coordinate.model.dart';
import 'package:letdem/services/map/map_asset_provider.service.dart';
import 'package:letdem/services/res/navigator.dart';
import 'package:letdem/services/toast/toast.dart';
import 'package:letdem/views/app/home/widgets/home/no_connection.widget.dart';
import 'package:letdem/views/app/home/widgets/home/shimmers/home_page_shimmer.widget.dart';
import 'package:letdem/views/app/profile/screens/scheduled_notifications/scheduled_notifications.view.dart';
import 'package:letdem/views/app/profile/widgets/settings_container.widget.dart';
import 'package:letdem/views/app/publish_space/screens/publish_space.view.dart';
import 'package:letdem/views/auth/views/onboard/verify_account.view.dart';
import 'package:letdem/views/welcome/views/splash.view.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mapbox;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import 'firebase_options.dart';

void _initializeHERESDK() async {
  // Needs to be called before accessing SDKOptions to load necessary libraries.
  SdkContext.init(IsolateOrigin.main);

  // Set your credentials for the HERE SDK.
  String accessKeyId = AppCredentials.hereAccessKeyId;
  String accessKeySecret = AppCredentials.hereAccessKeySecret;
  AuthenticationMode authenticationMode =
      AuthenticationMode.withKeySecret(accessKeyId, accessKeySecret);
  SDKOptions sdkOptions = SDKOptions.withAuthenticationMode(authenticationMode);

  try {
    await SDKNativeEngine.makeSharedInstance(sdkOptions);
  } on InstantiationException {
    throw Exception("Failed to initialize the HERE SDK.");
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _initializeHERESDK();
  MapboxOptions.setAccessToken(AppCredentials.mapBoxAccessToken);

  OneSignal.initialize(AppCredentials.oneSignalAppId);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>(
          create: (_) => AuthRepository(),
        ),
        RepositoryProvider<UserRepository>(
          create: (_) => UserRepository(),
        ),
        RepositoryProvider<ActivityRepository>(
          create: (_) => ActivityRepository(),
        ),
        RepositoryProvider(
          create: (_) => SearchLocationRepository(),
        ),
        RepositoryProvider(
          create: (_) => CarRepository(),
        ),
        RepositoryProvider(
          create: (_) => MapRepository(),
        ),
        RepositoryProvider(
          create: (_) => ScheduleNotificationsRepository(),
        ),
      ],
      child: MultiBlocProvider(providers: [
        BlocProvider(
          create: (context) => MapBloc(
            mapRepository: context.read<MapRepository>(),
          ),
        ),
        BlocProvider(
          create: (context) => ScheduleNotificationsBloc(
            scheduleNotificationsRepository:
                context.read<ScheduleNotificationsRepository>(),
          ),
        ),
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(
            authRepository: context.read<AuthRepository>(),
          ),
        ),
        BlocProvider(
          create: (context) => SearchLocationBloc(
            searchLocationRepository: context.read<SearchLocationRepository>(),
          ),
        ),
        BlocProvider<UserBloc>(
          create: (context) => UserBloc(
            userRepository: context.read<UserRepository>(),
          ),
        ),
        BlocProvider<ActivitiesBloc>(
          create: (context) => ActivitiesBloc(
            activityRepository: context.read<ActivityRepository>(),
          ),
        ),
        BlocProvider(
          create: (context) => CarBloc(
            carRepository: context.read<CarRepository>(),
          ),
        ),
      ], child: const LetDemApp()),
    ),
  );
}

class LetDemApp extends StatelessWidget {
  const LetDemApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        builder: FlashyFlushbarProvider.init(),
        theme: ThemeData(
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.white,
            titleTextStyle: TextStyle(
              color: AppColors.neutral600,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
            elevation: 0,
          ),
          scaffoldBackgroundColor: AppColors.scaffoldColor,
          fontFamily: 'DMSans',
        ),
        navigatorKey: NavigatorHelper.navigatorKey,
        debugShowCheckedModeBanner: false,
        debugShowMaterialGrid: false,
        home: const SplashView());
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AppLifecycleListener _appLifecycleListener;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HERE SDK for Flutter - Hello Map!',
      home: HereMap(onMapCreated: _onMapCreated),
    );
  }

  void _onMapCreated(HereMapController hereMapController) {
    // The camera can be configured before or after a scene is loaded.
    const double distanceToEarthInMeters = 8000;
    MapMeasure mapMeasureZoom =
        MapMeasure(MapMeasureKind.distanceInMeters, distanceToEarthInMeters);
    hereMapController.camera.lookAtPointWithMeasure(
        GeoCoordinates(52.530932, 13.384915), mapMeasureZoom);

    // Load the map scene using a map scheme to render the map with.
    hereMapController.mapScene.loadSceneForMapScheme(MapScheme.normalDay,
        (error) {
      if (error != null) {
        print('Map scene not loaded. MapError: ${error.toString()}');
      }
    });
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
}

class PolyMapView extends StatefulWidget {
  const PolyMapView({super.key});

  @override
  State<PolyMapView> createState() => _HomeViewState();
}

class _HomeViewState extends State<PolyMapView>
    with AutomaticKeepAliveClientMixin {
  mapbox.Position? _currentPosition;
  bool isLocationLoading = false;
  late mapbox.CameraOptions _cameraPosition;
  late mapbox.MapboxMap mapboxController;
  mapbox.PointAnnotationManager? pointAnnotationManager;
  final MapAssetsProvider _assetsProvider = MapAssetsProvider();

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _loadAssets();
    setupPositionTracking();
  }

  bool isLoadingAssets = true;

  Future<void> _loadAssets() async {
    await _assetsProvider.loadAssets();
    setState(() {
      isLoadingAssets = false;
    });
  }

  bool hasNoPermission = false;

  Future<void> _getCurrentLocation() async {
    try {
      setState(() {
        isLocationLoading = true;
      });
      bool serviceEnabled =
          await geolocator.Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await geolocator.Geolocator.requestPermission();
      }

      geolocator.LocationPermission permission =
          await geolocator.Geolocator.checkPermission();
      if (permission == geolocator.LocationPermission.denied ||
          permission == geolocator.LocationPermission.deniedForever) {
        setState(() {
          hasNoPermission = true;
          isLocationLoading = false;
        });
        permission = await geolocator.Geolocator.requestPermission();
      }

      if (permission == geolocator.LocationPermission.whileInUse ||
          permission == geolocator.LocationPermission.always) {
        var position = await geolocator.Geolocator.getCurrentPosition(
          desiredAccuracy: geolocator.LocationAccuracy.high,
        );

        setState(() {
          isLocationLoading = false;

          _currentPosition =
              mapbox.Position(position.longitude, position.latitude);
          _cameraPosition = mapbox.CameraOptions(
            center: mapbox.Point(
              coordinates:
                  mapbox.Position(position.longitude, position.latitude),
            ),
            zoom: 15,
            bearing: 0,
            pitch: 0,
          );
        });

        if (_currentPosition != null) {
          context.read<MapBloc>().add(GetNearbyPlaces(
                queryParams: MapQueryParams(
                  currentPoint: "${position.latitude},${position.longitude}",
                  radius: 8000,
                  drivingMode: false,
                  options: ['spaces', 'events'],
                ),
              ));
        }
      }
    } catch (e) {
      setState(() {
        isLocationLoading = false;
      });
      debugPrint("Error getting location: $e");
    }
  }

  @override
  void dispose() {
    _currentPosition = null;
    _positionStreamSubscription?.cancel();

    super.dispose();
  }

  Uint8List getEventIcon(
    EventTypes type,
    Uint8List policeMapMarkerImageData,
    Uint8List closedRoadMapMarkerImageData,
    Uint8List accidentMapMarkerImageData,
  ) {
    switch (type) {
      case EventTypes.accident:
        return accidentMapMarkerImageData;
      case EventTypes.police:
        return policeMapMarkerImageData;
      case EventTypes.closeRoad:
        return closedRoadMapMarkerImageData;
    }
  }

  Uint8List getImageData(
    PublishSpaceType type,
    Uint8List freeMarkerImageData,
    Uint8List greenMarkerImageData,
    Uint8List blueMapMarkerImageData,
    Uint8List disasterMapMarkerImageData,
  ) {
    switch (type) {
      case PublishSpaceType.free:
        return freeMarkerImageData;
      case PublishSpaceType.greenZone:
        return greenMarkerImageData;
      case PublishSpaceType.blueZone:
        return blueMapMarkerImageData;
      case PublishSpaceType.disabled:
        return disasterMapMarkerImageData;
    }
  }

  void _addAnnotations(
    List<Space> spaces,
    List<Event> events,
  ) {
    for (var element in spaces) {
      pointAnnotationManager?.create(
        mapbox.PointAnnotationOptions(
          geometry: mapbox.Point(
              coordinates: mapbox.Position(
                  element.location.point.lng, element.location.point.lat)),
          iconSize: 1.3,
          image: _assetsProvider.getImageForType(element.type),
        ),
      );
    }

    for (var element in events) {
      pointAnnotationManager?.create(
        mapbox.PointAnnotationOptions(
          geometry: mapbox.Point(
              coordinates: mapbox.Position(
                  element.location.point.lng, element.location.point.lat)),
          iconSize: 1.3,
          image: _assetsProvider.getEventIcon(element.type),
        ),
      );
    }
  }

  StreamSubscription? _positionStreamSubscription;

  setupPositionTracking() async {
    _positionStreamSubscription?.cancel();
    _positionStreamSubscription =
        geolocator.Geolocator.getPositionStream().listen((position) {
      //     calculate distance between two points

      double distanceInMeters = geolocator.Geolocator.distanceBetween(
        _currentPosition!.lat.toDouble(),
        _currentPosition!.lng.toDouble(),
        position.latitude,
        position.longitude,
      );
      // run a code and reset the current position to the new position if the distance is greater than 100 meters
      if (distanceInMeters > 300) {
        _currentPosition =
            mapbox.Position(position.longitude, position.latitude);
        context.read<MapBloc>().add(GetNearbyPlaces(
              queryParams: MapQueryParams(
                currentPoint: "${position.latitude},${position.longitude}",
                radius: 600,
                drivingMode: false,
                options: ['spaces', 'events'],
              ),
            ));
      }

      // only update the camera position if the distance is greater than 100 meters
      if (distanceInMeters > 100) {
        mapboxController.setCamera(
          mapbox.CameraOptions(
            center: mapbox.Point(
              coordinates: mapbox.Position(
                position.longitude,
                position.latitude,
              ),
            ),
            zoom: 15,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return isLocationLoading
        ? const HomePageShimmer()
        : hasNoPermission
            ? const NoMapPermissionSection()
            : BlocConsumer<MapBloc, MapState>(
                listener: (context, state) {},
                builder: (context, state) {
                  return Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      mapbox.MapWidget(
                        key: UniqueKey(),
                        onMapCreated: (controller) async {
                          mapboxController = controller;

                          mapboxController.scaleBar.updateSettings(
                            mapbox.ScaleBarSettings(enabled: false),
                          );
                          mapboxController.compass.updateSettings(
                            mapbox.CompassSettings(enabled: false),
                          );
                          mapboxController.location.updateSettings(
                            mapbox.LocationComponentSettings(
                              enabled: true,
                              pulsingEnabled: true,
                              puckBearingEnabled: true,
                              pulsingMaxRadius: 40,
                              showAccuracyRing: true,
                              accuracyRingBorderColor: 0xffD899FF,
                              accuracyRingColor: 0xffD899FF,
                              pulsingColor: 0xffD899FF,
                            ),
                          );

                          await mapboxController
                              .setBounds(mapbox.CameraBoundsOptions(
                            maxZoom: 18,
                            minZoom: 12,
                          ));
                          pointAnnotationManager = await mapboxController
                              .annotations
                              .createPointAnnotationManager();

                          if (mounted && state is MapLoaded) {
                            _addAnnotations(
                              (state).payload.spaces,
                              (state).payload.events,
                            );
                          }
                        },
                        styleUri: mapbox.MapboxStyles.MAPBOX_STREETS,
                        cameraOptions: _cameraPosition,
                      ),
                    ],
                  );
                },
              );
  }

  @override
  bool get wantKeepAlive => true;
}

// class TrafficRouteLineExample extends StatefulWidget {
//   const TrafficRouteLineExample({super.key});
//
//   @override
//   State<TrafficRouteLineExample> createState() =>
//       TrafficRouteLineExampleState();
// }
//
// class TrafficRouteLineExampleState extends State<TrafficRouteLineExample> {
//   late MapboxMap mapboxMap;
//   final _sfAirport = mapbox.Point(
//       coordinates: mapbox.Position(-122.39470445734368, 37.7080221537549));
//   final _sfDowntown = mapbox.Position(-122.41941, 37.77493);
//   bool _isRouteLoaded = false;
//
//   _onMapCreated(MapboxMap mapboxMap) async {
//     this.mapboxMap = mapboxMap;
//   }
//
//   _onStyleLoadedCallback(StyleLoadedEventData data) async {
//     await _addRouteSource();
//     await _addRouteLine();
//     await _fetchRouteData();
//   }
//
//   Future<void> _addRouteSource() async {
//     await mapboxMap.style.addSource(GeoJsonSource(
//       id: "line",
//       data: json.encode({"type": "FeatureCollection", "features": []}),
//     ));
//   }
//
//   Future<void> _fetchRouteData() async {
//     try {
//       final coordinates =
//           "${_sfAirport.coordinates.lng},${_sfAirport.coordinates.lat};" +
//               "${_sfDowntown.lng},${_sfDowntown.lat}";
//
//       final url =
//           'https://api.mapbox.com/directions/v5/mapbox/driving/$coordinates' +
//               '?alternatives=true' +
//               '&geometries=geojson' +
//               '&overview=full' +
//               '&steps=false' +
//               '&access_token=${AppCredentials.mapBoxAccessToken}';
//
//       final response = await http.get(Uri.parse(url));
//
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//
//         final route = data['routes'][0];
//         final geometry = route['geometry'];
//
//         final geoJson = {
//           "type": "Feature",
//           "properties": {"route-color": "rgb(51, 102, 255)"},
//           "geometry": geometry
//         };
//
//         // Use the correct method to update the GeoJSON source
//         await mapboxMap.style.updateGeoJSONSourceFeatures(
//           "line",
//           json.encode({
//             "type": "FeatureCollection",
//             "features": [geoJson]
//           }),
//           [
//             Feature(id: "line", geometry: LineString.fromJson(geometry)),
//           ],
//         );
//
//         setState(() {
//           _isRouteLoaded = true;
//         });
//       } else {
//         print('Failed to load route data: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('Error fetching route data: $e');
//     }
//   }
//
//   Future<void> _addRouteLine() async {
//     await mapboxMap.style.addLayer(LineLayer(
//       id: "line-layer",
//       sourceId: "line",
//       lineColor: Colors.blue.value,
//       lineWidthExpression: [
//         'interpolate',
//         ['exponential', 1.5],
//         ['zoom'],
//         4.0,
//         2.0,
//         10.0,
//         4.0,
//         13.0,
//         6.0,
//         16.0,
//         8.0,
//         19.0,
//         10.0,
//         22.0,
//         14.0,
//       ],
//       lineBorderColor: Colors.black.value,
//       lineBorderWidthExpression: [
//         'interpolate',
//         ['exponential', 1.5],
//         ['zoom'],
//         9.0,
//         1.0,
//         16.0,
//         3.0,
//       ],
//     ));
//   }
//
//   // Fix the traffic layer logic
//   Future<void> _addTrafficLayer() async {
//     try {
//       // Check if the traffic layer already exists
//
//       // If the layer exists, we can toggle its visibility instead of adding it again
//
//       // Otherwise, add the traffic layer
//       await mapboxMap.style.addLayer(LineLayer(
//         id: "traffic",
//         sourceId: "mapbox", // Changed from "composite" to "mapbox"
//         sourceLayer: "road_traffic", // Changed from "traffic" to "road_traffic"
//         lineWidth: 5.0,
//         lineColorExpression: [
//           'match',
//           ['get', 'congestion'],
//           'low',
//           'rgb(65, 244, 65)',
//           'moderate',
//           'rgb(244, 209, 65)',
//           'heavy',
//           'rgb(244, 130, 65)',
//           'severe',
//           'rgb(244, 65, 65)',
//           'rgb(65, 65, 244)', // Default color
//         ],
//       ));
//     } catch (e) {
//       print('Error adding traffic layer: $e');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       floatingActionButton: Padding(
//         padding: const EdgeInsets.all(12.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.end,
//           children: <Widget>[
//             FloatingActionButton(
//               heroTag: "refreshRoute",
//               onPressed: _fetchRouteData,
//               child: const Icon(Icons.refresh),
//               tooltip: "Refresh route data",
//             ),
//             const SizedBox(height: 10),
//             FloatingActionButton(
//               heroTag: "toggleTraffic",
//               onPressed: _addTrafficLayer,
//               child: const Icon(Icons.traffic),
//               tooltip: "Show traffic data",
//             ),
//           ],
//         ),
//       ),
//       body: MapWidget(
//         key: const ValueKey("mapWidget"),
//         cameraOptions: CameraOptions(
//           center: _sfAirport,
//           zoom: 11.0,
//         ),
//         textureView: true,
//         onMapCreated: _onMapCreated,
//         onStyleLoadedListener: _onStyleLoadedCallback,
//       ),
//     );
//   }
// }

class TrafficRouteLineExample extends StatefulWidget {
  final double lat;
  final double lng;

  final String streetName;

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
  late MapboxMap mapboxMap;

  Future _fetchRouteData() async {
    try {
      var currentLocation = await geolocator.Geolocator.getCurrentPosition();
      final coordinates =
          "${currentLocation.longitude},${currentLocation.latitude};"
          "${widget.lng},${widget.lat}";

      final url =
          'https://api.mapbox.com/directions/v5/mapbox/driving/$coordinates?alternatives=true&geometries=geojson&overview=full&steps=false&access_token=${AppCredentials.mapBoxAccessToken}';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        final route = data['routes'][0];
        final geometry = route['geometry'];

        final geoJson = {
          "type": "Feature",
          "properties": {"route-color": "rgb(51, 102, 255)"},
          "geometry": geometry
        };

        return geoJson;
      } else {
        print('Failed to load route data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching route data: $e');
    }
  }

  _onMapCreated(MapboxMap mapboxMap) async {
    this.mapboxMap = mapboxMap;
  }

  _onStyleLoadedCallback(StyleLoadedEventData data) async {
    var geoJson = await _fetchRouteData();
    // Add the GeoJSON source to the map from api

    await mapboxMap.style
        .addSource(GeoJsonSource(id: "line", data: json.encode(geoJson)));
    await _addRouteLine();
  }

  final bool _isRouteLoaded = false;

  _addRouteLine() async {
    await mapboxMap.style.addLayer(LineLayer(
      id: "line-layer",
      sourceId: "line",
      lineBorderColor: Colors.black.value,
      // Defines a line-width, line-border-width and line-color at different zoom extents
      // by interpolating exponentially between stops.
      // Doc: https://docs.mapbox.com/style-spec/reference/expressions/
      lineWidthExpression: [
        'interpolate',
        ['exponential', 1.5],
        ['zoom'],
        4.0,
        6.0,
        10.0,
        7.0,
        13.0,
        9.0,
        16.0,
        3.0,
        19.0,
        7.0,
        22.0,
        21.0,
      ],
      lineBorderWidthExpression: [
        'interpolate',
        ['exponential', 1.5],
        ['zoom'],
        9.0,
        1.0,
        16.0,
        3.0,
      ],
      lineColorExpression: [
        'interpolate',
        ['linear'],
        ['zoom'],
        8.0,
        'rgb(51, 102, 255)',
        11.0,
        [
          'coalesce',
          ['get', 'route-color'],
          'rgb(51, 102, 255)'
        ],
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
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
            MapWidget(
                key: UniqueKey(),
                cameraOptions: CameraOptions(
                    center: mapbox.Point(
                      coordinates: mapbox.Position(widget.lng, widget.lat),
                    ),
                    zoom: 12.0),
                textureView: true,
                onMapCreated: _onMapCreated,
                onStyleLoadedListener: _onStyleLoadedCallback),
            Positioned(
                left: 0,
                bottom: 0,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: NavigateNotificationCard(
                    hideToggle: widget.hideToggle,
                    notification: ScheduledNotification(
                        id: "1",
                        startsAt: DateTime.now(),
                        endsAt: DateTime.now(),
                        isExpired: false,
                        location: LocationData(
                          streetName: widget.streetName,
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

  final bool hideToggle;
  const NavigateNotificationCard(
      {super.key, required this.notification, required this.hideToggle});

  @override
  State<NavigateNotificationCard> createState() =>
      _NavigateNotificationCardState();
}

class _NavigateNotificationCardState extends State<NavigateNotificationCard> {
  bool notifyAvailableSpace = false;
  double radius = 100;

  bool isLocationAvailable = false;

  double distance = 0.0;

  TimeOfDay _fromTime = TimeOfDay.now();
  final TimeOfDay _toTime = TimeOfDay.now();

  DateTime _fromDate = DateTime.now();
  DateTime _toDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    getDistance();
  }

  void getDistance() async {
    // Check if location services are enabled
    setState(() {
      isLocationAvailable = false;
    });

    var currentLocation = await geolocator.Geolocator.getCurrentPosition(
        desiredAccuracy: geolocator.LocationAccuracy.best);

    // Get distance between two points
    distance = geolocator.Geolocator.distanceBetween(
        widget.notification.location.point.latitude,
        widget.notification.location.point.longitude,
        currentLocation.latitude,
        currentLocation.longitude);
    print('Distance: $distance');

    setState(() {
      isLocationAvailable = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ScheduleNotificationsBloc, ScheduleNotificationsState>(
      listener: (context, state) {
        if (state is ScheduleNotificationCreated) {
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
          child: Column(
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

                          "00 mins ${(distance / 1000).toStringAsFixed(1)} km",
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
                              text: "Moderate",
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
                        const Icon(IconlyLight.location, color: Colors.grey),
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
                    const Row(
                      children: [
                        Icon(IconlyLight.time_circle, color: Colors.grey),
                        SizedBox(width: 8),
                        Text(
                          "To Arrive in by 12:38pm",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    Divider(color: Colors.grey.withOpacity(0.2)),
                    SizedBox(height: 16),

                    // Notification toggle
                    Row(
                      children: widget.hideToggle
                          ? []
                          : [
                              const Icon(IconlyLight.notification,
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
                                    notifyAvailableSpace = value;
                                  });
                                },
                              ),
                            ],
                    ),
                    SizedBox(height: widget.hideToggle ? 0 : 16),

                    // Time selection buttons
                    Column(
                      children: !notifyAvailableSpace
                          ? []
                          : [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  PlatformTimePickerButton(
                                      initialTime: _fromTime,
                                      onTimeSelected: (time) {
                                        setState(() {
                                          _fromTime = time;
                                        });
                                      }),
                                  const SizedBox(width: 16),
                                  PlatformTimePickerButton(
                                      initialTime: _toTime,
                                      onTimeSelected: (time) {
                                        setState(() {
                                          _fromTime = time;
                                        });
                                      }),
                                ],
                              ),
                              Row(
                                children: [
                                  PlatformDatePickerButton(
                                      initialDate: _fromDate,
                                      onDateSelected: (date) {
                                        setState(() {
                                          _fromDate = date;
                                        });
                                      }),
                                  const SizedBox(width: 16),
                                  PlatformDatePickerButton(
                                      initialDate: _toDate,
                                      onDateSelected: (date) {
                                        setState(() {
                                          _toDate = date;
                                        });
                                      }),
                                ],
                              ),
                              const SizedBox(height: 24),

                              // Radius slider
                              Row(
                                children: [
                                  const Text(
                                    "Radius (Meters)",
                                    style: TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    radius.toStringAsFixed(0),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  activeTrackColor: Colors.purple,
                                  inactiveTrackColor:
                                      Colors.purple.withOpacity(0.2),
                                  thumbColor: Colors.white,
                                  overlayColor: Colors.purple.withOpacity(0.2),
                                  thumbShape: const RoundSliderThumbShape(
                                      enabledThumbRadius: 8),
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

                    // Reschedule button
                    PrimaryButton(
                      isLoading: state is ScheduleNotificationsLoading,
                      onTap: () {
                        if (notifyAvailableSpace) {
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

                          if (end.isBefore(start)) {
                            Toast.show('End time cannot be before start time');
                            return;
                          }

                          // check if the start or end time is in the past
                          if (start.isBefore(DateTime.now())) {
                            Toast.show('Start time cannot be in the past');
                            return;
                          }
                          if (end.isBefore(DateTime.now())) {
                            Toast.show('End time cannot be in the past');
                            return;
                          }

                          if (radius < 100) {
                            Toast.show('Radius cannot be less than 100 meters');
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
                        }
                        // Schedule notification
                        // Navigator.pop(context);
                      },
                      icon: !notifyAvailableSpace ? IconlyBold.location : null,
                      text: notifyAvailableSpace ? "Save" : "Start Route",
                    ),
                    Dimens.space(2)
                  ],
          ),
        );
      },
    );
  }
}
