import 'package:letdem/features/scheduled_notifications/schedule_notifications_bloc.dart';
import 'package:letdem/services/api/api.service.dart';
import 'package:letdem/services/api/endpoints.dart';
import 'package:letdem/services/api/models/response.model.dart';

class ScheduleNotificationsRepository extends IScheduleNotificationsRepository {
  @override
  Future<void> createScheduleNotification() {
    // TODO: implement createScheduleNotification
    throw UnimplementedError();
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

  @override
  Future<void> updateScheduleNotification() {
    // TODO: implement updateScheduleNotification
    throw UnimplementedError();
  }
}

abstract class IScheduleNotificationsRepository {
  Future<void> createScheduleNotification();
  Future<void> deleteScheduleNotification(String scheduleNotificationId);
  Future<void> updateScheduleNotification();
  Future<List<ScheduledNotification>> getScheduleNotification();
}
