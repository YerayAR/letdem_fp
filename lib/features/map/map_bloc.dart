import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:letdem/features/map/repository/map.repository.dart';
import 'package:letdem/models/auth/map/map_options.model.dart';
import 'package:letdem/models/auth/map/nearby_payload.model.dart';

part 'map_event.dart';
part 'map_state.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  final MapRepository mapRepository;
  MapBloc({required this.mapRepository}) : super(MapInitial()) {
    on<GetNearbyPlaces>((event, emit) async {
      emit(MapLoading());
      try {
        var p =
            await mapRepository.getNearbyPlaces(queryParams: event.queryParams);
        emit(MapLoaded(payload: p));
      } catch (e, st) {
        print(st);
        emit(MapError(message: e.toString()));
      }
    });
  }
}
