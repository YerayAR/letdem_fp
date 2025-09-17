import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:letdem/features/auth/models/nearby_payload.model.dart';
import 'package:letdem/infrastructure/storage/storage/storage.service.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class LocationWebSocketService {
  WebSocketChannel? _channel;

  bool get isConnected => _channel != null && _channel!.closeCode == null;

  /// Connects to the WebSocket and sends the initial location
  ///
  ///
  ///
  void connectAndSendInitialLocation({
    required double latitude,
    required double longitude,
    required void Function(MapNearbyPayload event) onEvent,
    void Function()? onDone,
    void Function(dynamic error)? onError,
  }) async {
    var token = await SecureStorageHelper().read('access_token');

    final wsUrl = Uri.parse(
      'ws://api-staging.letdem.org/ws/maps/nearby?token=${token}',
    );

    _channel = WebSocketChannel.connect(wsUrl);
    _log('✅ Connected to WebSocket');

    _channel!.stream.listen(
      (event) {
        var dta = MapNearbyPayload.fromJson(jsonDecode(event));
        onEvent(dta);
      },
      onDone: () {
        _log('🔌 Disconnected from WebSocket (onDone)');
        _handleReconnect(
          latitude: latitude,
          longitude: longitude,
          onEvent: onEvent,
          onDone: onDone,
          onError: onError,
        );
        onDone?.call();
      },
      onError: (error) {
        _log('❌ WebSocket Error: $error', type: 'error');
        _handleReconnect(
          latitude: latitude,
          longitude: longitude,
          onEvent: onEvent,
          onDone: onDone,
          onError: onError,
        );
        onError?.call(error);
      },
    );

    sendLocation(latitude, longitude);
  }

  /// Reconnects after a short delay
  void _handleReconnect({
    required double latitude,
    required double longitude,
    required void Function(MapNearbyPayload event) onEvent,
    void Function()? onDone,
    void Function(dynamic error)? onError,
  }) {
    Future.delayed(Duration(seconds: 5), () {
      _log('🔁 Attempting to reconnect...');
      connectAndSendInitialLocation(
        latitude: latitude,
        longitude: longitude,
        onEvent: onEvent,
        onDone: onDone,
        onError: onError,
      );
    });
  }

  /// Sends a location update over the WebSocket
  void sendLocation(double latitude, double longitude) {
    if (kDebugMode) {
      // Toast.show('📍 Sending location update: $latitude, $longitude');
    }
    if (_channel == null) {
      _log(
        '⚠️ WebSocket is not connected. Cannot send location.',
        type: 'warn',
      );
      return;
    }

    final payload = {
      "event_type": "update.live.location",
      "data": {"lat": latitude, "lng": longitude},
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

class UserWebSocketService {
  WebSocketChannel? _channel;

  bool get isConnected => _channel != null && _channel!.closeCode == null;

  /// Connects to the WebSocket to listen for user data updates
  void connect({
    required void Function(Map<String, dynamic> event) onEvent,
    void Function()? onDone,
    void Function(dynamic error)? onError,
  }) async {
    var token = await SecureStorageHelper().read('access_token');
    if(token == null) return;

    final wsUrl = Uri.parse(
      'ws://api-staging.letdem.org/ws/users/refresh?token=$token',
    );

    _channel = WebSocketChannel.connect(wsUrl);
    _log('✅ Connected to User WebSocket');

    _channel!.stream.listen(
      (event) {
        try {
          var data = jsonDecode(event) as Map<String, dynamic>;
          _log('📥 Received user update event: $event', type: 'incoming');
          onEvent(data);
        } catch (e) {
          _log('❌ Error parsing user update event: $e', type: 'error');
        }
      },
      onDone: () {
        _log('🔌 Disconnected from User WebSocket (onDone)');
        _handleReconnect(onEvent: onEvent, onDone: onDone, onError: onError);
        onDone?.call();
      },
      onError: (error) {
        _log('❌ User WebSocket Error: $error', type: 'error');
        _handleReconnect(onEvent: onEvent, onDone: onDone, onError: onError);
        onError?.call(error);
      },
    );
  }

  /// Reconnects after a short delay
  void _handleReconnect({
    required void Function(Map<String, dynamic> event) onEvent,
    void Function()? onDone,
    void Function(dynamic error)? onError,
  }) {
    Future.delayed(Duration(seconds: 5), () {
      _log('🔁 Attempting to reconnect to User WebSocket...');
      connect(onEvent: onEvent, onDone: onDone, onError: onError);
    });
  }

  /// Sends a ping or custom message if needed (optional)
  void sendMessage(Map<String, dynamic> message) {
    if (_channel == null) {
      _log(
        '⚠️ User WebSocket is not connected. Cannot send message.',
        type: 'warn',
      );
      return;
    }

    final jsonString = jsonEncode(message);
    _log('📤 Sending message to User WebSocket: $jsonString', type: 'outgoing');
    _channel!.sink.add(jsonString);
  }

  /// Closes the WebSocket connection
  void disconnect() {
    _log('🛑 Closing User WebSocket connection...');
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
    final fullMessage = '$prefix [UserWS] $message';
    log(fullMessage);
    if (kDebugMode) {
      print(fullMessage); // Optional: comment this if using only `log()`
    }
  }
}
