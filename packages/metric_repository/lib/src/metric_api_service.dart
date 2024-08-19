import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:metric_repository/features/database.dart';
import 'package:metric_repository/src/metric_repo.dart';
import 'package:http/http.dart' as http;
import 'package:user_repository/user_repository.dart';
import 'package:sqflite/sqflite.dart';

import 'models/model.dart';

class MetricRepository implements MetricRepo {
  @override
  Future<List<Metric>> getAllMetric() async {
    final DatabaseHelper databaseHelper = DatabaseHelper();
    final db = await databaseHelper.database;
    // get local metric
    final List<Map<String, dynamic>> data = await db
        .query('meters', where: 'status = ?', whereArgs: ['Выполняется']);
    if (data.isNotEmpty) {
      log("CACHE : HIT");
      List<Metric> metrics = data
          .map((e) => Metric(
              taskId: e['taskId'],
              code: e['code'],
              name: e['name'],
              number: e['number'],
              address: e['address'],
              previousIndication: e['previousIndication'],
              comment: e['comment'],
              status: e['status']))
          .toList();
      return metrics;
    }
    try {
      const url = "http://45.84.226.183:5000/tasks";

      final response = await http.get(Uri.parse(url),
          headers: {'Content-Type': 'application/json; charset=utf-8'});
      if (response.statusCode == 200) {
        Utf8Decoder decoder = const Utf8Decoder();
        String decoderBody = decoder.convert(response.bodyBytes);
        final result = jsonDecode(decoderBody)['result'];
        List<Map<String, dynamic>> dataResults =
            List<Map<String, dynamic>>.from(result['data']);
        // Store data in the local database
        List<Metric> metrics =
            dataResults.map((e) => Metric.fromJson(e)).toList();
        await db.transaction((txn) async {
          for (var metric in metrics) {
            await txn.insert(
                'meters',
                {
                  "taskId": metric.taskId,
                  "code": metric.code,
                  "name": metric.name,
                  "number": metric.number,
                  "address": metric.address,
                  "previousIndication": metric.previousIndication,
                  "currentIndication": metric.currentIndication,
                  "comment": metric.comment,
                  "status": metric.status
                },
                conflictAlgorithm: ConflictAlgorithm.replace);
          }
        });
        log("API : HIT");
        return metrics;
      }
    } catch (e) {
      log(e.toString());
    }
    return [];
  }

  Future<List<Metric>> getMetricByDepartmentFromAll(User user) async {
    try {
      List<Metric> allMetrics = await getAllMetric();
      List<Metric> filteredMetrics = allMetrics
          .where((metric) => metric.code!.contains(user.department))
          .toList();
      return filteredMetrics;
    } catch (e) {
      throw Exception("Error to failed");
    }
  }

  Future<List<Metric>> searchMetrics(User user) async {
    try {
      List<Metric> searchMetrics = await getMetricByDepartmentFromAll(user);
      return searchMetrics;
    } catch (e) {
      throw Exception('Error to failed!');
    }
  }

  @override
  Future<List<Meter>> getAllMeters() async {
    try {
      const url =
          "http://45.84.226.183:5000/tasks/?&order=ASC&condition=Проверяется";
      final response = await http.get(Uri.parse(url),
          headers: {'Content-Type': 'application/json; charset=utf-8'});
      if (response.statusCode == 200) {
        Utf8Decoder decoder = const Utf8Decoder();
        String decoderBody = decoder.convert(response.bodyBytes);
        final result = jsonDecode(decoderBody)['result'];
        List<Map<String, dynamic>> dataResults =
            List<Map<String, dynamic>>.from(result['data']);
        List<Meter> meters = dataResults.map((e) => Meter.fromJson(e)).toList();
        return meters;
      }
    } catch (e) {
      log(e.toString());
    }
    return [];
  }

  Future<List<Meter>> getMeterByUser(User user) async {
    try {
      List<Meter> allMeters = await getAllMeters();
      List<Meter> filteredMeters = allMeters
          .where((meter) => meter.code!.contains(user.department))
          .toList();
      return filteredMeters;
    } catch (e) {
      throw Exception("Error to failed");
    }
  }

  Future<List<Meter>> searchMeters(User user) async {
    try {
      final List<Meter> searchMeters = await getMeterByUser(user);
      return searchMeters;
    } catch (e) {
      throw ("Error to failed");
    }
  }
}
