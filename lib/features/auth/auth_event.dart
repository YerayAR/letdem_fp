part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();
}

class LoginEvent extends AuthEvent {
  final String email;
  final String password;

  const LoginEvent({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class RegisterEvent extends AuthEvent {
  final String email;
  final String password;

  const RegisterEvent({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class VerifyEmailEvent extends AuthEvent {
  final String email;
  final String code;

  const VerifyEmailEvent({required this.email, required this.code});

  @override
  List<Object?> get props => [email, code];
}

class ResendVerificationCodeEvent extends AuthEvent {
  final String email;

  const ResendVerificationCodeEvent({required this.email});

  @override
  List<Object?> get props => [email];
}

class UpdatePersonalInfoEvent extends AuthEvent {
  final String name;
  final String phone;
  final String address;

  const UpdatePersonalInfoEvent(
      {required this.name, required this.phone, required this.address});

  @override
  List<Object?> get props => [name, phone, address];
}
