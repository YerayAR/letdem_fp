part of 'auth_bloc.dart';

sealed class AuthState extends Equatable {
  const AuthState();
}

final class AuthInitial extends AuthState {
  @override
  List<Object> get props => [];
}

final class ResendVerificationCodeLoading extends AuthState {
  @override
  List<Object?> get props => [];
}

final class ResendVerificationCodeSuccess extends AuthState {
  @override
  List<Object?> get props => [];
}

final class ResendVerificationCodeError extends AuthState {
  final String error;

  const ResendVerificationCodeError({required this.error});

  @override
  List<Object?> get props => [error];
}

final class LoginLoading extends AuthState {
  @override
  // TODO: implement props
  List<Object?> get props => [];
}

final class LoginSuccess extends AuthState {
  @override
  // TODO: implement props
  List<Object?> get props => [];
}

final class LoginError extends AuthState {
  final String error;

  const LoginError({required this.error});

  @override
  // TODO: implement props
  List<Object?> get props => [];
}

final class FindForgotPasswordAccountLoading extends AuthState {
  @override
  List<Object?> get props => [];
}

final class FindForgotPasswordAccountSuccess extends AuthState {
  @override
  List<Object?> get props => [];
}

final class FindForgotPasswordAccountError extends AuthState {
  final String error;

  const FindForgotPasswordAccountError({required this.error});

  @override
  List<Object?> get props => [error];
}

class ValidateResetPasswordLoading extends AuthState {
  @override
  List<Object?> get props => [];
}

class ValidateResetPasswordSuccess extends AuthState {
  @override
  List<Object?> get props => [];
}

class ValidateResetPasswordError extends AuthState {
  final String error;

  const ValidateResetPasswordError({required this.error});

  @override
  List<Object?> get props => [error];
}

final class ResetPasswordLoading extends AuthState {
  @override
  List<Object?> get props => [];
}

final class ResetPasswordSuccess extends AuthState {
  @override
  List<Object?> get props => [];
}

final class ResetPasswordError extends AuthState {
  final String error;

  const ResetPasswordError({required this.error});

  @override
  List<Object?> get props => [error];
}

final class RegisterLoading extends AuthState {
  @override
  List<Object?> get props => [];
}

final class RegisterSuccess extends AuthState {
  @override
  List<Object?> get props => [];
}

final class RegisterError extends AuthState {
  final String error;

  const RegisterError({required this.error});

  @override
  List<Object?> get props => [error];
}

final class OTPVerificationLoading extends AuthState {
  @override
  List<Object?> get props => [];
}

final class OTPVerificationSuccess extends AuthState {
  final bool isGoogleLogin;

  const OTPVerificationSuccess({required this.isGoogleLogin});
  @override
  List<Object?> get props => [isGoogleLogin];
}

final class PersonalInfoLoading extends AuthState {
  @override
  List<Object?> get props => [];
}

final class PersonalInfoSuccess extends AuthState {
  @override
  List<Object?> get props => [];
}
