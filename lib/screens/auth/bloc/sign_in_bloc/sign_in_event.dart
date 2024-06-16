part of 'sign_in_bloc.dart';

sealed class SignInEvent extends Equatable {
  const SignInEvent();

  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class SignInRequired extends SignInEvent {
  final String username;
  final String password;

  const SignInRequired(this.username, this.password);
}

class SignOutRequired extends SignInEvent {}
