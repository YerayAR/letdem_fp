part of 'user_bloc.dart';

sealed class UserEvent extends Equatable {
  const UserEvent();
}

class FetchUserInfoEvent extends UserEvent {
  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class EditBasicInfoEvent extends UserEvent {
  final String firstName;
  final String lastName;

  const EditBasicInfoEvent({required this.firstName, required this.lastName});

  @override
  // TODO: implement props
  List<Object?> get props => [firstName, lastName];
}

class UserLoggedOutEvent extends UserEvent {
  @override
  // TODO: implement props
  List<Object?> get props => [];
}
