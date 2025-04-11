import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';
import 'package:letdem/features/notifications/repository/notification.repository.dart';

part 'notifications_event.dart';
part 'notifications_state.dart';

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  final NotificationRepository notificationRepository;
  NotificationsBloc({required this.notificationRepository})
      : super(NotificationsInitial()) {
    on<LoadNotificationsEvent>(_onLoadNotifications);
    on<ReadNotificationEvent>(_onReadNotification);
    on<MarkNotificationAsReadEvent>(_onMarkNotificationAsRead);
    on<ClearNotificationsEvent>(_onClearNotifications);
  }

  Future<void> _onClearNotifications(
      ClearNotificationsEvent event, Emitter<NotificationsState> emit) async {
    try {
      if (state is NotificationsLoaded) {
        await notificationRepository.clearNotifications();

        emit(NotificationsLoaded(
          notifications: NotificationModel(
            count: 0,
            next: null,
            previous: null,
            results: [],
          ),
        ));
      }
    } catch (err) {
      emit(NotificationsError(error: "Unable to clear notifications"));
    }
  }

  Future<void> _onMarkNotificationAsRead(MarkNotificationAsReadEvent event,
      Emitter<NotificationsState> emit) async {
    try {
      await notificationRepository.markNotificationAsRead(event.id);
      //   remove notification from the list
    } catch (err) {
      emit(NotificationsError(error: "Unable to mark notification as read"));
    }
  }

  Future<void> _onReadNotification(
      ReadNotificationEvent event, Emitter<NotificationsState> emit) async {
    try {
      await notificationRepository.readNotification(event.id);
    } catch (err) {
      emit(NotificationsError(error: "Unable to read notification"));
    }
  }

  Future<void> _onLoadNotifications(
      LoadNotificationsEvent event, Emitter<NotificationsState> emit) async {
    try {
      emit(NotificationsLoading());
      var notifications = await notificationRepository.getNotifications();

      var currentPos = await Geolocator.getCurrentPosition();

      for (var notification in notifications.results) {
        notification.setDistance(currentPos);
      }

      emit(NotificationsLoaded(notifications: notifications));
    } catch (err, st) {
      print(st);
      emit(NotificationsError(error: "Unable to load notifications"));
    }
  }
}
