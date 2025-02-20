part of 'search_location_bloc.dart';

sealed class SearchLocationEvent extends Equatable {
  const SearchLocationEvent();
}

final class GetLocationListEvent extends SearchLocationEvent {
  const GetLocationListEvent();

  @override
  // TODO: implement props
  List<Object?> get props => [];
}

final class DeleteRecentLocationEvent extends SearchLocationEvent {
  final MapBoxPlace place;

  const DeleteRecentLocationEvent({required this.place});

  @override
  List<Object?> get props => [place];
}

final class DeleteLocationEvent extends SearchLocationEvent {
  final LetDemLocationType locationType;

  const DeleteLocationEvent({required this.locationType});

  @override
  // TODO: implement props
  List<Object?> get props => [locationType];
}

final class ClearRecentLocationEvent extends SearchLocationEvent {
  const ClearRecentLocationEvent();

  @override
  // TODO: implement props
  List<Object?> get props => [];
}

final class CreateLocationEvent extends SearchLocationEvent {
  final LetDemLocationType locationType;
  final String name;
  final double latitude;
  final double longitude;

  const CreateLocationEvent({
    required this.locationType,
    required this.name,
    required this.latitude,
    required this.longitude,
  });

  @override
  // TODO: implement props
  List<Object?> get props => [locationType, name, latitude, longitude];
}
