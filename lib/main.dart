import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:flashy_flushbar/flashy_flushbar_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:letdem/constants/credentials.dart';
import 'package:letdem/constants/ui/colors.dart';
import 'package:letdem/features/activities/activities_bloc.dart';
import 'package:letdem/features/activities/repositories/activity.repository.dart';
import 'package:letdem/features/auth/auth_bloc.dart';
import 'package:letdem/features/auth/repositories/auth.repository.dart';
import 'package:letdem/features/car/car_bloc.dart';
import 'package:letdem/features/car/repository/car.repository.dart';
import 'package:letdem/features/map/map_bloc.dart';
import 'package:letdem/features/map/repository/map.repository.dart';
import 'package:letdem/features/search/repository/search_location.repository.dart';
import 'package:letdem/features/search/search_location_bloc.dart';
import 'package:letdem/features/users/repository/user.repository.dart';
import 'package:letdem/features/users/user_bloc.dart';
import 'package:letdem/services/res/navigator.dart';
import 'package:letdem/views/welcome/views/splash.view.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MapboxOptions.setAccessToken(AppCredentials.mapBoxAccessToken);

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
      ],
      child: MultiBlocProvider(providers: [
        BlocProvider(
          create: (context) => MapBloc(
            mapRepository: context.read<MapRepository>(),
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
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'DMSans',
      ),
      navigatorKey: NavigatorHelper.navigatorKey,
      debugShowCheckedModeBanner: false,
      debugShowMaterialGrid: false,
      home: SplashView(),
    );
  }
}

class TrafficRouteLineExample extends StatefulWidget implements Example {
  @override
  final Widget leading = const Icon(Icons.directions);
  @override
  final String title = 'Dynamic Route with Traffic';
  @override
  final String subtitle = "Shows a dynamic route based on user selection.";

  @override
  State createState() => TrafficRouteLineExampleState();
}

class TrafficRouteLineExampleState extends State<TrafficRouteLineExample> {
  late MapboxMap mapboxMap;
  static const String mapboxToken =
      "YOUR_MAPBOX_ACCESS_TOKEN"; // Replace with your Mapbox token
  final startPoint = Position(-118.2437, 34.0522); // Los Angeles, CA
  final endPoint = Position(-122.4194, 37.7749); // San Francisco, CA

  _onMapCreated(MapboxMap mapboxMap) async {
    this.mapboxMap = mapboxMap;
  }

  _onStyleLoadedCallback(StyleLoadedEventData data) async {
    await _fetchAndDisplayRoute();
  }

  /// Fetch Route from Mapbox API
  Future<void> _fetchAndDisplayRoute() async {
    final url =
        "https://api.mapbox.com/directions/v5/mapbox/driving/${startPoint.lng},${startPoint.lat};${endPoint.lng},${endPoint.lat}?geometries=geojson&access_token=${AppCredentials.mapBoxAccessToken}";

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final routeData = jsonDecode(response.body);
      final routeCoordinates =
          routeData["routes"][0]["geometry"]["coordinates"] as List;

      final geoJson = {
        "type": "FeatureCollection",
        "features": [
          {
            "type": "Feature",
            "geometry": {"type": "LineString", "coordinates": routeCoordinates}
          }
        ]
      };

      await mapboxMap.style.addSource(GeoJsonSource(
        id: "route-source",
        data: jsonEncode(geoJson),
      ));

      await _addRouteLine();
    } else {
      print("Error fetching route: ${response.body}");
    }
  }

  _addRouteLine() async {
    await mapboxMap.style.addLayer(LineLayer(
      id: "route-layer",
      sourceId: "route-source",
      lineBorderColor: Colors.black.value,
      lineWidthExpression: [
        'interpolate',
        ['linear'],
        ['zoom'],
        4.0,
        6.0,
        16.0,
        9.0
      ],
      lineColorExpression: ['rgb', 255, 0, 0], // Red color for the route
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _fetchAndDisplayRoute,
        child: const Icon(Icons.refresh),
      ),
      body: MapWidget(
        key: const ValueKey("mapWidget"),
        cameraOptions: CameraOptions(
          center: Point(coordinates: startPoint),
          zoom: 6.0,
        ),
        textureView: true,
        onMapCreated: _onMapCreated,
        onStyleLoadedListener: _onStyleLoadedCallback,
      ),
    );
  }
}

abstract interface class Example extends Widget {
  Widget get leading;
  String get title;
  String? get subtitle;
}
