part of 'activities_bloc.dart';

sealed class ActivitiesState extends Equatable {
  const ActivitiesState();
}

final class ActivitiesInitial extends ActivitiesState {
  @override
  List<Object> get props => [];
}

final class ActivitiesLoading extends ActivitiesState {
  @override
  List<Object?> get props => [];
}

final class ActivitiesLoaded extends ActivitiesState {
  final List<Activity> activities;

  const ActivitiesLoaded({required this.activities});

  @override
  List<Object?> get props => [activities];
}

final class ActivitiesPublished extends ActivitiesState {
  final int totalPointsEarned;

  const ActivitiesPublished({required this.totalPointsEarned});
  @override
  List<Object?> get props => [totalPointsEarned];
}

final class ActivitiesError extends ActivitiesState {
  final String error;

  const ActivitiesError({required this.error});

  @override
  List<Object?> get props => [error];
}
