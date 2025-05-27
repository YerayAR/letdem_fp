import 'package:letdem/infrastructure/api/api/models/endpoint.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

class TokenDTO extends DTO {
  final String token;

  TokenDTO({required this.token});

  @override
  Map<String, dynamic> toMap() {
    return {'token': token, 'device_id': OneSignal.User.pushSubscription.id};
  }
}
