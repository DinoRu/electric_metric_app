import 'package:metric_repository/metric_repository.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static const _databaseName = "meter.db";
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
        CREATE TABLE $table (
          id integer primary key autoincrement,
          taskId TEXT,
          code TEXT,
          name TEXT,
          address TEXT,
          number TEXT,
          previousIndication REAL,
          currentIndication REAL,
          farPhotoUrl TEXT,
          nearPhotoUrl TEXT,
          comment TEXT,
          status TEXT
        );
     ''');
  }

  Future<List<Map<String, dynamic>>> getMetersByStatus(String status) async {
    final db = await database;
    return db.query('meters', where: 'status = ?', whereArgs: [status]);
  }

  Future<int> deleteMeter(String id) async {
    final db = await database;
    return db.delete('meters', where: "taskId = ?", whereArgs: [id]);
  }

  Future<List<Metric>> getPendingMeters() async {
    List<Map<String, dynamic>> data = await getMetersByStatus("Проверяется");
    List<Metric> metrics = data
        .map((e) => Metric(
              taskId: e["taskId"],
              code: e["code"],
              name: e["name"],
              address: e["address"],
              number: e["number"],
              previousIndication: e["previousIndication"],
              currentIndication: e["currentIndication"],
              nearPhotoUrl: e["nearPhotoUrl"],
              farPhotoUrl: e["farPhotoUrl"],
              comment: e["comment"],
              status: e["status"],
            ))
        .toList();
    return metrics;
  }

  Future<void> saveUserSession(String userId, String token) async {
    final db = await database;
    await db.insert(
        'users',
        {
          "userId": userId,
          "token": token,
        },
        conflictAlgorithm: ConflictAlgorithm.replace);
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
