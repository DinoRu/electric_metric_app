import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:user_repository/user_repository.dart';

class UserDatabaseHelper {
  static const _databaseName = "user.db";
  static const _databaseVersion = 1;

  static Database? _database;

  //DATABASE TABLE NAME
  final String table = 'meters';
  final String userTable = 'users';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, _databaseName);
    return openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _createTables,
    );
  }

  Future<void> _createTables(Database db, int version) async {
    await db.execute('''
        CREATE TABLE $userTable (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          userId TEXT NOT NULL,
          firstName TEXT NOT NULL,
          lastName TEXT NOT NULL,
          middleName TEXT NOT NULL,
          role TEXT NOT NULL,
          department TEXT NOT NULL
        );
     ''');
  }

  Future<User?> getUserById(String userId) async {
    final db = await database;
    List<Map<String, dynamic>> data =
        await db.query('users', where: 'userId = ?', whereArgs: [userId]);
    if (data.isNotEmpty) {
      Map<String, dynamic> userData = data.first;
      final User user = User(
        userId: userData['userId'],
        username: userData['username'],
        firstName: userData['firstName'],
        lastName: userData['lastName'],
        middleName: userData['middleName'],
        role: userData['role'],
        department: userData['department'],
      );
      return user;
    } else {
      return null;
    }
  }

  Future<void> saveUserSession(User user) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.insert(
          'users',
          {
            "userId": user.userId,
            "firstName": user.firstName,
            "middleName": user.middleName,
            "lastName": user.lastName,
            "role": user.role,
            "department": user.department,
          },
          conflictAlgorithm: ConflictAlgorithm.replace);
    });
  }

  Future<Map<String, String?>> getUserSession() async {
    final db = await database;
    List<Map<String, dynamic>> data = await db.query('users');
    if (data.isNotEmpty) {
      final session = data.first;
      return {"userId": session["userId"], "token": session["token"]};
    }
    return {};
  }

  Future<void> clearSession() async {
    final db = await database;
    await db.delete('users');
  }
}
