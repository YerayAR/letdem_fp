import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:letdem/core/extensions/locale.dart';
import 'package:letdem/features/auth/dto/email.dto.dart';
import 'package:letdem/features/auth/dto/login.dto.dart';
import 'package:letdem/features/auth/dto/password_reset.dto.dart';
import 'package:letdem/features/auth/dto/register.dto.dart';
import 'package:letdem/features/auth/dto/token.dto.dart';
import 'package:letdem/features/auth/dto/verify_email.dto.dart';
import 'package:letdem/features/auth/models/tokens.model.dart';
import 'package:letdem/features/auth/repositories/auth.repository.dart';
import 'package:letdem/infrastructure/api/api/models/error.dart';
import 'package:letdem/infrastructure/services/google/google.service.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../infrastructure/services/res/navigator.dart';

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
      _onResendForgotPasswordVerificationCode,
    );
    on<ValidateResetPasswordEvent>(_onValidateResetPassword);
    on<ResetPasswordEvent>(_onResetPassword);
    on<GoogleLoginEvent>(_onGoogleLoginEvent);
    on<GoogleRegisterEvent>(_onGoogleRegisterEvent);
  }

  Future<void> _onGoogleRegisterEvent(
    GoogleRegisterEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(RegisterLoading());
      await OneSignal.Notifications.requestPermission(true);

      var at = await GoogleAuthService.signInWithGoogle();

      print("OneSignal User ID: ${OneSignal.User.pushSubscription.id}");
      print(OneSignal.User.pushSubscription.id);

      final Tokens tokens = await authRepository.googleSignup(
        TokenDTO(token: at!),
      );

      await tokens.write();
      emit(OTPVerificationSuccess(isGoogleLogin: true));
    } on ApiError catch (err) {
      emit(RegisterError(error: err.message));
    } catch (err, sr) {
      print(sr);
      emit(
        RegisterError(error: NavigatorHelper.context!.l10n.somethingWentWrong),
      );
    }
  }

  Future<void> _onGoogleLoginEvent(
    GoogleLoginEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(LoginLoading());
      await OneSignal.Notifications.requestPermission(true);

      print("OneSignal User ID: ${OneSignal.User.pushSubscription.id}");
      print(OneSignal.User.pushSubscription.id);

      var at = await GoogleAuthService.signInWithGoogle();
      final Tokens tokens = await authRepository.googleLogin(
        TokenDTO(token: at!),
      );

      await tokens.write();
      emit(LoginSuccess());
    } on ApiError catch (err) {
      emit(LoginError(error: err.message));
    } catch (err, sr) {
      print(sr);
      emit(LoginError(error: NavigatorHelper.context!.l10n.somethingWentWrong));
    }
  }

  Future<void> _onResetPassword(
    ResetPasswordEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(ResetPasswordLoading());
      await authRepository.resetPassword(
        ResetPasswordDTO(email: event.email, password: event.password),
      );

      emit(ResetPasswordSuccess());
    } on ApiError catch (err) {
      emit(ResetPasswordError(error: err.message));
    } catch (err, sr) {
      print(sr);
      emit(
        ResetPasswordError(
          error: NavigatorHelper.context!.l10n.unableToResetPassword,
        ),
      );
    }
  }

  Future<void> _onValidateResetPassword(
    ValidateResetPasswordEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(ValidateResetPasswordLoading());
      await authRepository.validateResetPassword(
        VerifyEmailDTO(email: event.email, otp: event.code),
      );

      emit(ValidateResetPasswordSuccess());
    } on ApiError catch (err) {
      emit(ValidateResetPasswordError(error: err.message));
    } catch (err, sr) {
      print(sr);
      emit(
        ValidateResetPasswordError(
          error: NavigatorHelper.context!.l10n.unableToResetPassword,
        ),
      );
    }
  }

  Future<void> _onResendForgotPasswordVerificationCode(
    ResendForgotPasswordVerificationCodeEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(ResendVerificationCodeLoading());
      await authRepository.resendVerificationCodeForgotPassword(
        EmailDTO(email: event.email),
      );

      emit(ResendVerificationCodeSuccess());
    } on ApiError catch (err) {
      emit(FindForgotPasswordAccountError(error: err.message));
    } catch (err, sr) {
      print(sr);
      emit(
        FindForgotPasswordAccountError(
          error: NavigatorHelper.context!.l10n.unableToResendCode,
        ),
      );
    }
  }

  Future<void> _onFindForgotPasswordAccount(
    FindForgotPasswordAccountEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(FindForgotPasswordAccountLoading());
      await authRepository.findForgotPasswordAccount(
        EmailDTO(email: event.email),
      );

      emit(FindForgotPasswordAccountSuccess());
    } on ApiError catch (err) {
      emit(FindForgotPasswordAccountError(error: err.message));
    } catch (err, sr) {
      print(sr);
      emit(
        FindForgotPasswordAccountError(
          error: NavigatorHelper.context!.l10n.unableToFindAccount,
        ),
      );
    }
  }

  Future<void> _onResendVerificationCode(
    ResendVerificationCodeEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(ResendVerificationCodeLoading());
      await authRepository.resendVerificationCode(EmailDTO(email: event.email));

      emit(ResendVerificationCodeSuccess());
    } on ApiError catch (err) {
      emit(RegisterError(error: err.message));
    } catch (err, sr) {
      print(sr);
      emit(
        RegisterError(error: NavigatorHelper.context!.l10n.unableToResendCode),
      );
    }
  }

  Future<void> _onVerifyEmail(
    VerifyEmailEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(OTPVerificationLoading());
      Tokens tokens = await authRepository.verifyEmailEvent(
        VerifyEmailDTO(email: event.email, otp: event.code),
      );

      await tokens.write();

      emit(OTPVerificationSuccess(isGoogleLogin: false));
    } on ApiError catch (err) {
      emit(RegisterError(error: err.message));
    } catch (err, sr) {
      print(sr);
      // emit(const RegisterError(error: 'Unable to Verify Email'));
      emit(
        RegisterError(error: NavigatorHelper.context!.l10n.unableToVerifyEmail),
      );
    }
  }

  Future<void> _onRegisterUserEvent(
    RegisterEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(RegisterLoading());
      await OneSignal.Notifications.requestPermission(true);

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      var lang = prefs.getString("locale");
      await authRepository.register(
        RegisterDTO(
          email: event.email,
          password: event.password,
          language: lang ?? "es",
        ),
      );

      emit(RegisterSuccess());
    } on ApiError catch (err) {
      emit(RegisterError(error: err.message));
    } catch (err, sr) {
      print(sr);
      // emit(const RegisterError(error: 'Unable to Register'));
      emit(
        RegisterError(error: NavigatorHelper.context!.l10n.unableToRegister),
      );
    }
  }

  Future<void> _onLoginUserEvent(
    LoginEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(LoginLoading());
      final Tokens tokens = await authRepository.login(
        LoginDTO(email: event.email, password: event.password),
      );

      await tokens.write();
      emit(LoginSuccess());
    } on ApiError catch (err) {
      emit(LoginError(error: err.message));
    } catch (err, sr) {
      print(sr);
      // emit(const LoginError(error: 'Unable to Login'));
      emit(LoginError(error: NavigatorHelper.context!.l10n.unableToLogin));
    }
  }
}
