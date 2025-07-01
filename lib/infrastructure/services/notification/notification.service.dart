import 'package:flutter/material.dart';
import 'package:letdem/core/extensions/user.dart';
import 'package:letdem/features/activities/presentation/views/active_reservation.view.dart';
import 'package:letdem/features/activities/presentation/views/view_all.view.dart';
import 'package:letdem/features/wallet/presentation/views/wallet.view.dart';
import 'package:letdem/infrastructure/services/res/navigator.dart';

import '../../../features/map/presentation/views/route.view.dart';

class NotificationHandler {
  final BuildContext context;

  NotificationHandler(this.context);

  void handleNotification(Map<String, dynamic>? data) {
    if (data == null) {
      return;
    }

    if (data['page_to_redirect'] != null) {
      switch (data['page_to_redirect']) {
        case 'wallet':
          _goToWallet();
          break;
        case 'destination_route':
          final spaceId = data['space_id'];
          if (spaceId != null) {
            _goToDestinationDetails(spaceId);
          }
          break;
        case 'reservation_details':
          _goToReservationDetails();
          break;
        case 'contributions':
          _goToContributions();
          break;
        default:
          print('Unknown page to redirect: ${data['page_to_redirect']}');
      }
    }
  }

  void _goToWallet() {
    // Fetch wallet info here
    print('Fetching wallet info...');
    NavigatorHelper.to(WalletScreen());
  }

  void _goToDestinationDetails(String spaceId) {
    // Call new endpoint /v1/spaces/<spaceId>
    print('Fetching space details for $spaceId...');
    NavigatorHelper.to(NavigationMapScreen(
      spaceID: spaceId,
      latitude: null,
      longitude: null,
      hideToggle: false,
      destinationStreetName: '',
    ));
  }

  void _goToReservationDetails() {
    // Fetch active reservation
    BuildContext context = NavigatorHelper.navigatorKey.currentState!.context;

    final activeReservation = context.userProfile?.activeReservation;
    if (activeReservation == null) return;

    NavigatorHelper.to(ActiveReservationView(payload: activeReservation));
  }

  void _goToContributions() {
    // Fetch contributions
    print('Fetching contributions...');
    NavigatorHelper.to(ViewAllView());
  }
}
