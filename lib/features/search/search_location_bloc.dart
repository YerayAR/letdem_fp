import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:letdem/features/search/dto/post_location.dto.dart';
import 'package:letdem/features/search/repository/search_location.repository.dart';

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
          locations: [...currentState.locations, location],
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
      emit(SearchLocationLoaded(locations: locations));
    } catch (e, st) {
      print(st);
      emit(SearchLocationError(message: e.toString()));
    }
  }
}
