import 'package:letdem/features/scheduled_notifications/schedule_notifications_bloc.dart';
import 'package:letdem/services/api/api.service.dart';
import 'package:letdem/services/api/endpoints.dart';
import 'package:letdem/services/api/models/endpoint.dart';
import 'package:letdem/services/api/models/response.model.dart';

class ScheduleNotificationsRepository extends IScheduleNotificationsRepository {
  @override
  Future createScheduleNotification(CreateScheduledNotificationDTO dto) async {
    await ApiService.sendRequest(
      endpoint: EndPoints.createScheduleNotification.copyWithDTO(dto),
    );
  }

  @override
  Future<ScheduledNotification> updateScheduleNotification(
      String scheduleNotificationId, CreateScheduledNotificationDTO dto) async {
    ApiResponse response = await ApiService.sendRequest(
      endpoint: EndPoints.updateScheduleNotification(scheduleNotificationId)
          .copyWithDTO(dto),
    );

    return ScheduledNotification.fromJson(response.data);
  }

  @override
  Future deleteScheduleNotification(String scheduleNotificationId) async {
    return await ApiService.sendRequest(
      endpoint: EndPoints.deleteScheduleNotification(scheduleNotificationId),
    );
  }

  @override
  Future<List<ScheduledNotification>> getScheduleNotification() async {
    ApiResponse res = await ApiService.sendRequest(
      endpoint: EndPoints.getScheduleNotification,
    );
    return res.data['results']
        .map<ScheduledNotification>((e) => ScheduledNotification.fromJson(e))
        .toList();
  }
}

abstract class IScheduleNotificationsRepository {
  Future<void> createScheduleNotification(CreateScheduledNotificationDTO dto);
  Future<void> deleteScheduleNotification(String scheduleNotificationId);
  Future<ScheduledNotification> updateScheduleNotification(
      String scheduleNotificationId, CreateScheduledNotificationDTO dto);
  Future<List<ScheduledNotification>> getScheduleNotification();
}

class CreateScheduledNotificationDTO extends DTO {
  final DateTime startsAt;
  final DateTime endsAt;
  final LocationData location;
  final double radius;

  CreateScheduledNotificationDTO(
      {required this.startsAt,
      required this.endsAt,
      required this.location,
      required this.radius});

  @override
  Map<String, dynamic> toMap() {
    return {
      'starts_at': startsAt.toIso8601String(),
      'ends_at': endsAt.toIso8601String(),
      'location': {
        'lat': location.point.latitude,
        'lng': location.point.longitude,
        'street_name': location.streetName,
      },
      'radius': radius,
    };
  }
}
