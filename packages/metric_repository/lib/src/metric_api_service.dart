import 'dart:convert';
import 'dart:developer';

import 'package:metric_repository/src/metric_repo.dart';
import 'package:http/http.dart' as http;
import 'package:user_repository/user_repository.dart';

import 'models/model.dart';

class MetricRepository implements MetricRepo {
  @override
  Future<List<Metric>> getAllMetric() async {
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
        List<Metric> metrics =
            dataResults.map((e) => Metric.fromJson(e)).toList();
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
}
