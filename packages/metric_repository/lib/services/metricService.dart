import 'dart:async';
import 'package:metric_repository/features/database.dart';

class Metricservice {
  final DatabaseHelper databaseHelper = DatabaseHelper();

  final _metricStreamController =
      StreamController<List<Map<String, dynamic>>>.broadcast();
  Stream<List<Map<String, dynamic>>> get metricStream =>
      _metricStreamController.stream;

  Future<List<Map<String, dynamic>>> getLocalMetric() async {
    try {
      final db = await databaseHelper.database;
      final data = await db
          .query('meters', where: 'status = ?', whereArgs: ['Проверяется']);
      return data;
    } on Exception catch (e) {
      throw Exception(e);
    }
  }
}
