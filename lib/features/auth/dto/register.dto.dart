import 'package:letdem/services/api/models/endpoint.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

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
