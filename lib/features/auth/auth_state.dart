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
