import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:letdem/core/enums/LetDemLocationType.dart';
import 'package:letdem/features/search/dto/post_location.dto.dart';
import 'package:letdem/features/search/repository/search_location.repository.dart';
import 'package:letdem/infrastructure/services/mapbox_search/models/cache.dart';
import 'package:letdem/infrastructure/services/mapbox_search/models/service.dart';
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
        emit(
          currentState.copyWith(recentPlaces: [], isLocationCreating: false),
        );
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
        await DatabaseHelper().deletePlace(event.place.placeId ?? '');
        emit(
          currentState.copyWith(
            recentPlaces:
                currentState.recentPlaces
                    .where((element) => element != event.place)
                    .toList(),
            isLocationCreating: false,
          ),
        );
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
        emit(
          currentState.copyWith(
            locations:
                currentState.locations
                    .where((element) => element.type != event.locationType)
                    .toList(),
            isLocationCreating: false,
          ),
        );
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

      late double latitude;
      late double longitude;
      // get lat and lng from recent places if available
      var value = await HereSearchApiService().getPlaceDetailsLatLng(
        event.placeID,
      );

      if (value != null) {
        latitude = value['lat'] as double;
        longitude = value['lng'] as double;
      } else {
        // Fallback to default values if not found
        latitude = 0.0;
        longitude = 0.0;
      }
      try {
        final location = await searchLocationRepository.postLocation(
          PostLetDemoLocationDTO(
            name: event.name,
            latitude: latitude,
            longitude: longitude,
            type: event.locationType,
          ),
        );
        emit(
          currentState.copyWith(
            locations:
                event.isUpdating
                    ? [
                      ...currentState.locations.where(
                        (element) => element.type != event.locationType,
                      ),
                      location,
                    ]
                    : [...currentState.locations, location],
            isLocationCreating: false,
          ),
        );
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
      var country = await getCountryCodeFromLocation();
      final locations = await searchLocationRepository.getLocationList();
      final recentPlaces = await DatabaseHelper().getPlaces();
      emit(
        SearchLocationLoaded(
          locations: locations,
          recentPlaces: recentPlaces,
          country: country,
        ),
      );
    } catch (e, st) {
      print(st);
      emit(SearchLocationError(message: e.toString()));
    }
  }
}

//extension to get country code from context

extension LocationExtension on BuildContext {
  String? get countryCode {
    var state = read<SearchLocationBloc>().state;

    if (state is SearchLocationLoaded) {
      return (state as SearchLocationLoaded).country;
    }
    return null;
  }
}
