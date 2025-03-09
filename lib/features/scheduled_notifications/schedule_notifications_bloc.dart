import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'schedule_notifications_event.dart';
part 'schedule_notifications_state.dart';

class ScheduleNotificationsBloc extends Bloc<ScheduleNotificationsEvent, ScheduleNotificationsState> {
  ScheduleNotificationsBloc() : super(ScheduleNotificationsInitial()) {
    on<ScheduleNotificationsEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
