import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:letdem/services/toast/toast.dart';

import 'repository/schedule_notifications.repository.dart';

part 'schedule_notifications_event.dart';
part 'schedule_notifications_state.dart';

class ScheduleNotificationsBloc
    extends Bloc<ScheduleNotificationsEvent, ScheduleNotificationsState> {
  final ScheduleNotificationsRepository scheduleNotificationsRepository;
  ScheduleNotificationsBloc({
    required this.scheduleNotificationsRepository,
  }) : super(ScheduleNotificationsInitial()) {
    on<FetchScheduledNotificationsEvent>(_onFetchScheduledNotifications);
    on<DeleteScheduledNotificationEvent>(_onDeleteScheduledNotification);
  }

  Future<void> _onDeleteScheduledNotification(
      DeleteScheduledNotificationEvent event,
      Emitter<ScheduleNotificationsState> emit) async {
    emit(ScheduleNotificationsLoading());
    if (state is ScheduleNotificationsLoaded) {
      final currentState = state as ScheduleNotificationsLoaded;
      try {
        await scheduleNotificationsRepository
            .deleteScheduleNotification(event.id);
        final updatedScheduledNotifications = currentState
            .scheduledNotifications
            .where((element) => element.id != event.id)
            .toList();
        emit(ScheduleNotificationsLoaded(updatedScheduledNotifications));
      } catch (e) {
        Toast.showError('Failed to delete scheduled notification');
        emit(const ScheduleNotificationsError(
            'Failed to delete scheduled notification'));
      }
    }
  }

  Future<void> _onFetchScheduledNotifications(
      FetchScheduledNotificationsEvent event,
      Emitter<ScheduleNotificationsState> emit) async {
    emit(ScheduleNotificationsLoading());
    try {
      final scheduledNotifications =
          await scheduleNotificationsRepository.getScheduleNotification();
      emit(ScheduleNotificationsLoaded(scheduledNotifications));
    } catch (e) {
      emit(const ScheduleNotificationsError(
          'Failed to fetch scheduled notifications'));
    }
  }
}
