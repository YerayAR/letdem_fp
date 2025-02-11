import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:letdem/features/activities/repositories/activity.repository.dart';

part 'activities_event.dart';
part 'activities_state.dart';

class ActivitiesBloc extends Bloc<ActivitiesEvent, ActivitiesState> {
  ActivityRepository activityRepository;
  ActivitiesBloc({
    required this.activityRepository,
  }) : super(ActivitiesInitial()) {
    on<ActivitiesEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
