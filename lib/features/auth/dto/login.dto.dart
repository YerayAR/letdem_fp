import 'package:letdem/infrastructure/api/api/models/endpoint.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

class LoginDTO extends DTO {
  final String email;
  final String password;

  LoginDTO({
    required this.email,
    required this.password,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'password': password,
      'device_id': OneSignal.User.pushSubscription.id
    };
  }
}
