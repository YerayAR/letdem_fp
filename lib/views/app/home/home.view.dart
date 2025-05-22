import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart' as geolocator;
import 'package:here_sdk/core.dart';
import 'package:here_sdk/gestures.dart';
import 'package:here_sdk/location.dart';
import 'package:here_sdk/mapview.dart';
import 'package:iconly/iconly.dart';
import 'package:iconsax/iconsax.dart';
import 'package:letdem/constants/ui/colors.dart';
import 'package:letdem/constants/ui/dimens.dart';
import 'package:letdem/constants/ui/typo.dart';
import 'package:letdem/enums/EventTypes.dart';
import 'package:letdem/extenstions/user.dart';
import 'package:letdem/features/activities/activities_bloc.dart';
import 'package:letdem/features/activities/activities_state.dart';
import 'package:letdem/features/map/map_bloc.dart';
import 'package:letdem/global/popups/popup.dart';
import 'package:letdem/global/widgets/appbar.dart';
import 'package:letdem/global/widgets/body.dart';
import 'package:letdem/global/widgets/button.dart';
import 'package:letdem/global/widgets/chip.dart';
import 'package:letdem/models/auth/map/map_options.model.dart';
import 'package:letdem/models/auth/map/nearby_payload.model.dart' hide Location;
import 'package:letdem/services/map/map_asset_provider.service.dart';
import 'package:letdem/services/res/navigator.dart';
import 'package:letdem/services/toast/toast.dart';
import 'package:letdem/views/app/home/widgets/home/home_bottom_section.widget.dart';
import 'package:letdem/views/app/home/widgets/home/no_connection.widget.dart';
import 'package:letdem/views/app/home/widgets/home/shimmers/home_page_shimmer.widget.dart';
import 'package:letdem/views/app/maps/navigate.view.dart';
import 'package:letdem/views/app/maps/route.view.dart';
import 'package:letdem/views/app/payment_method/screens/add_payment_method.view.dart';
import 'package:letdem/views/app/payment_method/screens/payment_methods.view.dart';
import 'package:letdem/views/app/publish_space/screens/publish_space.view.dart';
import 'package:letdem/views/auth/views/onboard/verify_account.view.dart';
import 'package:url_launcher/url_launcher.dart';

// ... your imports remain unchanged

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView>
    with AutomaticKeepAliveClientMixin {
  HereMapController? _mapController;

  GeoCoordinates? _currentPosition;
  GeoCoordinates? _lastFetchPosition;

  bool isLocationLoading = false;
  bool isLoadingAssets = true;
  bool hasNoPermission = false;
  bool _isListeningToLocation = false;

  final MapAssetsProvider _assetsProvider = MapAssetsProvider();

  MapMarker? _currentLocationMarker;
  final Map<MapMarker, Space> _spaceMarkers = {};
  final Map<MapMarker, Event> _eventMarkers = {};

  late LocationEngine _locationEngine;
  LocationIndicator? _locationIndicator;

  static const double TRIGGER_DISTANCE_METERS = 250.0;
  LocationListener? _locationListener;

  @override
  void initState() {
    super.initState();
    _loadAssets();
    _getCurrentLocation();
  }

  Future<void> _loadAssets() async {
    setState(() => isLoadingAssets = true);
    await _assetsProvider.loadAssets();
    setState(() => isLoadingAssets = false);
  }

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

  void _addMyLocationToMap(Location myLocation) {
    if (_locationIndicator == null) {
      _locationIndicator = LocationIndicator()
        ..isAccuracyVisualized = false
        ..locationIndicatorStyle = LocationIndicatorIndicatorStyle.navigation
        ..enable(_mapController!)
        ..setHaloColor(
            LocationIndicatorIndicatorStyle.navigation, Colors.transparent);
    }
    _locationIndicator!.updateLocation(myLocation);

    if (_lastFetchPosition == null) {
      _mapController!.camera.lookAtPointWithMeasure(
        myLocation.coordinates,
        MapMeasure(MapMeasureKind.distanceInMeters, 3000),
      );
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

  void _fetchNearbyPlaces(GeoCoordinates position) {
    _lastFetchPosition = position;
    context.read<MapBloc>().add(GetNearbyPlaces(
          queryParams: MapQueryParams(
            currentPoint: "${position.latitude},${position.longitude}",
            radius: 8000,
            drivingMode: false,
            options: ['spaces', 'events'],
          ),
        ));
  }

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
        marker.fadeDuration = Duration(seconds: 2);

        _spaceMarkers[marker] = space;
      } catch (e) {
        debugPrint("Space marker error: $e");
      }
    }

    for (var event in events) {
      try {
        final imageData = _assetsProvider.getEventIcon(event.type);

        // print lat and lng

        print(
            "??Adding ${event.type} marker at ${event.location.point.lat}, ${event.location.point.lng}");
        final marker = MapMarker(
          GeoCoordinates(event.location.point.lat, event.location.point.lng),
          MapImage.withPixelDataAndImageFormat(imageData, ImageFormat.png),
        );
        marker.fadeDuration = Duration(seconds: 2);

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
  }

  showEventPopup({
    required Event event,
  }) {
    AppPopup.showBottomSheet(
      context,
      Padding(
        padding: EdgeInsets.all(Dimens.defaultMargin + 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: [
                Image(
                  image: AssetImage(
                    MapAssetsProvider.getAssetEvent(event.type),
                  ),
                  height: 40,
                ),
                Dimens.space(1),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          getEventMessage(event.type),
                          style: Typo.largeBody.copyWith(
                              fontWeight: FontWeight.w700, fontSize: 18),
                        ),
                        Dimens.space(2),
                        DecoratedChip(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 5),
                          text: '${geolocator.Geolocator.distanceBetween(
                            _currentPosition!.latitude,
                            _currentPosition!.longitude,
                            event.location.point.lat,
                            event.location.point.lng,
                          ).floor()}m away',
                          textStyle: Typo.smallBody.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.green600,
                          ),
                          icon: Iconsax.clock,
                          color: AppColors.green500,
                        )
                      ],
                    ),
                    Text(
                      event.location.streetName,
                      style: Typo.largeBody.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: AppColors.neutral600),
                    ),
                  ],
                ),
              ],
            ),
            Dimens.space(4),
            Row(
              children: <Widget>[
                Flexible(
                  child: PrimaryButton(
                    onTap: () {
                      NavigatorHelper.pop();
                    },
                    text: 'Got it, Thank you',
                  ),
                ),
                Dimens.space(1),
                Flexible(
                  child: PrimaryButton(
                    outline: true,
                    onTap: () {
                      AppPopup.showBottomSheet(
                          context,
                          FeedbackForm(
                            eventID: event.id,
                          ));
                    },
                    background: AppColors.primary50,
                    borderColor: Colors.transparent,
                    color: AppColors.primary500,
                    text: 'Feedback',
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  showSpacePopup({
    required Space space,
  }) {
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
                        mainAxisSize:
                            MainAxisSize.min, // Important to avoid overflow
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                getSpaceTypeIcon(space.type),
                                width: 20,
                                height: 20,
                              ),
                              SizedBox(
                                  width:
                                      8), // Replaces Dimens.space(1) for horizontal spacing
                              Expanded(
                                // Make sure text wraps and doesn't overflow
                                child: Text(
                                  getSpaceAvailabilityMessage(space.type),
                                  style: Typo.largeBody
                                      .copyWith(fontWeight: FontWeight.w800),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Dimens.space(2),
                              SizedBox(
                                child: space.isPremium
                                    ? Text("€${space.price}",
                                        style: Typo.largeBody.copyWith(
                                          fontWeight: FontWeight.w800,
                                        ))
                                    : null,
                              ),
                            ],
                          ),
                          SizedBox(height: 8), // Replaces Dimens.space(1)
                          Text(
                            space.location.streetName,
                            style: Typo.largeBody.copyWith(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: AppColors.neutral600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 8), // Replaces Dimens.space(1)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              DecoratedChip(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 5),
                                text:
                                    '${parseMeters(geolocator.Geolocator.distanceBetween(
                                  _currentPosition!.latitude,
                                  _currentPosition!.longitude,
                                  space.location.point.lat,
                                  space.location.point.lng,
                                ))} away',
                                textStyle: Typo.smallBody.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.green600,
                                ),
                                icon: Iconsax.clock5,
                                color: AppColors.green500,
                              ),
                              Dimens.space(1),
                              SizedBox(
                                child: space.isPremium &&
                                        space.expirationDate != null
                                    ? DecoratedChip(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 5),
                                        text: getTimeLeftMessage(DateTime.now(),
                                            space.expirationDate!),
                                        textStyle: Typo.smallBody.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.primary500,
                                        ),
                                        icon: Iconsax.clock5,
                                        color: AppColors.primary200,
                                      )
                                    : null,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Dimens.space(3),
                SizedBox(
                    child: space.isPremium
                        ? Container(
                            margin: const EdgeInsets.only(bottom: 24),
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 14),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: AppColors.neutral50,
                              ),
                            ),
                            child: context.userProfile!.defaultPaymentMethod !=
                                    null
                                ? Row(
                                    children: [
                                      Image.asset(
                                        getCardIcon(
                                          context.userProfile!
                                              .defaultPaymentMethod!.brand,
                                        ),
                                        width: 40,
                                        height: 40,
                                      ),
                                      Dimens.space(1),
                                      Text(
                                        '${context.userProfile!.defaultPaymentMethod!.brand}  ending with ${context.userProfile!.defaultPaymentMethod!.last4}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Spacer(),
                                      GestureDetector(
                                        onTap: () {
                                          NavigatorHelper.to(
                                            const PaymentMethodsScreen(),
                                          );
                                        },
                                        child: Icon(
                                          Icons.keyboard_arrow_right_sharp,
                                          size: 25,
                                          color: AppColors.neutral100,
                                        ),
                                      ),
                                    ],
                                  )
                                : Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Add payment method',
                                        style: Typo.mediumBody.copyWith(
                                          color: AppColors.primary500,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                      Icon(
                                        IconlyBold.arrow_right_2,
                                        size: 18,
                                        color: AppColors.neutral100,
                                      ),
                                    ],
                                  ),
                          )
                        : const SizedBox()),
                BlocConsumer<ActivitiesBloc, ActivitiesState>(
                  listener: (context, state) {
                    if (state is SpaceReserved) {
                      AppPopup.showDialogSheet(
                        context,
                        SuccessDialog(
                          onProceed: () {
                            NavigatorHelper.to(ReservedSpaceDetailView(
                              space: space,
                              details: state.spaceID,
                            ));
                          },
                          title: 'Payment Successful',
                          subtext:
                              'You have successfully reserved a paid space. You can get the details by clicking below.',
                          buttonText: 'Get Details of space',
                        ),
                      );
                    } else if (state is ActivitiesError) {
                      Toast.showError(state.error);
                    }
                    // TODO: implement listener
                  },
                  builder: (context, state) {
                    return PrimaryButton(
                      icon: space.isPremium ? null : Iconsax.location5,
                      isLoading: context.read<ActivitiesBloc>().state
                          is ActivitiesLoading,
                      text: space.isPremium
                          ? 'Reserve space'
                          : 'Navigate to space',
                      onTap: () {
                        if (space.isPremium) {
                          if (context.userProfile!.defaultPaymentMethod ==
                              null) {
                            NavigatorHelper.to(AddPaymentMethod());
                          } else {
                            context
                                .read<ActivitiesBloc>()
                                .add(ReserveSpaceEvent(
                                  spaceID: space.id,
                                  paymentMethodID: context.userProfile!
                                      .defaultPaymentMethod!.paymentMethodId,
                                ));
                          }
                        } else {
                          NavigatorHelper.to(TrafficRouteLineExample(
                            hideToggle: true,
                            spaceInfo: space,
                            streetName: space.location.streetName,
                            lat: space.location.point.lat,
                            lng: space.location.point.lng,
                          ));
                        }
                      },
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
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
          final space = _spaceMarkers[topMarker]!;

          showSpacePopup(space: space);
        } else if (_eventMarkers.containsKey(topMarker)) {
          final event = _eventMarkers[topMarker]!;
          showEventPopup(event: event);
        }
      }
    });
  }

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
          target, MapMeasure(MapMeasureKind.distanceInMeters, 14000));

      if (_currentPosition != null) {
        _addMyLocationToMap(Location.withCoordinates(_currentPosition!));
        _setupLocationUpdates();
        _fetchNearbyPlaces(_currentPosition!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return isLocationLoading || isLoadingAssets
        ? const HomePageShimmer()
        : hasNoPermission
            ? const NoMapPermissionSection()
            : BlocConsumer<MapBloc, MapState>(
                listener: (context, state) {
                  if (state is MapLoaded && _mapController != null) {
                    _addMapMarkers(state.payload.spaces, state.payload.events);
                  }
                },
                builder: (context, state) {
                  return Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      _currentPosition != null
                          ? HereMap(onMapCreated: _onMapCreated)
                          : const Center(child: CircularProgressIndicator()),
                      const HomeMapBottomSection(),
                    ],
                  );
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

    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;
}

class ReservedSpaceDetailView extends StatelessWidget {
  final ReservedSpacePayload details;
  final Space space;
  const ReservedSpaceDetailView(
      {super.key, required this.details, required this.space});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StyledBody(
        isBottomPadding: false,
        children: [
          StyledAppBar(
            title: 'Reserved Space',
            onTap: () {
              NavigatorHelper.pop();
            },
            icon: Iconsax.close_circle5,
          ),
          // Parking Image
          Expanded(
            child: ListView(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    space.image,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 24),

                // Confirmation Code Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Confirmation Code',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        details.confirmationCode,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          color: AppColors.secondary50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Share this code with the parking space owner',
                          style: TextStyle(
                            color: AppColors.secondary600,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Dimens.space(3),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'The Owner\'s Plate Number: ',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                            ),
                          ),
                          Text(
                            details.carPlateNumber,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Properties Row
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 5,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            SvgPicture.asset(
                              getSpaceTypeIcon(space.type),
                              width: 60,
                              height: 60,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              getSpaceAvailabilityMessage(space.type),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 5,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Stack(
                              alignment: Alignment.centerRight,
                              children: [
                                CircleAvatar(
                                  radius: 30,
                                  backgroundColor: AppColors.green600,
                                  child: const Icon(
                                    IconlyBold.wallet,
                                    size: 30,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '€${details.price.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Navigate Button
                PrimaryButton(
                  onTap: () {
                    NavigatorHelper.to(TrafficRouteLineExample(
                      hideToggle: true,
                      spaceInfo: space,
                      streetName: space.location.streetName,
                      lat: space.location.point.lat,
                      lng: space.location.point.lng,
                    ));
                  },
                  text: 'Navigate to Space',
                ),
                const SizedBox(height: 16),

                // Call Button
                PrimaryButton(
                  onTap: () async {
                    Uri url = Uri.parse('tel:${details.phone}');
                    if (!await launchUrl(url)) {
                      Toast.showError("Could not launch dialer");
                    } else {
                      // Successfully launched the dialer
                      print("Dialer launched successfully");
                    }
                  },
                  borderWidth: 1,
                  background: Colors.white,
                  textColor: AppColors.neutral500,
                  icon: IconlyBold.call,
                  text: 'Call Space Owner',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
