part of 'activities_bloc.dart';

sealed class ActivitiesEvent extends Equatable {
  const ActivitiesEvent();
}

final class EventFeedBackEvent extends ActivitiesEvent {
  final String eventID;
  final bool isThere;

  const EventFeedBackEvent({required this.eventID, required this.isThere});

  @override
  // TODO: implement props
  List<Object?> get props => [eventID, isThere];
}

final class TakeSpaceEvent extends ActivitiesEvent {
  final String spaceID;
  final TakeSpaceType type;

  const TakeSpaceEvent({required this.spaceID, required this.type});

  // TODO: implement props
  @override
  List<Object?> get props => [spaceID, type];
}

final class PublishRoadEventEvent extends ActivitiesEvent {
  final String locationName;
  final double latitude;
  final double longitude;
  final String type;

  const PublishRoadEventEvent({
    required this.locationName,
    required this.type,
    required this.latitude,
    required this.longitude,
  });

  @override
  // TODO: implement props
  List<Object?> get props => [locationName, latitude, longitude, type];
}

final class ConfirmSpaceReserveEvent extends ActivitiesEvent {
  final ConfirmationCodeDTO confirmationCode;

  const ConfirmSpaceReserveEvent({required this.confirmationCode});

  @override
  // TODO: implement props
  List<Object?> get props => [confirmationCode];
}

final class ReserveSpaceEvent extends ActivitiesEvent {
  final String spaceID;
  final String paymentMethodID;

  const ReserveSpaceEvent({
    required this.spaceID,
    required this.paymentMethodID,
  });

  @override
  // TODO: implement props
  List<Object?> get props => [spaceID, paymentMethodID];
}

class DeleteSpaceEvent extends ActivitiesEvent {
  final String spaceID;

  const DeleteSpaceEvent({required this.spaceID});

  @override
  // TODO: implement props
  List<Object?> get props => [spaceID];
}

final class CancelReservationEvent extends ActivitiesEvent {
  final String reservationId;

  const CancelReservationEvent({required this.reservationId});

  @override
  // TODO: implement props
  List<Object?> get props => [reservationId];
}

final class PublishSpaceEvent extends ActivitiesEvent {
  final File image;
  final String locationName;
  final double latitude;
  final double longitude;
  final String type;

  final String? price;
  final int? waitTime;
  final String? phoneNumber;

  const PublishSpaceEvent({
    required this.image,
    required this.locationName,
    required this.type,
    required this.latitude,
    required this.longitude,
    this.price,
    this.waitTime,
    this.phoneNumber,
  });

  @override
  // TODO: implement props
  List<Object?> get props => [
    image,
    locationName,
    latitude,
    longitude,
    type,
    price,
    waitTime,
    phoneNumber,
  ];
}

final class GetActivitiesEvent extends ActivitiesEvent {
  @override
  List<Object?> get props => [];
}

final class ExtendTimeEvent extends ActivitiesEvent {
  const ExtendTimeEvent({required this.spaceId, required this.time});

  final String spaceId;
  final int time;

  @override
  List<Object?> get props => [];
}
