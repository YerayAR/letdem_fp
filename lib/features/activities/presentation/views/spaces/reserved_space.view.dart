// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:here_sdk/core.dart' as HERE;
import 'package:here_sdk/core.dart';
import 'package:here_sdk/location.dart' hide LocationAccuracy;
import 'package:iconly/iconly.dart';
import 'package:iconsax/iconsax.dart';
import 'package:letdem/common/popups/popup.dart';
import 'package:letdem/common/widgets/chip.dart';
import 'package:letdem/core/constants/colors.dart';
import 'package:letdem/core/constants/dimens.dart';
import 'package:letdem/core/enums/PublishSpaceType.dart';
import 'package:letdem/core/extensions/locale.dart';
import 'package:letdem/features/activities/activities_state.dart';
import 'package:letdem/features/activities/presentation/modals/space.popup.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../../../../common/popups/success_dialog.dart';
import '../../../../../common/widgets/appbar.dart';
import '../../../../../common/widgets/body.dart';
import '../../../../../common/widgets/button.dart';
import '../../../../../infrastructure/services/res/navigator.dart';
import '../../../../../infrastructure/storage/storage/storage.service.dart';
import '../../../../../infrastructure/toast/toast/toast.dart';
import '../../../../auth/models/nearby_payload.model.dart' hide Location;
import '../../../../map/presentation/views/navigate/navigate.view.dart';
import '../../../activities_bloc.dart';

class ReservedSpaceDetailView extends StatefulWidget {
  final ReservedSpacePayload details;
  final Space space;

  const ReservedSpaceDetailView({
    super.key,
    required this.details,
    required this.space,
  });

  @override
  State<ReservedSpaceDetailView> createState() =>
      _ReservedSpaceDetailViewState();
}

class _ReservedSpaceDetailViewState extends State<ReservedSpaceDetailView> {
  final RequesterTrackLocationSocket _socket = RequesterTrackLocationSocket();
  bool isSharingLocation = false;

  late LocationEngine _locationEngine;
  LocationListener? _locationListener;
  double _lastLatitude = 0;
  double _lastLongitude = 0;
  int _distanceTraveled = 0;

  HERE.GeoCoordinates? _currentLocation;

  @override
  void dispose() {
    _socket.disconnect();
    if (_locationListener != null) {
      _locationEngine.removeLocationListener(_locationListener!);
    }
    super.dispose();
  }

  void _onBack() {
    NavigatorHelper.pop();
    NavigatorHelper.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<ActivitiesBloc, ActivitiesState>(
        listener: (context, state) {
          if (state is ReservationSpaceCancelled) {
            // Handle cancelled reservation
            AppPopup.showDialogSheet(
              context,
              SuccessDialog(
                title: context.l10n.reservationCancelledRequesterTitle,
                subtext: context.l10n.reservationCancelledRequesterDescription,
                onProceed: _onBack,
              ),
            );
          }
          // TODO: implement listener
        },
        builder: (context, state) {
          bool isStateLoading =
              context.watch<ActivitiesBloc>().state is ActivitiesLoading;
          return StyledBody(
            isBottomPadding: false,
            children: [
              _buildAppBar(context),
              Expanded(
                child: ListView(
                  children: [
                    _buildImage(context),
                    const SizedBox(height: 24),
                    _buildConfirmationCard(context),
                    const SizedBox(height: 24),
                    _buildPropertiesRow(context),
                    const SizedBox(height: 24),
                    _buildNavigateButton(context),
                    const SizedBox(height: 16),
                    _buildCallButton(context),
                    const SizedBox(height: 24),
                    _trackLocation(context),
                    const SizedBox(height: 24),
                    PrimaryButton(
                      isLoading: isStateLoading,
                      isDisabled: isStateLoading,
                      text: context.l10n.cancel,
                      color: AppColors.red500,
                      textColor: Colors.white,
                      onTap: () {
                        AppPopup.showDialogSheet(
                          context,
                          ConfirmationDialog(
                            onProceed: () {
                              NavigatorHelper.pop();

                              context.read<ActivitiesBloc>().add(
                                CancelReservationEvent(
                                  reservationId: widget.details.id,
                                ),
                              );
                            },
                            title:
                                context.l10n.cancelReservationConfirmationTitle,
                            subtext:
                                context.l10n.cancelReservationConfirmationText,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  Widget _buildAppBar(BuildContext context) {
    return StyledAppBar(
      title: context.l10n.reservedSpace,
      onTap: () => NavigatorHelper.pop(),
      icon: Iconsax.close_circle5,
    );
  }

  // ---------------------------------------------------------------------------
  Widget _buildImage(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.network(
            widget.space.image,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  Widget _buildConfirmationCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          Center(
            child: Text(
              context.l10n.confirmationCodeTitle,
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            widget.details.confirmationCode,
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildShareNote(context),
          const SizedBox(height: 16),
          DecoratedChip(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            text: widget.details.space.location.streetName,
            icon: IconlyBold.location,
            color: AppColors.primary500,
          ),
          Dimens.space(3),
          _buildOwnerPlate(context),
        ],
      ),
    );
  }

  Widget _buildShareNote(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.secondary50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        context.l10n.shareCodeOwner,
        style: TextStyle(color: AppColors.secondary600, fontSize: 16),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildOwnerPlate(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          context.l10n.ownerPlateNumber,
          style: const TextStyle(fontSize: 16, color: Colors.black54),
        ),
        Text(
          widget.details.carPlateNumber,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  Widget _buildPropertiesRow(context) {
    return Row(
      children: [
        Expanded(child: _buildSpaceInfoCard(context)),
        const SizedBox(width: 16),
        Expanded(child: _buildPriceInfoCard()),
      ],
    );
  }

  Widget _buildSpaceInfoCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          SvgPicture.asset(
            getSpaceTypeIcon(widget.space.type),
            width: 60,
            height: 60,
          ),
          const SizedBox(height: 12),
          Text(
            getSpaceAvailabilityMessage(widget.space.type, context),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: AppColors.green600,
            child: const Icon(IconlyBold.wallet, size: 30, color: Colors.white),
          ),
          const SizedBox(height: 12),
          Text(
            '${widget.details.price.toStringAsFixed(2)} €',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  Widget _buildNavigateButton(BuildContext context) {
    return PrimaryButton(
      onTap: () {
        NavigatorHelper.to(
          NavigationView(
            destinationLat: widget.details.space.location.point.lat,
            destinationLng: widget.details.space.location.point.lng,
          ),
        );
      },
      text: context.l10n.navigateToSpace,
    );
  }

  Widget _buildCallButton(BuildContext context) {
    return PrimaryButton(
      onTap: () async {
        Uri url = Uri.parse('tel:${widget.details.phone}');
        if (!await launchUrl(url)) {
          Toast.showError(context.l10n.couldNotLaunchDialer);
        } else {
          print("Dialer launched successfully");
        }
      },
      borderWidth: 1,
      background: Colors.white,
      textColor: AppColors.neutral500,
      icon: IconlyBold.call,
      text: context.l10n.callSpaceOwner,
    );
  }

  Widget _trackLocation(BuildContext context) {
    return PrimaryButton(
      onTap: () async {
        if (isSharingLocation) {
          _socket.disconnect();
          setState(() {
            isSharingLocation = false;
          });
        } else {
          await _getCurrentLocation();
        }
      },
      borderWidth: 1,
      background: Colors.white,
      textColor: AppColors.neutral500,
      icon: IconlyBold.location,
      text:
          isSharingLocation
              ? 'Dejar de compartir ubicación'
              : 'Compartir mi ubicación',
    );
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

      // setState(() {
      //   _isLocationReady = true;
      //   _isLoading = false;
      // });

      _initializeWebSocketConnection();
    } catch (e) {
      // debugPrint('❌ Error getting current location: $e');
      // setState(() {
      //   _errorMessage = "Failed to get current location";
      //   _isLoading = false;
      //   _isLocationReady = false;
      // });
    }
  }

  void _initializeWebSocketConnection() async {
    final token = await SecureStorageHelper().read('access_token') ?? '';

    _socket.connect(token, widget.details.id);

    await Future.delayed(const Duration(seconds: 1));

    print('currentLocation $_currentLocation');

    _socket.sendLocation(
      _currentLocation!.latitude,
      _currentLocation!.longitude,
    );

    setState(() {
      isSharingLocation = true;
    });
  }

  // void _setupLocationUpdates() {
  //   try {
  //     _locationEngine = LocationEngine();
  //     _locationListener = LocationListener((Location location) {
  //       print('location si paso');
  //       _socket.sendLocation(
  //         location.coordinates.latitude,
  //         location.coordinates.longitude,
  //       );
  //     });

  //     _locationEngine.addLocationListener(_locationListener!);
  //     _locationEngine.startWithLocationAccuracy(LocationAccuracy.navigation);
  //   } catch (e) {
  //     print('location no paso');
  //     debugPrint("Location setup error: $e");
  //   }
  // }

  // ---------------------------------------------------------------------------
  BoxDecoration _cardDecoration() {
    return BoxDecoration(
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
    );
  }
}

class RequesterTrackLocationSocket {
  WebSocketChannel? channel;

  void connect(String token, String reservationId) {
    final url =
        'ws://api-staging.letdem.org/ws/reservations/track-location?token=$token&reservation_id=$reservationId';

    final uri = Uri.parse(url);

    channel = WebSocketChannel.connect(uri);

    // ---- ESCUCHAR RESPUESTAS DEL SERVIDOR (IMPORTANTE) ----
    channel!.stream.listen((message) {}, onDone: () {}, onError: (error) {});
  }

  /// Enviar coordenadas
  void sendLocation(double lat, double lng) {
    final data = {
      "event_type": "track_location",
      "data": {"lat": lat, "lng": lng},
    };

    print('📤 Enviando ubicación => lat: $lat, lng: $lng');

    channel?.sink.add(jsonEncode(data));
  }

  /// Dejar de compartir ubicación
  void disconnect() {
    channel?.sink.close();
  }
}
