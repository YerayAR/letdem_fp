import 'package:letdem/services/api/models/endpoint.dart';

class EmailDTO extends DTO {
  final String email;

  EmailDTO({
    required this.email,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'email': email,
    };
  }
}
