import 'package:flutter/material.dart';
import 'package:letdem/constants/credentials.dart';
import 'package:letdem/services/res/navigator.dart';
import 'package:letdem/views/welcome/views/splash.view.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MapboxOptions.setAccessToken(AppCredentials.mapBoxAccessToken);
  runApp(const LetDemApp());
}

class LetDemApp extends StatelessWidget {
  const LetDemApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'DMSans',
      ),
      navigatorKey: NavigatorHelper.navigatorKey,
      debugShowCheckedModeBanner: false,
      debugShowMaterialGrid: false,
      home: const SplashView(),
    );
  }
}
