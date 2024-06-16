part of 'auth_bloc.dart';

enum AuthenticationStatus { unknown, authenticated, unauthenticated }

class AuthState extends Equatable {
  const AuthState._({this.status = AuthenticationStatus.unknown, this.user});

  final AuthenticationStatus status;
  final User? user;

  //Unknown
  const AuthState.unknown() : this._();

  //Authenticated
  const AuthState.authenticated(User myUser)
      : this._(status: AuthenticationStatus.authenticated, user: myUser);

  //unauthenticated
  const AuthState.unauthenticated()
      : this._(status: AuthenticationStatus.unauthenticated);

  @override
  List<Object?> get props => [status];
}
