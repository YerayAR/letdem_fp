import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:letdem/features/auth/models/nearby_payload.model.dart';
import 'package:letdem/infrastructure/storage/storage/storage.service.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class LocationWebSocketService {
  WebSocketChannel? _channel;

  bool get isConnected => _channel != null && _channel!.closeCode == null;

  void connectAndSendInitialLocation({
    required double latitude,
    required double longitude,
    required void Function(MapNearbyPayload event) onEvent,
    void Function()? onDone,
    void Function(dynamic error)? onError,
  }) async {
    var token = await SecureStorageHelper().read('access_token');

    final wsUrl = Uri.parse(
      'ws://api-staging.letdem.org/ws/maps/nearby?token=$token',
    );

    _channel = WebSocketChannel.connect(wsUrl);
    _log('✅ Connected to WebSocket');

    _channel!.stream.listen(
      (event) {
        var dta = MapNearbyPayload.fromJson(jsonDecode(event));
        // if (kDebugMode) {
        //   Toast.show('📥 Received location event: $event');
        // }
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
  Timer? _reconnectTimer;
  Timer? _connectionTimeout;
  int _reconnectAttempts = 0;
  static const int maxReconnectAttempts = 5;
  static const Duration baseReconnectDelay = Duration(seconds: 5);
  bool _isReconnecting = false;
  bool _intentionalDisconnect = false;

  bool get isConnected => _channel != null && _channel!.closeCode == null;
  bool get shouldAttemptReconnect =>
      _reconnectAttempts < maxReconnectAttempts && !_intentionalDisconnect;

  /// Connects to the WebSocket to listen for user data updates
  Future<void> connect({
    required void Function(Map<String, dynamic> event) onEvent,
    void Function()? onDone,
    void Function(dynamic error)? onError,
  }) async {
    // Clear intentional disconnect flag when explicitly connecting
    _intentionalDisconnect = false;

    try {
      // Cancel any existing reconnection timer
      _reconnectTimer?.cancel();
      _connectionTimeout?.cancel();

      // Close existing connection if any (but preserve reconnect state)
      await _closeExistingConnection();

      final token = await SecureStorageHelper().read('access_token');
      if (token == null || token.isEmpty) {
        _log('❌ No access token found', type: 'error');
        onError?.call('No access token');
        return;
      }

      final wsUrl = Uri.parse(
        'ws://api-staging.letdem.org/ws/users/refresh?token=$token',
      );

      _log('🔗 Attempting to connect to: ${wsUrl.toString()}');

      _channel = WebSocketChannel.connect(wsUrl);

      // Add a connection timeout
      _connectionTimeout = Timer(Duration(seconds: 10), () {
        if (_channel != null && _channel!.closeCode == null) {
          _log('⏰ Connection timeout', type: 'error');
          _channel?.sink.close();
        }
      });

      _channel!.stream.listen(
        (event) {
          _connectionTimeout?.cancel();
          _reconnectAttempts = 0; // Reset on successful connection
          _isReconnecting = false;

          try {
            var data = jsonDecode(event) as Map<String, dynamic>;
            _log('📥 Received user update event: $event', type: 'incoming');
            onEvent(data);
          } catch (e) {
            _log('❌ Error parsing user update event: $e', type: 'error');
          }
        },
        onDone: () {
          _connectionTimeout?.cancel();
          _log('🔌 Disconnected from User WebSocket (onDone)');
          _handleReconnect(onEvent: onEvent, onDone: onDone, onError: onError);
          onDone?.call();
        },
        onError: (error) {
          _connectionTimeout?.cancel();
          _log('❌ User WebSocket Error: $error', type: 'error');

          // Check if it's a DNS resolution error
          if (error.toString().contains('Failed host lookup') ||
              error.toString().contains('errno = 7')) {
            _log(
              '🌐 DNS resolution failed. Check if api-staging.letdem.org is accessible.',
              type: 'error',
            );

            // Don't attempt reconnection for DNS issues immediately
            if (_reconnectAttempts < 3) {
              _handleReconnect(
                onEvent: onEvent,
                onDone: onDone,
                onError: onError,
                delayMultiplier: 4,
              );
            } else {
              _log(
                '🛑 Max DNS resolution attempts reached. Stopping reconnection.',
                type: 'error',
              );
              onError?.call('DNS resolution failed after multiple attempts');
              return;
            }
          } else {
            _handleReconnect(
              onEvent: onEvent,
              onDone: onDone,
              onError: onError,
            );
          }

          onError?.call(error);
        },
      );

      // _log('✅ Connected to User WebSocket');
    } catch (e) {
      // _log('❌ Failed to connect to User WebSocket: $e', type: 'error');
      _handleReconnect(onEvent: onEvent, onDone: onDone, onError: onError);
      onError?.call(e);
    }
  }

  /// Reconnects after a delay with exponential backoff
  void _handleReconnect({
    required void Function(Map<String, dynamic> event) onEvent,
    void Function()? onDone,
    void Function(dynamic error)? onError,
    int delayMultiplier = 1,
  }) {
    // Don't reconnect if intentionally disconnected or already reconnecting
    if (_intentionalDisconnect) {
      _log('🛑 Intentional disconnect - not reconnecting', type: 'info');
      return;
    }

    if (_isReconnecting) {
      _log('⏳ Already reconnecting - skipping duplicate attempt', type: 'info');
      return;
    }

    if (!shouldAttemptReconnect) {
      _log(
        '🛑 Max reconnection attempts ($maxReconnectAttempts) reached. Giving up.',
        type: 'error',
      );
      _isReconnecting = false;
      onError?.call('Max reconnection attempts reached');
      return;
    }

    _isReconnecting = true;
    _reconnectAttempts++;

    // Exponential backoff: 5s, 10s, 20s, 40s, 80s
    final delay = Duration(
      seconds:
          baseReconnectDelay.inSeconds * delayMultiplier * _reconnectAttempts,
    );

    _log(
      '🔁 Attempting to reconnect to User WebSocket in ${delay.inSeconds}s (attempt $_reconnectAttempts/$maxReconnectAttempts)',
    );

    _reconnectTimer = Timer(delay, () {
      // Check if disconnect was called during the delay
      if (_intentionalDisconnect || !_isReconnecting) {
        _log('🛑 Reconnection cancelled', type: 'info');
        _isReconnecting = false;
        return;
      }

      // Reset flag before connecting so we can detect new disconnections
      _isReconnecting = false;

      connect(onEvent: onEvent, onDone: onDone, onError: onError);
    });
  }

  /// Sends a ping or custom message if needed
  void sendMessage(Map<String, dynamic> message) {
    if (!isConnected) {
      _log(
        '⚠️ User WebSocket is not connected. Cannot send message.',
        type: 'warn',
      );
      return;
    }

    try {
      final jsonString = jsonEncode(message);
      _log(
        '📤 Sending message to User WebSocket: $jsonString',
        type: 'outgoing',
      );
      _channel!.sink.add(jsonString);
    } catch (e) {
      _log('❌ Error sending message: $e', type: 'error');
    }
  }

  /// Closes existing connection without affecting reconnection state
  /// Used internally during reconnection flow
  Future<void> _closeExistingConnection() async {
    _connectionTimeout?.cancel();
    _connectionTimeout = null;

    if (_channel != null) {
      try {
        await _channel!.sink.close();
      } catch (e) {
        _log('⚠️ Error closing existing connection: $e', type: 'warn');
      }
      _channel = null;
    }
  }

  /// Closes the WebSocket connection and stops all reconnection attempts
  /// Call this when you want to fully disconnect (e.g., user logout)
  Future<void> disconnect() async {
    _log('🛑 Closing User WebSocket connection...');

    _intentionalDisconnect = true;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _connectionTimeout?.cancel();
    _connectionTimeout = null;
    _isReconnecting = false;
    _reconnectAttempts = 0;

    if (_channel != null) {
      try {
        await _channel!.sink.close();
      } catch (e) {
        _log('⚠️ Error during disconnect: $e', type: 'warn');
      }
      _channel = null;
    }
  }

  /// Reset reconnection state (call this when you want to retry after giving up)
  void resetReconnectionAttempts() {
    _reconnectAttempts = 0;
    _isReconnecting = false;
    _intentionalDisconnect = false;
  }

  /// Check if domain is reachable (optional utility method)
  static Future<bool> checkDomainReachability(String domain) async {
    try {
      final result = await InternetAddress.lookup(domain);
      return result.isNotEmpty;
    } catch (e) {
      return false;
    }
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

    // Use your preferred logging method
    developer.log(fullMessage);

    if (kDebugMode) {
      print(fullMessage);
    }
  }
}
