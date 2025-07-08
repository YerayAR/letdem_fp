import 'dart:ui';

import 'package:letdem/features/auth/dto/password_reset.dto.dart';
import 'package:letdem/features/users/dto/edit_basic_info.dto.dart';
import 'package:letdem/features/users/models/user.model.dart';
import 'package:letdem/infrastructure/api/api/api.service.dart';
import 'package:letdem/infrastructure/api/api/endpoints.dart';
import 'package:letdem/infrastructure/api/api/models/response.model.dart';
import 'package:letdem/models/orders/order.model.dart';

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
  Future<List<Order>> getOrders() async {
    ApiResponse response = await ApiService.sendRequest(
      endpoint: EndPoints.getOrdersEndpoint,
    );

    return response.data['results']
        .map<Order>((e) => Order.fromJson(e))
        .toList();
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

  @override
  Future changePassword(String oldPassword, String newPassword) async {
    return ApiService.sendRequest(
      endpoint: EndPoints.changePassword.copyWithDTO(
        ChangePasswordDTO(
          oldPassword: oldPassword,
          newPassword: newPassword,
        ),
      ),
    );
  }

  @override
  deleteAccount() async {
    return ApiService.sendRequest(
      endpoint: EndPoints.deleteAccountEndpoint,
    );
  }

  @override
  Future updatePreferencesEndpoint(PreferencesDTO dto) {
    return ApiService.sendRequest(
      endpoint: EndPoints.updatePreferencesEndpoint.copyWithDTO(dto),
    );
  }

  @override
  Future updateNotificationPreferences(PreferencesDTO preferences) async {
    return ApiService.sendRequest(
      endpoint: EndPoints.updatePreferencesEndpoint.copyWithDTO(preferences),
    );
  }

  @override
  Future changeLanguage(Locale locale) async {
    return ApiService.sendRequest(
      endpoint: EndPoints.updateLanguageEndpoint,
    );
  }

  @override
  Future<List<UserReservationPayments>> getReservationHistory() async {
    ApiResponse response = await ApiService.sendRequest(
      endpoint: EndPoints.getReservationHistoryEndpoint,
    );

    return response.data['results']
        .map<UserReservationPayments>(
            (e) => UserReservationPayments.fromJson(e))
        .toList();
  }
}

abstract class IUserRepository {
  Future<void> changeLanguage(Locale locale);
  Future<void> createUser();
  Future<void> deleteUser();

  Future<List<UserReservationPayments>> getReservationHistory();

  Future<List<Order>> getOrders();

  Future updatePreferencesEndpoint(PreferencesDTO dto);

  Future deleteAccount();

  Future updateNotificationPreferences(PreferencesDTO preferences);

  Future<LetDemUser> getUser();

  Future changePassword(String oldPassword, String newPassword);

  Future<void> updateUser(EditBasicInfoDTO dto);
}
