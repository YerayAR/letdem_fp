part of 'map_bloc.dart';

sealed class MapEvent extends Equatable {
  const MapEvent();
}

class GetNearbyPlaces extends MapEvent {
  final MapQueryParams queryParams;

  const GetNearbyPlaces({required this.queryParams});

  @override
  List<Object> get props => [queryParams];
}
