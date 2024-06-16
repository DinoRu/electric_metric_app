import 'dart:convert';
import 'dart:developer';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:user_repository/src/models/user_model.dart';
import 'package:user_repository/src/user_repos.dart';
import 'package:http/http.dart' as http;

class ApiUserRepository implements UserRepos {
  static jwtDecodeToken(String token) {
    Map<String, dynamic> payload = JwtDecoder.decode(token);
    return payload['user_id'];
  }

  Future<User> getUserByID(String userId) async {
    final url = "http://45.84.226.183:5000/users/$userId";
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      Utf8Decoder decoder = const Utf8Decoder();
      String decoderBody = decoder.convert(response.bodyBytes);
      final result = jsonDecode(decoderBody)['result'];
      User user = User.fromJson(result);
      return user;
    } else {
      throw Exception("Failed to load user");
    }
  }

  @override
  Future<User> login(String username, String password) async {
    try {
      const url = 'http://45.84.226.183:5000/users/login';
      Map<String, dynamic> data = {'username': username, 'password': password};

      final response = await http.post(Uri.parse(url),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(data));
      if (response.statusCode == 200) {
        final token = jsonDecode(response.body);
        final userId = jwtDecodeToken(token);
        final user = await getUserByID(userId);
        return user.copyWith(token: token);
      } else {
        throw Exception('Failed to login');
      }
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<void> logout() async {}
}
