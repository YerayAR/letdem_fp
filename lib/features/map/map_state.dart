part of 'map_bloc.dart';

sealed class MapState extends Equatable {
  const MapState();
}

final class MapInitial extends MapState {
  @override
  List<Object> get props => [];
}

class MapLoading extends MapState {
  @override
  List<Object> get props => [];
}

class MapLoaded extends MapState {
  final MapNearbyPayload payload;

  const MapLoaded({required this.payload});

  @override
  List<Object> get props => [payload];
}

class MapError extends MapState {
  final String message;

  const MapError({required this.message});

  @override
  List<Object> get props => [message];
}

class NearByPlace {}
