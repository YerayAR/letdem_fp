import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:letdem/core/extensions/location.dart';
import 'package:letdem/features/auth/models/tokens.model.dart';
import 'package:letdem/features/users/dto/edit_basic_info.dto.dart';
import 'package:letdem/features/users/models/user.model.dart';
import 'package:letdem/features/users/repository/user.repository.dart';
import 'package:letdem/infrastructure/api/api/models/error.dart';
import 'package:letdem/infrastructure/services/res/navigator.dart';
import 'package:letdem/infrastructure/toast/toast/toast.dart';
import 'package:letdem/models/earnings_account/earning_account.model.dart';
import 'package:letdem/models/orders/order.model.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

part 'user_event.dart';
part 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  UserRepository userRepository;

  UserBloc({required this.userRepository}) : super(UserInitial()) {
    on<FetchUserInfoEvent>(_onFetchUserInfo);
    on<UserLoggedOutEvent>(_onUserLoggedOut);
    on<EditBasicInfoEvent>(_onEditBasicInfo);
    on<IncreaseUserPointEvent>(_onIncreaseUserPoint);
    on<ChangePasswordEvent>(_onChangePassword);
    on<ChangeLanguageEvent>(_onChangeLanguage);
    on<UpdateEarningAccountEvent>(_onUpdateEarningAccount);
    on<DeleteAccountEvent>(_onDeleteAccount);
    on<LoadOrdersEvent>(_onLoadOrdererInfo);
    on<UpdatePreferencesEvent>(_onUpdatePreferences);
    on<UpdateNotificationPreferencesEvent>(_onUpdateNotificationPreferences);
  }

  Future<void> _onLoadOrdererInfo(
      LoadOrdersEvent event, Emitter<UserState> emit) async {
    try {
      if (state is UserLoaded) {
        UserLoaded userLoaded = state as UserLoaded;
        emit(userLoaded.copyWith(
          isOrdersLoading: true,
        ));

        var orders = await userRepository.getOrders();

        print(orders);

        emit(userLoaded.copyWith(
          isOrdersLoading: false,
          orders: orders,
        ));
      }
    } catch (err, st) {
      print(err);
      print(st);

      add(FetchUserInfoEvent());
    }
  }

  Future<void> _onUpdateEarningAccount(
      UpdateEarningAccountEvent event, Emitter<UserState> emit) async {
    try {
      if (state is UserLoaded) {
        UserLoaded userLoaded = state as UserLoaded;

        final updatedUser = userLoaded.user.copyWith(
          earningAccount: event.account,
        );
        emit(UserLoaded(
          user: updatedUser,
          points: userLoaded.points,
          isLocationPermissionGranted: userLoaded.isLocationPermissionGranted,
        ));
      }
    } on ApiError catch (err) {
      emit(UserError(error: err.message, apiError: err));
    } catch (err) {
      emit(const UserError(error: "Unable to load user"));
    }
  }

  Future<void> _onChangeLanguage(
      ChangeLanguageEvent event, Emitter<UserState> emit) async {
    if (state is UserLoaded) {
      UserLoaded userLoaded = state as UserLoaded;

      try {
        emit(userLoaded.copyWith(
          isUpdateLoading: true,
        ));
        await userRepository.changeLanguage(event.locale);

        emit(userLoaded.copyWith(
          isUpdateLoading: false,
        ));
        emit(const UserInfoChanged());
      } on ApiError catch (err) {
        emit(userLoaded.copyWith(
          isUpdateLoading: false,
        ));
        Toast.showError(err.message);
      } catch (err) {
        emit(userLoaded.copyWith(
          isUpdateLoading: false,
        ));
        Toast.showError("Unable to change language");
      }
    }
  }

  Future<void> _onUpdateNotificationPreferences(
      UpdateNotificationPreferencesEvent event, Emitter<UserState> emit) async {
    if (state is UserLoaded) {
      UserLoaded userLoaded = state as UserLoaded;

      try {
        emit(userLoaded.copyWith(
          isUpdateLoading: true,
        ));
        await userRepository.updateNotificationPreferences(PreferencesDTO(
          preferences: [],
          notificationsPreferences: [
            {
              'push': event.pushNotifications,
            },
            {
              'email': event.emailNotifications,
            },
          ],
        ));

        emit(userLoaded.copyWith(
          isUpdateLoading: false,
        ));
        emit(const UserInfoChanged());
      } on ApiError catch (err) {
        emit(userLoaded.copyWith(
          isUpdateLoading: false,
        ));
        Toast.showError(err.message);
      } catch (err) {
        emit(userLoaded.copyWith(
          isUpdateLoading: false,
        ));
        Toast.showError("Unable to update notification preferences");
      }
    }
  }

  Future<void> _onUpdatePreferences(
      UpdatePreferencesEvent event, Emitter<UserState> emit) async {
    if (state is UserLoaded) {
      UserLoaded userLoaded = state as UserLoaded;

      try {
        emit(userLoaded.copyWith(
          isUpdateLoading: true,
        ));
        await userRepository.updatePreferencesEndpoint(
          PreferencesDTO(
              preferences: event.preferences, notificationsPreferences: []),
        );

        emit(userLoaded.copyWith(
          isUpdateLoading: false,
        ));
        emit(const UserInfoChanged());
      } on ApiError catch (err) {
        emit(userLoaded.copyWith(
          isUpdateLoading: false,
        ));
        Toast.showError(err.message);
      } catch (err) {
        emit(userLoaded.copyWith(
          isUpdateLoading: false,
        ));
        Toast.showError("Unable to update preferences");
      }
    }
  }

  Future<void> _onDeleteAccount(
      DeleteAccountEvent event, Emitter<UserState> emit) async {
    try {
      emit(UserLoading());
      await userRepository.deleteAccount();
      await Tokens.delete();
      emit(UserLoggedOutState());
    } on ApiError catch (err) {
      emit(UserError(error: err.message, apiError: err));
    } catch (err) {
      emit(const UserError(error: "Unable to delete account"));
    }
  }

  Future<void> _onChangePassword(
      ChangePasswordEvent event, Emitter<UserState> emit) async {
    if (state is UserLoaded) {
      UserLoaded userLoaded = state as UserLoaded;

      try {
        emit(userLoaded.copyWith(
          isUpdateLoading: true,
        ));
        await userRepository.changePassword(
          event.oldPassword,
          event.newPassword,
        );

        emit(userLoaded.copyWith(
          isUpdateLoading: false,
        ));
        emit(const UserInfoChanged());
      } on ApiError catch (err) {
        emit(userLoaded.copyWith(
          isUpdateLoading: false,
        ));
        Toast.showError(err.message);
      } catch (err) {
        emit(userLoaded.copyWith(
          isUpdateLoading: false,
        ));
        Toast.showError("Unable to change password");
      }
    }
  }

  Future<void> _onIncreaseUserPoint(
      IncreaseUserPointEvent event, Emitter<UserState> emit) async {
    try {
      if (state is UserLoaded) {
        UserLoaded userLoaded = state as UserLoaded;
        emit(userLoaded.copyWith(
          points: userLoaded.points + event.points,
        ));
      }
    } on ApiError catch (err) {
      emit(UserError(error: err.message, apiError: err));
    } catch (err) {
      emit(const UserError(error: "Unable to load user"));
    }
  }

  Future<void> _onEditBasicInfo(
      EditBasicInfoEvent event, Emitter<UserState> emit) async {
    try {
      emit(UserLoading());

      await userRepository.updateUser(
        EditBasicInfoDTO(
          firstName: event.firstName,
          lastName: event.lastName,
        ),
      );

      bool isLocationPermissionGranted = await NavigatorHelper
          .navigatorKey.currentState!.context.hasLocationPermission;

      var user = await userRepository.getUser();

      emit(UserLoaded(
        user: user,
        points: user.totalPoints,
        isLocationPermissionGranted: isLocationPermissionGranted,
      ));
    } on ApiError catch (err) {
      emit(UserError(error: err.message, apiError: err));
    } catch (err) {
      emit(const UserError(error: "Unable to load user"));
    }
  }

  Future<void> _onUserLoggedOut(
      UserLoggedOutEvent event, Emitter<UserState> emit) async {
    await Tokens.delete();
    emit(UserLoggedOutState());
  }

  Future<void> _onFetchUserInfo(
      FetchUserInfoEvent event, Emitter<UserState> emit) async {
    try {
      emit(UserLoading());

      LetDemUser user = await userRepository.getUser();

      await OneSignal.Notifications.requestPermission(true);
      await OneSignal.login(user.id);

      bool isLocationPermissionGranted = await NavigatorHelper
          .navigatorKey.currentState!.context.hasLocationPermission;

      emit(UserLoaded(
        points: user.totalPoints,
        user: user,
        isLocationPermissionGranted: isLocationPermissionGranted,
      ));
    } on ApiError catch (err) {
      emit(UserError(error: err.message, apiError: err));
    } catch (err, strack) {
      print(err);
      print(strack);
      emit(const UserError(error: "Unable to load user"));
    }
  }
}
