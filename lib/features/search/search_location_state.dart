part of 'search_location_bloc.dart';

sealed class SearchLocationState extends Equatable {
  const SearchLocationState();
}

final class SearchLocationInitial extends SearchLocationState {
  @override
  List<Object> get props => [];
}
