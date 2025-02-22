part of 'user_bloc.dart';

sealed class UserState extends Equatable {
  const UserState();
}

final class UserLoggedOutState extends UserState {
  @override
  // TODO: implement props
  List<Object?> get props => [];
}

final class UserInitial extends UserState {
  @override
  List<Object> get props => [];
}

class UserLoading extends UserState {
  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class UserLoaded extends UserState {
  final LetDemUser user;
  final int points;

  final bool isLocationPermissionGranted;

  const UserLoaded({
    required this.user,
    required this.isLocationPermissionGranted,
    required this.points,
  });

  UserLoaded copyWith({
    LetDemUser? user,
    bool? isLocationPermissionGranted,
    int? points,
  }) {
    return UserLoaded(
      user: user ?? this.user,
      isLocationPermissionGranted:
          isLocationPermissionGranted ?? this.isLocationPermissionGranted,
      points: points ?? this.points,
    );
  }

  @override
  // TODO: implement props
  List<Object?> get props => [
        user,
        isLocationPermissionGranted,
        points,
      ];
}

class UserError extends UserState {
  final String error;
  final ApiError? apiError;

  const UserError({
    required this.error,
    this.apiError,
  });
  @override
  // TODO: implement props
  List<Object?> get props => [error];
}
