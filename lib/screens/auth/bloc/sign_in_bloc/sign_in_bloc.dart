import 'dart:convert';
import 'dart:developer';

import 'package:api_cache_manager/api_cache_manager.dart';
import 'package:api_cache_manager/models/cache_db_model.dart';
import 'package:bloc/bloc.dart';
import 'package:electric_meter_app/blocs/auth_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:user_repository/user_repository.dart';

part 'sign_in_event.dart';
part 'sign_in_state.dart';

class SignInBloc extends Bloc<SignInEvent, SignInState> {
  final ApiUserRepository _userRepository;
  final AuthBloc _authBLoc;

  SignInBloc(this._userRepository, this._authBLoc) : super(SignInInitial()) {
    on<SignInRequired>((event, emit) async {
      emit(SignInProcess());
      var isCached = await APICacheManager().isAPICacheKeyExist('user');
      if (!isCached) {
        try {
          final user =
              await _userRepository.login(event.username, event.password);
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isLoggedIn', true);
          await prefs.setString('userId', user.userId);
          await APICacheManager().addCacheData(
              APICacheDBModel(key: "user", syncData: user.toJson().toString()));
          _authBLoc.add(AuthenticationUserChanged(user));
          log('Cache user ${user.userId}');
          emit(SignInSuccess(user));
        } catch (e) {
          emit(SignInFailure());
        }
      } else {
        log("User with cache");
        var cacheData = await APICacheManager().getCacheData("user");
        final user = userFromJson(cacheData.syncData);
        _authBLoc.add(AuthenticationUserChanged(user));
        emit(SignInSuccess(user));
      }
    });

    on<SignOutRequired>((event, emit) async {
      await _userRepository.logout();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('userId');
      await prefs.setBool('isLoggedIn', false);
      await APICacheManager().deleteCache('user');
      log("Delete cache user");
      _authBLoc.add(const AuthenticationUserChanged(null));
    });
  }
}
