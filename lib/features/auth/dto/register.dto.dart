import 'package:letdem/services/api/models/endpoint.dart';

class RegisterDTO extends DTO {
  final String email;
  final String password;

  RegisterDTO({
    required this.email,
    required this.password,
  });

  @override
  Map<String, dynamic> toMap() {
    return {'email': email, 'password': password};
  }
}
