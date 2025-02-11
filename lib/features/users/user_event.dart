part of 'user_bloc.dart';

sealed class UserEvent extends Equatable {
  const UserEvent();
}

class FetchUserInfoEvent extends UserEvent {
  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class UserLoggedOutEvent extends UserEvent {
  @override
  // TODO: implement props
  List<Object?> get props => [];
}
