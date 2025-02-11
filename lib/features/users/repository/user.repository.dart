import 'package:letdem/services/api/api.service.dart';
import 'package:letdem/services/api/endpoints.dart';
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
  Future<void> updateUser() {
    // TODO: implement updateUser
    throw UnimplementedError();
  }
}

abstract class IUserRepository {
  Future<void> createUser();
  Future<void> deleteUser();
  Future<LetDemUser> getUser();
  Future<void> updateUser();
}

class LetDemUser {
  final String email;
  final String name;

  LetDemUser({
    required this.email,
    required this.name,
  });

  factory LetDemUser.fromJSON(Map<String, dynamic> json) {
    return LetDemUser(email: '', name: '');
  }
}
