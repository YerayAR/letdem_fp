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

class UserInfoChanged extends UserState {
  const UserInfoChanged();

  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class UserLoaded extends UserState {
  final LetDemUser user;

  final int points;

  final List<UserReservationPayments> reservationHistory;

  final int unreadNotificationsCount;

  final bool isUpdateLoading;

  final bool isLocationPermissionGranted;

  final List<Order> orders;
  final bool isOrdersLoading;

  const UserLoaded({
    required this.user,
    this.isUpdateLoading = false,
    required this.isLocationPermissionGranted,
    required this.points,
    this.isOrdersLoading = false,
    this.reservationHistory = const [],
    required this.unreadNotificationsCount,
    this.orders = const [],
  });

  UserLoaded copyWith({
    LetDemUser? user,
    bool? isLocationPermissionGranted,
    bool? isOrdersLoading,
    bool? isUpdateLoading,
    List<UserReservationPayments>? reservationHistory,
    int? unreadNotificationsCount,
    List<Order>? orders,
    int? points,
  }) {
    return UserLoaded(
      user: user ?? this.user,
      reservationHistory: reservationHistory ?? this.reservationHistory,
      unreadNotificationsCount:
          unreadNotificationsCount ?? this.unreadNotificationsCount,
      isOrdersLoading: isOrdersLoading ?? this.isOrdersLoading,
      orders: orders ?? this.orders,
      isUpdateLoading: isUpdateLoading ?? this.isUpdateLoading,
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
        isUpdateLoading,
        isOrdersLoading,
        unreadNotificationsCount,
        reservationHistory,
        orders,
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
