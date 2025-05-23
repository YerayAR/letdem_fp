import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:letdem/features/activities/activities_state.dart';
import 'package:letdem/features/activities/dto/publish_event.dto.dart';
import 'package:letdem/features/activities/dto/publish_space.dto.dart';
import 'package:letdem/features/activities/repositories/activity.repository.dart';
import 'package:letdem/features/auth/dto/verify_email.dto.dart';
import 'package:letdem/services/api/endpoints.dart';
import 'package:letdem/services/api/models/error.dart';
import 'package:letdem/services/image/compressor.dart';
import 'package:letdem/services/location/location.service.dart';
import 'package:letdem/services/toast/toast.dart';

part 'activities_event.dart';

class ActivitiesBloc extends Bloc<ActivitiesEvent, ActivitiesState> {
  ActivityRepository activityRepository;
  ActivitiesBloc({
    required this.activityRepository,
  }) : super(ActivitiesInitial()) {
    on<PublishSpaceEvent>(_onPublishSpace);
    on<GetActivitiesEvent>(_onGetActivities);
    on<PublishRoadEventEvent>(_onPublishRoadEvent);
    on<TakeSpaceEvent>(_onTakeSpace);
    on<EventFeedBackEvent>(_onEventFeedBack);
    on<ReserveSpaceEvent>(_onReserveSpace);
    on<ConfirmSpaceReserveEvent>(_onConfirmSpaceReserveEvent);
  }

  Future<void> _onConfirmSpaceReserveEvent(
      ConfirmSpaceReserveEvent event, Emitter<ActivitiesState> emit) async {
    try {
      emit(ActivitiesLoading());
      await activityRepository.confirmSpaceReservation(
        spaceID: event.confirmationCode.spaceID,
        confirmationCode: event.confirmationCode,
      );
      emit(const ActivitiesPublished(totalPointsEarned: 0));
    } on ApiError catch (err) {
      emit(ActivitiesError(error: err.message));
    } catch (err) {
      emit(const ActivitiesError(error: "Unable to confirm space reservation"));
    }
  }

  Future<void> _onReserveSpace(
      ReserveSpaceEvent event, Emitter<ActivitiesState> emit) async {
    try {
      emit(ActivitiesLoading());
      var payload = await activityRepository.reserveSpace(
        spaceID: event.spaceID,
        paymentMethodID: event.paymentMethodID,
      );
      emit(SpaceReserved(spaceID: payload));
    } on ApiError catch (err) {
      emit(ActivitiesError(error: err.message));
    } catch (err, st) {
      print(err);
      print(st);

      emit(const ActivitiesError(error: "Unable to reserve space"));
    }
  }

  Future<void> _onEventFeedBack(
      EventFeedBackEvent event, Emitter<ActivitiesState> emit) async {
    try {
      emit(ActivitiesLoading());
      await activityRepository.eventFeedback(
        eventID: event.eventID,
        isThere: event.isThere,
      );
      emit(const ActivitiesPublished(totalPointsEarned: 0));
    } on ApiError catch (err) {
      emit(ActivitiesError(error: err.message));
    } catch (err) {
      emit(const ActivitiesError(error: "Unable to send feedback"));
    }
  }

  Future<void> _onTakeSpace(
      TakeSpaceEvent event, Emitter<ActivitiesState> emit) async {
    try {
      emit(ActivitiesLoading());
      await activityRepository.takeSpace(event.spaceID, event.type);
      emit(const ActivitiesPublished(totalPointsEarned: 0));
    } on ApiError catch (err) {
      emit(ActivitiesError(error: err.message));
      (Toast.showError(err.message));
    } catch (err) {
      emit(const ActivitiesError(error: "Unable to take space"));

      Toast.showError("Unable to take space");
    }
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
          price: event.price,
          waitTime: event.waitTime,
          phoneNumber: event.phoneNumber,
        ),
        event.price == null,
      );
      emit(const ActivitiesPublished(totalPointsEarned: 0));
    } on ApiError catch (err) {
      emit(ActivitiesError(error: err.message));
    } catch (err) {
      emit(const ActivitiesError(error: "Unable to publish space"));
    }
  }
}
