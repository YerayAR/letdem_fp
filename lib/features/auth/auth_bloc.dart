import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:letdem/features/auth/dto/login.dto.dart';
import 'package:letdem/features/auth/repositories/auth.repository.dart';
import 'package:letdem/models/auth/tokens.model.dart';
import 'package:letdem/services/api/models/error.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    on<LoginEvent>(_onLoginUserEvent);
  }

  Future<void> _onLoginUserEvent(
      LoginEvent event, Emitter<AuthState> emit) async {
    try {
      emit(LoginLoading());
      final Tokens tokens = await authRepository
          .login(LoginDTO(email: event.email, password: event.password));

      await tokens.write();
      emit(LoginSuccess());
    } on ApiError catch (err) {
      emit(LoginError(error: err.message));
    } catch (err, sr) {
      print(sr);
      emit(const LoginError(error: 'Unable to Login'));
    }
  }
}
