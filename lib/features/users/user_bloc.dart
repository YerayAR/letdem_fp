import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:letdem/extenstions/location.dart';
import 'package:letdem/features/users/repository/user.repository.dart';
import 'package:letdem/models/auth/tokens.model.dart';
import 'package:letdem/services/api/models/error.dart';
import 'package:letdem/services/res/navigator.dart';
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
      print(strack);
      emit(const UserError(error: "Unable to load user"));
    }
  }
}
