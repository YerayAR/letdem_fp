import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as geolocator;
import 'package:iconsax/iconsax.dart';
import 'package:letdem/constants/ui/colors.dart';
import 'package:letdem/constants/ui/dimens.dart';
import 'package:letdem/constants/ui/typo.dart';
import 'package:letdem/global/widgets/button.dart';
import 'package:letdem/global/widgets/textfield.dart';
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
    const Center(child: Text('Search View')),
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
            icon: Icon(_selectedIndex == 0 ? Iconsax.home5 : Iconsax.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(_selectedIndex == 1 ? Iconsax.chart4 : Iconsax.chart),
            label: 'Activities',
          ),
          BottomNavigationBarItem(
            icon: Icon(_selectedIndex == 2 ? Iconsax.user : Iconsax.user),
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
        });
      }
    } catch (e) {
      print("Error getting location: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return _currentPosition == null
        ? const CupertinoActivityIndicator()
        : Center(
            child: Stack(
              children: [
                mapbox.MapWidget(
                  styleUri: mapbox.MapboxStyles.MAPBOX_STREETS,
                  cameraOptions: mapbox.CameraOptions(
                      center: mapbox.Point(coordinates: _currentPosition!),
                      zoom: 14,
                      bearing: 0,
                      pitch: 0),
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
                        topLeft: Radius.circular(25),
                        topRight: Radius.circular(25),
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
                          placeHolder: 'Enter your destination',
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
                                onTap: () {},
                                icon: Iconsax.star5,
                                text: 'Publish Event',
                              ),
                            ),
                          ],
                        ),
                        Dimens.space(2),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
  }
}
