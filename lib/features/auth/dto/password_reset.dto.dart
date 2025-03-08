import 'package:letdem/services/api/models/endpoint.dart';

class ResetPasswordDTO extends DTO {
  final String email;
  final String password;

  ResetPasswordDTO({
    required this.email,
    required this.password,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'password': password,
    };
  }
}

class ChangePasswordDTO extends DTO {
  final String oldPassword;
  final String newPassword;

  ChangePasswordDTO({
    required this.oldPassword,
    required this.newPassword,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'current_password': oldPassword,
      'new_password': newPassword,
    };
  }
}
