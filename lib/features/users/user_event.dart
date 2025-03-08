part of 'user_bloc.dart';

sealed class UserEvent extends Equatable {
  const UserEvent();
}

class FetchUserInfoEvent extends UserEvent {
  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class ChangePasswordEvent extends UserEvent {
  final String oldPassword;
  final String newPassword;

  const ChangePasswordEvent(
      {required this.oldPassword, required this.newPassword});

  @override
  // TODO: implement props
  List<Object?> get props => [oldPassword, newPassword];
}

class UpdatePreferencesEvent extends UserEvent {
  final List<Map<String, bool>> preferences;

  const UpdatePreferencesEvent({required this.preferences});

  @override
  // TODO: implement props
  List<Object?> get props => [preferences];
}

class EditBasicInfoEvent extends UserEvent {
  final String firstName;
  final String lastName;

  const EditBasicInfoEvent({required this.firstName, required this.lastName});

  @override
  // TODO: implement props
  List<Object?> get props => [firstName, lastName];
}

class IncreaseUserPointEvent extends UserEvent {
  final int points;

  const IncreaseUserPointEvent({required this.points});

  @override
  // TODO: implement props
  List<Object?> get props => [points];
}

class DeleteAccountEvent extends UserEvent {
  @override
  List<Object?> get props => [];
}

class UserLoggedOutEvent extends UserEvent {
  @override
  // TODO: implement props
  List<Object?> get props => [];
}
