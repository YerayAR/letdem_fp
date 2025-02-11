import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:letdem/features/users/repository/user.repository.dart';
import 'package:letdem/models/auth/tokens.model.dart';
import 'package:letdem/services/api/models/error.dart';

part 'user_event.dart';
part 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  UserRepository userRepository;

  UserBloc({required this.userRepository}) : super(UserInitial()) {
    on<FetchUserInfoEvent>(_onFetchUserInfo);
    on<UserLoggedOutEvent>(_onUserLoggedOut);
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

      emit(UserLoaded(user: user));
    } on ApiError catch (err) {
      emit(UserError(error: err.message, apiError: err));
    } catch (err) {
      emit(const UserError(error: "Unable to load user"));
    }
  }
}
