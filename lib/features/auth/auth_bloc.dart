import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:letdem/features/auth/dto/email.dto.dart';
import 'package:letdem/features/auth/dto/login.dto.dart';
import 'package:letdem/features/auth/dto/register.dto.dart';
import 'package:letdem/features/auth/dto/verify_email.dto.dart';
import 'package:letdem/features/auth/repositories/auth.repository.dart';
import 'package:letdem/models/auth/tokens.model.dart';
import 'package:letdem/services/api/models/error.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    on<LoginEvent>(_onLoginUserEvent);
    on<RegisterEvent>(_onRegisterUserEvent);
    on<VerifyEmailEvent>(_onVerifyEmail);
    on<ResendVerificationCodeEvent>(_onResendVerificationCode);
  }

  Future<void> _onResendVerificationCode(
      ResendVerificationCodeEvent event, Emitter<AuthState> emit) async {
    try {
      emit(ResendVerificationCodeLoading());
      await authRepository.resendVerificationCode(EmailDTO(email: event.email));

      emit(ResendVerificationCodeSuccess());
    } on ApiError catch (err) {
      emit(RegisterError(error: err.message));
    } catch (err, sr) {
      print(sr);
      emit(const RegisterError(error: 'Unable to Resend Verification Code'));
    }
  }

  Future<void> _onVerifyEmail(
      VerifyEmailEvent event, Emitter<AuthState> emit) async {
    try {
      emit(OTPVerificationLoading());
      Tokens tokens = await authRepository.verifyEmailEvent(
          VerifyEmailDTO(email: event.email, otp: event.code));

      await tokens.write();

      emit(OTPVerificationSuccess());
    } on ApiError catch (err) {
      emit(RegisterError(error: err.message));
    } catch (err, sr) {
      print(sr);
      emit(const RegisterError(error: 'Unable to Verify Email'));
    }
  }

  Future<void> _onRegisterUserEvent(
      RegisterEvent event, Emitter<AuthState> emit) async {
    try {
      emit(RegisterLoading());
      await authRepository
          .register(RegisterDTO(email: event.email, password: event.password));

      emit(RegisterSuccess());
    } on ApiError catch (err) {
      emit(RegisterError(error: err.message));
    } catch (err, sr) {
      print(sr);
      emit(const RegisterError(error: 'Unable to Register'));
    }
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
