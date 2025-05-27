import 'package:onesignal_flutter/onesignal_flutter.dart';

import '../../../infrastructure/api/api/models/endpoint.dart';

class RegisterDTO extends DTO {
  final String email;
  final String password;

  final String language;

  RegisterDTO({
    required this.email,
    required this.password,
    required this.language,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'password': password,
      'language': language,
      'device_id': OneSignal.User.pushSubscription.id
    };
  }
}
