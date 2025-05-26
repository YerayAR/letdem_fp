import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:letdem/core/enums/LetDemLocationType.dart';
import 'package:letdem/features/search/dto/post_location.dto.dart';
import 'package:letdem/features/search/repository/search_location.repository.dart';
import 'package:letdem/infrastructure/services/mapbox_search/models/cache.dart';
import 'package:letdem/infrastructure/services/mapbox_search/models/model.dart';
import 'package:letdem/models/location/local_location.model.dart';

part 'search_location_event.dart';
part 'search_location_state.dart';

class SearchLocationBloc
    extends Bloc<SearchLocationEvent, SearchLocationState> {
  final SearchLocationRepository searchLocationRepository;
  SearchLocationBloc({required this.searchLocationRepository})
      : super(SearchLocationInitial()) {
    on<GetLocationListEvent>(_getLocationList);
    on<CreateLocationEvent>(_createLocation);
    on<DeleteLocationEvent>(_deleteLocation);
    on<DeleteRecentLocationEvent>(_deleteRecentLocation);
    on<ClearRecentLocationEvent>(_clearRecentLocation);
  }

  void _clearRecentLocation(
    ClearRecentLocationEvent event,
    Emitter<SearchLocationState> emit,
  ) async {
    if (state is SearchLocationLoaded) {
      final currentState = state as SearchLocationLoaded;
      emit(currentState.copyWith(isLocationCreating: true));

      try {
        await DatabaseHelper().clearAll();
        emit(currentState.copyWith(
          recentPlaces: [],
          isLocationCreating: false,
        ));
      } catch (e) {
        emit(SearchLocationError(message: e.toString()));
      }
    }
  }

  void _deleteRecentLocation(
    DeleteRecentLocationEvent event,
    Emitter<SearchLocationState> emit,
  ) async {
    if (state is SearchLocationLoaded) {
      final currentState = state as SearchLocationLoaded;
      emit(currentState.copyWith(isLocationCreating: true));

      try {
        await DatabaseHelper().deletePlace(event.place.mapboxId);
        emit(currentState.copyWith(
          recentPlaces: currentState.recentPlaces
              .where((element) => element != event.place)
              .toList(),
          isLocationCreating: false,
        ));
      } catch (e) {
        emit(SearchLocationError(message: e.toString()));
      }
    }
  }

  void _deleteLocation(
    DeleteLocationEvent event,
    Emitter<SearchLocationState> emit,
  ) async {
    if (state is SearchLocationLoaded) {
      final currentState = state as SearchLocationLoaded;
      emit(currentState.copyWith(isLocationCreating: true));

      try {
        await searchLocationRepository.deleteLocation(event.locationType);
        emit(currentState.copyWith(
          locations: currentState.locations
              .where((element) => element.type != event.locationType)
              .toList(),
          isLocationCreating: false,
        ));
      } catch (e) {
        emit(SearchLocationError(message: e.toString()));
      }
    }
  }

  void _createLocation(
    CreateLocationEvent event,
    Emitter<SearchLocationState> emit,
  ) async {
    print('Creating location ${event.locationType.name}');
    if (state is SearchLocationLoaded) {
      final currentState = state as SearchLocationLoaded;
      emit(currentState.copyWith(isLocationCreating: true));

      try {
        final location = await searchLocationRepository.postLocation(
          PostLetDemoLocationDTO(
            name: event.name,
            latitude: event.latitude,
            longitude: event.longitude,
            type: event.locationType,
          ),
        );
        emit(currentState.copyWith(
          locations: event.isUpdating
              ? [
                  ...currentState.locations
                      .where((element) => element.type != event.locationType),
                  location
                ]
              : [...currentState.locations, location],
          isLocationCreating: false,
        ));
      } catch (e) {
        emit(SearchLocationError(message: e.toString()));
      }
    }
  }

  void _getLocationList(
    GetLocationListEvent event,
    Emitter<SearchLocationState> emit,
  ) async {
    emit(SearchLocationLoading());
    try {
      final locations = await searchLocationRepository.getLocationList();
      final recentPlaces = await DatabaseHelper().getPlaces();
      emit(SearchLocationLoaded(
          locations: locations, recentPlaces: recentPlaces));
    } catch (e, st) {
      print(st);
      emit(SearchLocationError(message: e.toString()));
    }
  }
}
