part of 'auth_bloc.dart';

sealed class AuthState extends Equatable {
  const AuthState();
}

final class AuthInitial extends AuthState {
  @override
  List<Object> get props => [];
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
  @override
  List<Object?> get props => [];
}

final class PersonalInfoLoading extends AuthState {
  @override
  List<Object?> get props => [];
}

final class PersonalInfoSuccess extends AuthState {
  @override
  List<Object?> get props => [];
}
