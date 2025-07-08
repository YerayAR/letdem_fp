part of 'user_bloc.dart';

sealed class UserEvent extends Equatable {
  const UserEvent();
}

class FetchUserInfoEvent extends UserEvent {
  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class UpdateUserNotificationsEvent extends UserEvent {
  final int unreadNotificationsCount;

  const UpdateUserNotificationsEvent({required this.unreadNotificationsCount});

  @override
  List<Object?> get props => [unreadNotificationsCount];
}

class FetchReservationHistoryEvent extends UserEvent {
  @override
  List<Object?> get props => [];
}

class ChangeLanguageEvent extends UserEvent {
  final Locale locale;

  const ChangeLanguageEvent({required this.locale});
  @override
  // TODO: implement props
  List<Object?> get props => [locale];
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

class UpdateEarningAccountEvent extends UserEvent {
  final EarningAccount account;

  const UpdateEarningAccountEvent({required this.account});

  @override
  List<Object?> get props => [account];
}

class UpdateNotificationPreferencesEvent extends UserEvent {
  final bool pushNotifications;
  final bool emailNotifications;

  const UpdateNotificationPreferencesEvent(
      {required this.pushNotifications, required this.emailNotifications});

  @override
  // TODO: implement props
  List<Object?> get props => [pushNotifications, emailNotifications];
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

class LoadOrdersEvent extends UserEvent {
  const LoadOrdersEvent();

  @override
  List<Object?> get props => [];
}

class UserLoggedOutEvent extends UserEvent {
  @override
  // TODO: implement props
  List<Object?> get props => [];
}
