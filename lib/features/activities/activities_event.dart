part of 'activities_bloc.dart';

sealed class ActivitiesEvent extends Equatable {
  const ActivitiesEvent();
}

final class PublishRoadEventEvent extends ActivitiesEvent {
  final String locationName;
  final double latitude;
  final double longitude;
  final String type;

  const PublishRoadEventEvent(
      {required this.locationName,
      required this.type,
      required this.latitude,
      required this.longitude});

  @override
  // TODO: implement props
  List<Object?> get props => [locationName, latitude, longitude, type];
}

final class PublishSpaceEvent extends ActivitiesEvent {
  final File image;
  final String locationName;
  final double latitude;
  final double longitude;
  final String type;

  const PublishSpaceEvent(
      {required this.image,
      required this.locationName,
      required this.type,
      required this.latitude,
      required this.longitude});

  @override
  // TODO: implement props
  List<Object?> get props => [image, locationName, latitude, longitude];
}

final class GetActivitiesEvent extends ActivitiesEvent {
  @override
  // TODO: implement props
  List<Object?> get props => [];
}
