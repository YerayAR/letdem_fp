part of 'activities_bloc.dart';

sealed class ActivitiesState extends Equatable {
  const ActivitiesState();
}

final class ActivitiesInitial extends ActivitiesState {
  @override
  List<Object> get props => [];
}
