import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'search_location_event.dart';
part 'search_location_state.dart';

class SearchLocationBloc extends Bloc<SearchLocationEvent, SearchLocationState> {
  SearchLocationBloc() : super(SearchLocationInitial()) {
    on<SearchLocationEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
