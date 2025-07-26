import 'dart:convert';
import 'dart:developer';

import 'package:letdem/features/auth/models/nearby_payload.model.dart';
import 'package:letdem/infrastructure/storage/storage/storage.service.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class LocationWebSocketService {
  WebSocketChannel? _channel;

  /// Connects to the WebSocket and sends the initial location
  void connectAndSendInitialLocation({
    required double latitude,
    required double longitude,
    required void Function(MapNearbyPayload event) onEvent,
    void Function()? onDone,
    void Function(dynamic error)? onError,
  }) async {
    var token = await SecureStorageHelper().read('access_token');

    final wsUrl =
        Uri.parse('ws://api-staging.letdem.org/ws/maps/nearby?token=${token}');

    _channel = WebSocketChannel.connect((wsUrl));

    _log('✅ Connected to WebSocket');

    _channel!.stream.listen(
      (event) {
        var dta = MapNearbyPayload.fromJson(jsonDecode(event));
        onEvent(dta);
      },
      onDone: () {
        _log('🔌 Disconnected from WebSocket (onDone)');
        onDone?.call();
      },
      onError: (error) {
        _log('❌ WebSocket Error: $error', type: 'error');
        onError?.call(error);
      },
    );

    sendLocation(latitude, longitude);
  }

  /// Sends a location update over the WebSocket
  void sendLocation(double latitude, double longitude) {
    if (_channel == null) {
      _log('⚠️ WebSocket is not connected. Cannot send location.',
          type: 'warn');
      return;
    }

    final payload = {
      "event_type": "update.live.location",
      "data": {
        "lat": latitude,
        "lng": longitude,
      }
    };

    final jsonString = jsonEncode(payload);
    _log('📤 Sending location update: $jsonString', type: 'outgoing');
    _channel!.sink.add(jsonString);
  }

  /// Closes the WebSocket connection
  void disconnect() {
    _log('🛑 Closing WebSocket connection ...');
    _channel?.sink.close();
    _channel = null;
  }

  /// Pretty logger with labels
  void _log(String message, {String type = 'info'}) {
    final prefix = switch (type) {
      'incoming' => '[⬅️ INCOMING]',
      'outgoing' => '[➡️ OUTGOING]',
      'error' => '[❗ERROR]',
      'warn' => '[⚠️ WARNING]',
      _ => '[🔷 INFO]',
    };
    final fullMessage = '$prefix $message';
    log(fullMessage);
    print(fullMessage); // Optional: comment this if using only `log()`
  }
}
