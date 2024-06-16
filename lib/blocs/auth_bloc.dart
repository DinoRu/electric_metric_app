import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:user_repository/user_repository.dart';
// import 'package:shared_preferences/shared_preferences.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final ApiUserRepository userRepository;
  String? _token;
  AuthBloc({required this.userRepository}) : super(const AuthState.unknown()) {
    on<AuthenticationUserChanged>(_onAuthenticationUserChanged);
    on<AuthLogoutRequested>(_onLogoutRequested);
    _checkAuthentication();
  }

  void _onAuthenticationUserChanged(
      AuthenticationUserChanged event, Emitter<AuthState> emit) {
    if (event.user != null) {
      emit(AuthState.authenticated(event.user!));
      _token = event.user!.token;
    } else {
      emit(const AuthState.unauthenticated());
    }
  }

  void _onLogoutRequested(
      AuthLogoutRequested event, Emitter<AuthState> emit) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('userId');
      await prefs.setBool('isLoggedIn', false);
      await userRepository.logout();
      emit(const AuthState.unauthenticated());
    } catch (e) {
      log(e.toString());
    }
  }

  Future<void> _checkAuthentication() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    if (isLoggedIn) {
      final userId = prefs.getString('userId');
      if (userId != null) {
        try {
          final user = await userRepository.getUserByID(userId);
          add(AuthenticationUserChanged(user));
        } catch (e) {
          log(e.toString());
          add(const AuthenticationUserChanged(null));
        }
      } else {
        add(const AuthenticationUserChanged(null));
      }
    } else {
      add(const AuthenticationUserChanged(null));
    }
  }
}
