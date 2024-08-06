import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static const _databaseName = "meter.db";
  static const _databaseVersion = 1;

  static Database? _database;

  //DATABASE TABLE NAME
  final String table = 'meters';

  //Colonnes de la table;
  final String columnId = 'id';
  final String columnKey = 'key';
  final String columnData = 'data';

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
}
