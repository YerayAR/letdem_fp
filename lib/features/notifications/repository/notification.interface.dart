import 'package:letdem/features/notifications/repository/notification.repository.dart';

abstract class INotificationRepository {
  Future<void> clearNotifications();
  Future<NotificationModel> getNotifications(bool unreadOnly);
  Future<void> markNotificationAsRead(String id);

  Future readNotification(String id);
}
