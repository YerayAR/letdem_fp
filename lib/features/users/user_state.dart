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

  const UserLoaded({required this.user});

  @override
  // TODO: implement props
  List<Object?> get props => [user];
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
