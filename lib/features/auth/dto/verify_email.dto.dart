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

class ConfirmationCodeDTO extends DTO {
  final String code;

  final String spaceID;

  ConfirmationCodeDTO({
    required this.code,
    required this.spaceID,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'confirmation_code': code,
    };
  }
}
