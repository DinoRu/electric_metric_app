import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:api_cache_manager/models/cache_db_model.dart';
import 'package:api_cache_manager/utils/cache_manager.dart';
import 'package:archive/archive_io.dart';
import 'package:metric_repository/src/metric_repo.dart';
import 'package:http/http.dart' as http;
import 'package:metric_repository/src/models/pending_model.dart';
import 'package:user_repository/user_repository.dart';

import 'models/model.dart';

class MetricRepository implements MetricRepo {
  @override
  Future<List<Metric>> getAllMetric() async {
    var isCacheExits =
        await APICacheManager().isAPICacheKeyExist("API_metrics");
    if (!isCacheExits) {
      try {
        const url = "http://45.84.226.183:5000/tasks";
        final response = await http.get(Uri.parse(url),
            headers: {'Content-Type': 'application/json; charset=utf-8'});
        print("URL : HIT");
        if (response.statusCode == 200) {
          Utf8Decoder decoder = const Utf8Decoder();
          String decoderBody = decoder.convert(response.bodyBytes);
          final result = jsonDecode(decoderBody)['result'];
          List<Map<String, dynamic>> dataResults =
              List<Map<String, dynamic>>.from(result['data']);
          List<Metric> metrics =
              dataResults.map((e) => Metric.fromJson(e)).toList();

          // Storing the data in the cache
          // Compression des données avant stockage
          var encodedData = jsonEncode(dataResults);
          var compressedData = GZipEncoder()
              .encode(Uint8List.fromList(utf8.encode(encodedData)));

          // Storing the compressed data in cache
          await APICacheManager().addCacheData(APICacheDBModel(
            key: "API_metrics",
            syncData: base64Encode(compressedData!),
          ));
          return metrics;
        }
      } catch (e) {
        log(e.toString());
      }
    } else {
      var cacheData = await APICacheManager().getCacheData("API_metrics");
      var compressedData = base64Decode(cacheData.syncData);
      var decodedData = utf8.decode(GZipDecoder().decodeBytes(compressedData));
      List<Map<String, dynamic>> dataResults =
          List<Map<String, dynamic>>.from(jsonDecode(decodedData));
      List<Metric> metrics =
          dataResults.map((e) => Metric.fromJson(e)).toList();
      print("CACHE : HIT");
      return metrics;
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
    var isCachedExits =
        await APICacheManager().isAPICacheKeyExist("API_metrics_completed");
    if (!isCachedExits) {
      try {
        const url =
            "http://45.84.226.183:5000/tasks/?&order=ASC&condition=Проверяется";
        final response = await http.get(Uri.parse(url),
            headers: {'Content-Type': 'application/json; charset=utf-8'});
        print("URL : HIT");
        if (response.statusCode == 200) {
          Utf8Decoder decoder = const Utf8Decoder();
          String decoderBody = decoder.convert(response.bodyBytes);
          final result = jsonDecode(decoderBody)['result'];
          List<Map<String, dynamic>> dataResults =
              List<Map<String, dynamic>>.from(result['data']);
          List<Meter> meters =
              dataResults.map((e) => Meter.fromJson(e)).toList();
          // Storing the data in the cache
          // Compression des données avant stockage
          var encodedData = jsonEncode(dataResults);
          var compressedData = GZipEncoder()
              .encode(Uint8List.fromList(utf8.encode(encodedData)));
          // Storing the compressed data in cache
          await APICacheManager().addCacheData(APICacheDBModel(
            key: "API_metrics_completed",
            syncData: base64Encode(compressedData!),
          ));
          return meters;
        }
      } catch (e) {
        log(e.toString());
      }
    } else {
      var cacheData =
          await APICacheManager().getCacheData("API_metrics_completed");
      var compressedData = base64Decode(cacheData.syncData);
      var decodedData = utf8.decode(GZipDecoder().decodeBytes(compressedData));
      List<Map<String, dynamic>> dataResults =
          List<Map<String, dynamic>>.from(jsonDecode(decodedData));
      List<Meter> meters = dataResults.map((e) => Meter.fromJson(e)).toList();
      print("CACHE : HIT");
      return meters;
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

  Future<List<PendingMeter>> getPendingMeters() async {
    var cacheManager = APICacheManager();
    var cacheData = await cacheManager.getAllCacheData();
  }
}
