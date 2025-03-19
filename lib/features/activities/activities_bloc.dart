import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:letdem/features/activities/dto/publish_event.dto.dart';
import 'package:letdem/features/activities/dto/publish_space.dto.dart';
import 'package:letdem/features/activities/repositories/activity.repository.dart';
import 'package:letdem/models/activities/activity.model.dart';
import 'package:letdem/services/api/models/error.dart';
import 'package:letdem/services/image/compressor.dart';
import 'package:letdem/services/location/location.service.dart';

part 'activities_event.dart';
part 'activities_state.dart';

class ActivitiesBloc extends Bloc<ActivitiesEvent, ActivitiesState> {
  ActivityRepository activityRepository;
  ActivitiesBloc({
    required this.activityRepository,
  }) : super(ActivitiesInitial()) {
    on<PublishSpaceEvent>(_onPublishSpace);
    on<GetActivitiesEvent>(_onGetActivities);
    on<PublishRoadEventEvent>(_onPublishRoadEvent);
  }

  Future<void> _onPublishRoadEvent(
      PublishRoadEventEvent event, Emitter<ActivitiesState> emit) async {
    try {
      emit(ActivitiesLoading());

      var c = await MapboxService.getPlaceFromLatLng();
      await activityRepository.publishRoadEvent(
        PublishRoadEventDTO(
          type: event.type,
          streetName: event.locationName,
          latitude: c!.latitude,
          longitude: c.longitude,
        ),
      );
      emit(const ActivitiesPublished(
        totalPointsEarned: 10,
      ));
    } on ApiError catch (err) {
      emit(ActivitiesError(error: err.message));
    } catch (err) {
      emit(const ActivitiesError(error: "Unable to publish road event"));
    }
  }

  Future<void> _onGetActivities(
      GetActivitiesEvent event, Emitter<ActivitiesState> emit) async {
    try {
      emit(ActivitiesLoading());
      var activities = await activityRepository.getActivities();
      emit(ActivitiesLoaded(activities: activities.results));
    } on ApiError catch (err) {
      emit(ActivitiesError(error: err.message));
    } catch (err) {
      emit(const ActivitiesError(error: "Unable to load activities"));
    }
  }

  Future<void> _onPublishSpace(
      PublishSpaceEvent event, Emitter<ActivitiesState> emit) async {
    try {
      emit(ActivitiesLoading());

      var base64 = await ImageCompressor.compressImageToBase64(event.image);
      await activityRepository.publishSpace(
        PublishSpaceDTO(
          type: event.type,
          image: base64,
          streetName: event.locationName,
          latitude: event.latitude,
          longitude: event.longitude,
        ),
      );
      emit(const ActivitiesPublished(totalPointsEarned: 0));
    } on ApiError catch (err) {
      emit(ActivitiesError(error: err.message));
    } catch (err) {
      emit(const ActivitiesError(error: "Unable to publish space"));
    }
  }
}
