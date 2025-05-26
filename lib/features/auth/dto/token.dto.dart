import 'package:onesignal_flutter/onesignal_flutter.dart';

import '../../../services/api/models/endpoint.dart';

class TokenDTO extends DTO {
  final String token;

  TokenDTO({required this.token});

  @override
  Map<String, dynamic> toMap() {
    return {'token': token, 'device_id': OneSignal.User.pushSubscription.id};
  }
}
