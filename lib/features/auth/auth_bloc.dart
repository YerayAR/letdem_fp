import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:letdem/features/auth/dto/email.dto.dart';
import 'package:letdem/features/auth/dto/login.dto.dart';
import 'package:letdem/features/auth/dto/password_reset.dto.dart';
import 'package:letdem/features/auth/dto/register.dto.dart';
import 'package:letdem/features/auth/dto/token.dto.dart';
import 'package:letdem/features/auth/dto/verify_email.dto.dart';
import 'package:letdem/features/auth/repositories/auth.repository.dart';
import 'package:letdem/models/auth/tokens.model.dart';
import 'package:letdem/services/api/models/error.dart';
import 'package:letdem/services/google/google.service.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    on<LoginEvent>(_onLoginUserEvent);
    on<RegisterEvent>(_onRegisterUserEvent);
    on<VerifyEmailEvent>(_onVerifyEmail);
    on<ResendVerificationCodeEvent>(_onResendVerificationCode);
    on<FindForgotPasswordAccountEvent>(_onFindForgotPasswordAccount);
    on<ResendForgotPasswordVerificationCodeEvent>(
        _onResendForgotPasswordVerificationCode);
    on<ValidateResetPasswordEvent>(_onValidateResetPassword);
    on<ResetPasswordEvent>(_onResetPassword);
    on<GoogleLoginEvent>(_onGoogleLoginEvent);
    on<GoogleRegisterEvent>(_onGoogleRegisterEvent);
  }

  Future<void> _onGoogleRegisterEvent(
      GoogleRegisterEvent event, Emitter<AuthState> emit) async {
    try {
      emit(RegisterLoading());
      var at = await GoogleAuthService.signInWithGoogle();
      final Tokens tokens =
          await authRepository.googleSignup(TokenDTO(token: at!));

      await tokens.write();
      emit(OTPVerificationSuccess());
    } on ApiError catch (err) {
      emit(RegisterError(error: err.message));
    } catch (err, sr) {
      print(sr);
      emit(const RegisterError(error: 'Unable to Register'));
    }
  }

  Future<void> _onGoogleLoginEvent(
      GoogleLoginEvent event, Emitter<AuthState> emit) async {
    try {
      emit(LoginLoading());
      var at = await GoogleAuthService.signInWithGoogle();
      final Tokens tokens =
          await authRepository.googleLogin(TokenDTO(token: at!));

      await tokens.write();
      emit(LoginSuccess());
    } on ApiError catch (err) {
      emit(LoginError(error: err.message));
    } catch (err, sr) {
      print(sr);
      emit(const LoginError(error: 'Unable to Login'));
    }
  }

  Future<void> _onResetPassword(
      ResetPasswordEvent event, Emitter<AuthState> emit) async {
    try {
      emit(ResetPasswordLoading());
      await authRepository.resetPassword(
          ResetPasswordDTO(email: event.email, password: event.password));

      emit(ResetPasswordSuccess());
    } on ApiError catch (err) {
      emit(ResetPasswordError(error: err.message));
    } catch (err, sr) {
      print(sr);
      emit(const ResetPasswordError(error: 'Unable to Reset Password'));
    }
  }

  Future<void> _onValidateResetPassword(
      ValidateResetPasswordEvent event, Emitter<AuthState> emit) async {
    try {
      emit(ValidateResetPasswordLoading());
      await authRepository.validateResetPassword(
          VerifyEmailDTO(email: event.email, otp: event.code));

      emit(ValidateResetPasswordSuccess());
    } on ApiError catch (err) {
      emit(ValidateResetPasswordError(error: err.message));
    } catch (err, sr) {
      print(sr);
      emit(const ValidateResetPasswordError(
          error: 'Unable to Validate Reset Password'));
    }
  }

  Future<void> _onResendForgotPasswordVerificationCode(
      ResendForgotPasswordVerificationCodeEvent event,
      Emitter<AuthState> emit) async {
    try {
      emit(ResendVerificationCodeLoading());
      await authRepository.resendVerificationCode(EmailDTO(email: event.email));

      emit(ResendVerificationCodeSuccess());
    } on ApiError catch (err) {
      emit(FindForgotPasswordAccountError(error: err.message));
    } catch (err, sr) {
      print(sr);
      emit(const FindForgotPasswordAccountError(
          error: 'Unable to Resend Verification Code'));
    }
  }

  Future<void> _onFindForgotPasswordAccount(
      FindForgotPasswordAccountEvent event, Emitter<AuthState> emit) async {
    try {
      emit(FindForgotPasswordAccountLoading());
      await authRepository
          .findForgotPasswordAccount(EmailDTO(email: event.email));

      emit(FindForgotPasswordAccountSuccess());
    } on ApiError catch (err) {
      emit(FindForgotPasswordAccountError(error: err.message));
    } catch (err, sr) {
      print(sr);
      emit(const FindForgotPasswordAccountError(
          error: 'Unable to Find Forgot Password Account'));
    }
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
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      var lang = prefs.getString("locale");
      await authRepository.register(RegisterDTO(
        email: event.email,
        password: event.password,
        language: lang ?? "es",
      ));

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
