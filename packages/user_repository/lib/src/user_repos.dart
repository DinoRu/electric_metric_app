import 'models/model.dart';

abstract class UserRepos {

  Future<User> login(String username, String password);

  Future<void> logout();
}