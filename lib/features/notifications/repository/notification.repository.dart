import 'package:letdem/features/notifications/models/notification.model.dart';
import 'package:letdem/features/notifications/repository/notification.interface.dart';
import 'package:letdem/services/api/api.service.dart';
import 'package:letdem/services/api/endpoints.dart';
import 'package:letdem/services/api/models/endpoint.dart';
import 'package:letdem/services/api/models/response.model.dart';

class NotificationRepository implements INotificationRepository {
  @override
  Future<NotificationModel> getNotifications(bool unreadOnly) async {
    EndPoints.notifications.setParams([
      QParam(key: 'read', value: (!unreadOnly).toString()),
    ]);
    ApiResponse res =
        await ApiService.sendRequest(endpoint: EndPoints.notifications);
    // Get notifications from database

    return NotificationModel.fromJson(res.data);
  }

  @override
  Future readNotification(String id) async {
    return await ApiService.sendRequest(
        endpoint: EndPoints.readNotification(id));
  }

  @override
  Future markNotificationAsRead(String id) async {
    return await ApiService.sendRequest(
        endpoint: EndPoints.markNotificationAsRead(id));
  }

  @override
  Future clearNotifications() async {
    return await ApiService.sendRequest(endpoint: EndPoints.clearNotifications);
  }
}

class NotificationModel {
  final int count;
  final String? next;
  final String? previous;
  final List<NotificationResult> results;

  NotificationModel({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      NotificationModel(
        count: json['count'],
        next: json['next'],
        previous: json['previous'],
        results: List<NotificationResult>.from(
            json['results'].map((x) => NotificationResult.fromJson(x))),
      );
}
