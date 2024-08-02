import 'dart:convert';

import 'package:api_cache_manager/utils/cache_manager.dart';
import 'package:metric_repository/metric_repository.dart';

Future<List<PendingMeter>> getPendingMeters() async {
  var cacheManager = APICacheManager();
  var cacheKeysData = await cacheManager.getCacheData("API_pending_keys");

  if (cacheKeysData == null) {
    return [];
  }
  List<String> cacheKeys =
      List<String>.from(jsonDecode(cacheKeysData.syncData));
  List<PendingMeter> pendingMeters = [];
  for (var key in cacheKeys) {
    var cacheKey = await cacheManager.getCacheData(key);
    if (cacheKey != null) {
      Map<String, dynamic> data = jsonDecode(cacheKey.syncData);
      pendingMeters.add(PendingMeter.fromJson(data));
    }
  }
  return pendingMeters;
}
