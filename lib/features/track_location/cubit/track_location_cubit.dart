import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../../infrastructure/storage/storage/storage.service.dart';

part 'track_location_state.dart';

class TrackLocationCubit extends Cubit<TrackLocationState> {
  TrackLocationCubit(this.socket) : super(const TrackLocationState());
  final OwnerTrackLocationSocket socket;

  // -------------------------------
  // 🔵 CONNECT
  // -------------------------------
  void connect({required String reservationId}) {
    if (socket.isConnected) return;

    socket.connect(
      reservationId: reservationId,
      onMessage: _onMessageReceived,
      onDisconnected: () {
        emit(state.copyWith(isConnected: false));
      },
    );

    emit(state.copyWith(isConnected: true, errorCode: null));
  }

  // -------------------------------
  // 📥 MANEJO DE EVENTOS
  // -------------------------------
  void _onMessageReceived(Map<String, dynamic> data) {
    final type = data["type"];

    switch (type) {
      case "location":
        emit(
          state.copyWith(
            requesterLat: data["lat"],
            requesterLng: data["lng"],
            errorCode: null,
          ),
        );
        break;

      case "error":
        emit(
          state.copyWith(
            errorCode: data["error_code"],
            requesterLat: null,
            requesterLng: null,
          ),
        );
        break;

      default:
        emit(state.copyWith(errorCode: "UNKNOWN_EVENT"));
    }
  }

  // -------------------------------
  // 🔴 DISCONNECT
  // -------------------------------
  void disconnect() {
    socket.disconnect();
    emit(const TrackLocationState());
  }
}

class OwnerTrackLocationSocket {
  WebSocketChannel? _channel;
  final bool useTestServer;

  OwnerTrackLocationSocket({this.useTestServer = false});

  bool get isConnected => _channel != null && _channel!.closeCode == null;

  void connect({
    required String reservationId,
    required Function(Map<String, dynamic>) onMessage,
    Function()? onDisconnected,
  }) async {
    final token = await SecureStorageHelper().read('access_token') ?? '';

    // 🧪 TEST MODE: Use local test server
    final Uri wsUrl;
    if (useTestServer) {
      wsUrl = Uri.parse('ws://localhost:8765/test');
      debugPrint('🧪 [TEST MODE] Connecting to local test server: $wsUrl');
      debugPrint('🧪 [TEST MODE] Reservation ID: $reservationId (ignored in test mode)');
    } else {
      wsUrl = Uri.parse(
        'ws://api-staging.letdem.org/ws/reservations/track-location?token=$token&reservation_id=$reservationId',
      );
      debugPrint('🌐 [PRODUCTION] Connecting to: $wsUrl');
    }

    _channel = WebSocketChannel.connect(wsUrl);

    _channel!.stream.listen(
      (raw) {
        try {
          final json = jsonDecode(raw);

          // 🟢 Caso 1: ubicación recibida
          if (json["event_type"] == "track_location" && json["data"] != null) {
            onMessage({
              "type": "location",
              "lat": json["data"]["lat"],
              "lng": json["data"]["lng"],
            });
            return;
          }

          // 🔴 Caso 2: requester no comparte ubicación
          if (json["error_code"] == "REQUESTER_NOT_SHARING_LOCATION") {
            onMessage({
              "type": "error",
              "error_code": "REQUESTER_NOT_SHARING_LOCATION",
            });
            return;
          }

          // ❓ Caso desconocido
          onMessage({"type": "unknown", "raw": json});
        } catch (e) {
          onMessage({"type": "error", "error_code": "INVALID_JSON"});
        }
      },
      onDone: () {
        onDisconnected?.call();
      },
      onError: (error) {
        onDisconnected?.call();
      },
    );
  }

  void disconnect() {
    _channel?.sink.close();
    _channel = null;
  }
}
