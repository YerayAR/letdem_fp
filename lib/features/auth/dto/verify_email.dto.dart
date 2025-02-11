import 'package:letdem/services/api/models/endpoint.dart';

class VerifyEmailDTO extends DTO {
  final String email;
  final String otp;

  VerifyEmailDTO({
    required this.email,
    required this.otp,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'otp': otp,
    };
  }
}
