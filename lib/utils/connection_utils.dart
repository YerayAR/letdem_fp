// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

import '../common/popups/popup.dart';
import '../features/activities/presentation/modals/space.popup.dart';
import '../infrastructure/services/res/navigator.dart';

class ConnectionHelper {
  /// Verifica si el dispositivo tiene acceso real a Internet
  static Future<bool> checkInternetAccess() async {
    final connectivityResults = await Connectivity().checkConnectivity();

    // Si no hay conexión de red
    if (connectivityResults.isEmpty ||
        connectivityResults.contains(ConnectivityResult.none)) {
      return false;
    }

    // Intenta hacer ping a un servidor confiable
    try {
      final result = await InternetAddress.lookup(
        'google.com',
      ).timeout(const Duration(seconds: 3));
      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } on SocketException {
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Muestra un popup si no hay conexión a Internet
  static Future<void> showNoConnectionDialog(BuildContext context) async {
    await AppPopup.showDialogSheet(
      context,
      ConfirmationDialog(
        isError: true,
        title: 'Sin conexión a Internet',
        subtext: 'Por favor, verifica tu conexión e inténtalo de nuevo.',
        onProceed: () {
          NavigatorHelper.pop();
        },
      ),
    );
  }
}
