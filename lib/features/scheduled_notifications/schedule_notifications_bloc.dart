import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:letdem/features/scheduled_notifications/repository/schedule_notifications.repository.dart';
import 'package:letdem/infrastructure/api/api/models/error.dart';
import 'package:letdem/infrastructure/toast/toast/toast.dart';
import 'package:letdem/models/map/coordinate.model.dart';

part 'schedule_notifications_event.dart';
part 'schedule_notifications_state.dart';

class ScheduleNotificationsBloc
    extends Bloc<ScheduleNotificationsEvent, ScheduleNotificationsState> {
  final ScheduleNotificationsRepository scheduleNotificationsRepository;
  ScheduleNotificationsBloc({required this.scheduleNotificationsRepository})
    : super(ScheduleNotificationsInitial()) {
    on<FetchScheduledNotificationsEvent>(_onFetchScheduledNotifications);
    on<DeleteScheduledNotificationEvent>(_onDeleteScheduledNotification);
    on<CreateScheduledNotificationEvent>(_onCreateScheduledNotification);
  }

  Future<void> _onCreateScheduledNotification(
    CreateScheduledNotificationEvent event,
    Emitter<ScheduleNotificationsState> emit,
  ) async {
    emit(ScheduleNotificationsLoading());
    try {
      ScheduledNotification? scheduledNotification;

      if (event.isUpdate) {
        scheduledNotification = await scheduleNotificationsRepository
            .updateScheduleNotification(
              event.eventID!,
              CreateScheduledNotificationDTO(
                startsAt: event.startsAt,
                endsAt: event.endsAt,
                location: LocationData(
                  point: event.location.point,
                  streetName: event.location.streetName,
                ),
                radius: event.radius,
              ),
            );
      } else {
        await scheduleNotificationsRepository.createScheduleNotification(
          CreateScheduledNotificationDTO(
            startsAt: event.startsAt,
            endsAt: event.endsAt,
            location: LocationData(
              point: event.location.point,
              streetName: event.location.streetName,
            ),
            radius: event.radius,
          ),
        );
      }
      if (event.isUpdate) {
        final scheduledNotifications =
            await scheduleNotificationsRepository.getScheduleNotification();

        emit(ScheduleNotificationsLoaded(scheduledNotifications));
      } else {
        emit(const ScheduleNotificationCreated());
      }
    } on ApiError catch (err) {
      emit(
        const ScheduleNotificationsError(
          'Failed to create scheduled notification',
        ),
      );
      Toast.showError(err.message);
    } catch (e) {
      emit(
        const ScheduleNotificationsError(
          'Failed to create scheduled notification',
        ),
      );

      Toast.showError('Failed to create scheduled notification');
    }
  }

  Future<void> _onDeleteScheduledNotification(
    DeleteScheduledNotificationEvent event,
    Emitter<ScheduleNotificationsState> emit,
  ) async {
    if (state is ScheduleNotificationsLoaded) {
      final currentState = state as ScheduleNotificationsLoaded;
      emit(ScheduleNotificationsLoading());
      try {
        await scheduleNotificationsRepository.deleteScheduleNotification(
          event.id,
        );
        final updatedScheduledNotifications =
            currentState.scheduledNotifications
                .where((element) => element.id != event.id)
                .toList();
        emit(ScheduleNotificationsLoaded(updatedScheduledNotifications));
      } catch (e) {
        Toast.showError('Failed to delete scheduled notification');
        emit(
          const ScheduleNotificationsError(
            'Failed to delete scheduled notification',
          ),
        );
      }
    }
  }

  Future<void> _onFetchScheduledNotifications(
    FetchScheduledNotificationsEvent event,
    Emitter<ScheduleNotificationsState> emit,
  ) async {
    emit(ScheduleNotificationsLoading());
    try {
      final scheduledNotifications =
          await scheduleNotificationsRepository.getScheduleNotification();
      emit(ScheduleNotificationsLoaded(scheduledNotifications));
    } catch (e) {
      emit(
        const ScheduleNotificationsError(
          'Failed to fetch scheduled notifications',
        ),
      );
    }
  }
}
