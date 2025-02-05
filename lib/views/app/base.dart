import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_mapbox_navigation/flutter_mapbox_navigation.dart';
import 'package:geolocator/geolocator.dart' as geolocator;
import 'package:iconly/iconly.dart';
import 'package:iconsax/iconsax.dart';
import 'package:letdem/constants/ui/colors.dart';
import 'package:letdem/constants/ui/dimens.dart';
import 'package:letdem/constants/ui/typo.dart';
import 'package:letdem/extenstions/location.dart';
import 'package:letdem/global/widgets/button.dart';
import 'package:letdem/global/widgets/textfield.dart';
import 'package:letdem/views/app/activities/activities.view.dart';
import 'package:letdem/views/app/profile/profile.view.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mapbox;

class BaseView extends StatefulWidget {
  const BaseView({super.key});

  @override
  State<BaseView> createState() => _BaseViewState();
}

class _BaseViewState extends State<BaseView> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [
    const HomeView(),
    const ActivitiesView(),
    const ProfileView()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primary400,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(
            icon:
                Icon(_selectedIndex == 0 ? IconlyBold.home : IconlyLight.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(_selectedIndex == 1
                ? IconlyBold.activity
                : IconlyLight.activity),
            label: 'Activities',
          ),
          BottomNavigationBarItem(
            icon: Icon(
                _selectedIndex == 2 ? IconlyBold.profile : IconlyLight.profile),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  mapbox.Position? _currentPosition;

  @override
  void initState() {
    _getCurrentLocation();
    super.initState();
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled =
          await geolocator.Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await geolocator.Geolocator.requestPermission();
      }
      geolocator.LocationPermission permission =
          await geolocator.Geolocator.checkPermission();
      if (permission == geolocator.LocationPermission.denied ||
          permission == geolocator.LocationPermission.deniedForever) {
        permission = await geolocator.Geolocator.requestPermission();
      }

      if (permission == geolocator.LocationPermission.whileInUse ||
          permission == geolocator.LocationPermission.always) {
        var position = await geolocator.Geolocator.getCurrentPosition(
          desiredAccuracy: geolocator.LocationAccuracy.high,
        );

        setState(() {
          _currentPosition = mapbox.Position(
            position.longitude,
            position.latitude,
          );
          _cameraPosition = mapbox.CameraOptions(
              center: mapbox.Point(
                  coordinates: mapbox.Position(
                position.longitude,
                position.latitude,
              )),
              zoom: 13,
              bearing: 0,
              pitch: 0);
        });
      }
    } catch (e) {
      print("Error getting location: $e");
    }
  }

  late mapbox.MapboxMap mapboxController;

  Future<bool> checkLocationFuture() async {
    return await context.hasLocationPermission;
  }

  late mapbox.CameraOptions _cameraPosition;

  // void startNav() {
  //   MapBoxNavigation.instance.setDefaultOptions(MapBoxOptions(
  //       initialLatitude: 36.1175275,
  //       initialLongitude: -115.1839524,
  //       zoom: 7.0,
  //       tilt: 0.0,
  //       bearing: 0.0,
  //       enableRefresh: false,
  //       alternatives: true,
  //       voiceInstructionsEnabled: true,
  //       bannerInstructionsEnabled: true,
  //       allowsUTurnAtWayPoints: true,
  //       mode: MapBoxNavigationMode.drivingWithTraffic,
  //       mapStyleUrlDay: "https://url_to_day_style",
  //       mapStyleUrlNight: "https://url_to_night_style",
  //       units: VoiceUnits.imperial,
  //       simulateRoute: true,
  //       language: "en"));
  // }

  @override
  Widget build(BuildContext context) {
    return _currentPosition == null
        ? const CupertinoActivityIndicator()
        : Center(
            key: UniqueKey(),
            child: Stack(
              children: [
                mapbox.MapWidget(
                  key: UniqueKey(),
                  styleUri: mapbox.MapboxStyles.OUTDOORS,
                  cameraOptions: _cameraPosition,
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  child: Container(
                      width: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.all(Dimens.defaultMargin),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 1,
                            blurRadius: 7,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Dimens.space(2),
                          const TextInputField(
                            label: null,
                            prefixIcon: IconlyLight.search,
                            placeHolder: 'Enter destination',
                          ),
                          Dimens.space(2),
                          Text(
                            "What do you want to do?",
                            style: Typo.largeBody
                                .copyWith(fontWeight: FontWeight.w500),
                          ),
                          Dimens.space(2),
                          Row(
                            children: [
                              Flexible(
                                child: PrimaryButton(
                                  onTap: () {},
                                  icon: Iconsax.location5,
                                  text: 'Publish Space',
                                ),
                              ),
                              Dimens.space(1),
                              Flexible(
                                child: PrimaryButton(
                                  outline: true,
                                  background: AppColors.primary50,
                                  borderColor: Colors.transparent,
                                  onTap: () {},
                                  icon: IconlyBold.star,
                                  color: AppColors.primary500,
                                  text: 'Publish Event',
                                ),
                              ),
                            ],
                          ),
                          Dimens.space(2),
                        ],
                      )),
                ),
              ],
            ),
          );
  }
}
