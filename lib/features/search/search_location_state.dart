part of 'search_location_bloc.dart';

sealed class SearchLocationState extends Equatable {
  const SearchLocationState();
}

final class SearchLocationInitial extends SearchLocationState {
  @override
  List<Object> get props => [];
}

final class SearchLocationLoading extends SearchLocationState {
  @override
  List<Object> get props => [];
}

final class SearchLocationLoaded extends SearchLocationState {
  final List<LetDemLocation> locations;

  final List<MapBoxPlace> recentPlaces;
  final bool isLocationCreating;

  const SearchLocationLoaded({
    required this.locations,
    required this.recentPlaces,
    this.isLocationCreating = false,
  });

  SearchLocationLoaded copyWith({
    List<LetDemLocation>? locations,
    List<MapBoxPlace>? recentPlaces,
    bool? isLocationCreating,
  }) {
    return SearchLocationLoaded(
      recentPlaces: recentPlaces ?? this.recentPlaces,
      locations: locations ?? this.locations,
      isLocationCreating: isLocationCreating ?? this.isLocationCreating,
    );
  }

  @override
  List<Object> get props => [locations, isLocationCreating, recentPlaces];
}

final class SearchLocationError extends SearchLocationState {
  final String message;

  const SearchLocationError({required this.message});

  @override
  List<Object> get props => [message];
}
