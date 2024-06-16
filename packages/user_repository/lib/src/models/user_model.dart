
import 'dart:convert';

User userFromJson(String str) => User.fromJson(json.decode(str));

String userToJson(User data) => json.encode(data.toJson());

class User {
  final String userId;
  final String username;
  final String firstName;
  final String lastName;
  final String middleName;
  final String role;
  final String department;
  final String? token;

  User({
    required this.userId,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.middleName,
    required this.role,
    required this.department,
    this.token
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    userId: json["user_id"],
    username: json["username"],
    firstName: json["first_name"],
    lastName: json["last_name"],
    middleName: json["middle_name"],
    role: json["role"],
    department: json["department"],
    token: json['token']
  );

  User copyWith({
    String? userId,
    String? username,
    String? firstName,
    String? lastName,
    String? middleName,
    String? role,
    String? department,
    String? token
  }) =>
      User(
        userId: userId ?? this.userId,
        username: username ?? this.username,
        firstName: firstName ?? this.firstName,
        lastName: lastName ?? this.lastName,
        middleName: middleName ?? this.middleName,
        role: role ?? this.role,
        department: department ?? this.department,
        token: token ?? this.token
      );

  Map<String, dynamic> toJson() => {
    "user_id": userId,
    "username": username,
    "first_name": firstName,
    "last_name": lastName,
    "middle_name": middleName,
    "role": role,
    "department": department,
    "token": token
  };
}
