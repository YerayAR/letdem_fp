import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:letdem/extenstions/location.dart';
import 'package:letdem/features/users/repository/user.repository.dart';
import 'package:letdem/models/auth/tokens.model.dart';
import 'package:letdem/services/api/models/error.dart';
import 'package:letdem/services/res/navigator.dart';

part 'user_event.dart';
part 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  UserRepository userRepository;

  UserBloc({required this.userRepository}) : super(UserInitial()) {
    on<FetchUserInfoEvent>(_onFetchUserInfo);
    on<UserLoggedOutEvent>(_onUserLoggedOut);
    on<EditBasicInfoEvent>(_onEditBasicInfo);
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

      emit(UserLoaded(
        user: await userRepository.getUser(),
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
      bool isLocationPermissionGranted = await NavigatorHelper
          .navigatorKey.currentState!.context.hasLocationPermission;

      emit(UserLoaded(
        user: await userRepository.getUser(),
        isLocationPermissionGranted: isLocationPermissionGranted,
      ));
    } on ApiError catch (err) {
      emit(UserError(error: err.message, apiError: err));
    } catch (err) {
      emit(const UserError(error: "Unable to load user"));
    }
  }
}
