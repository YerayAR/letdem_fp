import 'package:letdem/services/api/api.service.dart';
import 'package:letdem/services/api/endpoints.dart';
import 'package:letdem/services/api/models/endpoint.dart';
import 'package:letdem/services/api/models/response.model.dart';

class UserRepository extends IUserRepository {
  @override
  Future<void> createUser() {
    // TODO: implement createUser
    throw UnimplementedError();
  }

  @override
  Future<void> deleteUser() {
    // TODO: implement deleteUser
    throw UnimplementedError();
  }

  @override
  Future<LetDemUser> getUser() async {
    ApiResponse response = await ApiService.sendRequest(
      endpoint: EndPoints.getUserProfileEndpoint,
    );

    return LetDemUser.fromJSON(response.data);
  }

  @override
  Future<void> updateUser(EditBasicInfoDTO dto) {
    return ApiService.sendRequest(
      endpoint: EndPoints.updateUserProfileEndpoint.copyWithDTO(dto),
    );
  }
}

abstract class IUserRepository {
  Future<void> createUser();
  Future<void> deleteUser();
  Future<LetDemUser> getUser();
  Future<void> updateUser(EditBasicInfoDTO dto);
}

class LetDemUser {
  final String email;
  final String firstName;
  final String lastName;
  final bool isSocial;
  final int totalPoints;
  final int notificationsCount;

  LetDemUser({
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.isSocial,
    required this.totalPoints,
    required this.notificationsCount,
  });

  factory LetDemUser.fromJSON(Map<String, dynamic> json) {
    return LetDemUser(
      email: json['email'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      isSocial: json['is_social'] ?? false,
      totalPoints: json['total_points'] ?? 0,
      notificationsCount: json['notifications_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJSON() {
    return {
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'is_social': isSocial,
      'total_points': totalPoints,
      'notifications_count': notificationsCount,
    };
  }
}

class EditBasicInfoDTO extends DTO {
  final String firstName;
  final String lastName;

  EditBasicInfoDTO({
    required this.firstName,
    required this.lastName,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'first_name': firstName,
      'last_name': lastName,
    };
  }
}
