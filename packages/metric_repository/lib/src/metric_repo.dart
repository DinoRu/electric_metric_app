import 'models/model.dart';

abstract class MetricRepo {
  Future<List<Metric>> getAllMetric();

  Future<List<Meter>> getAllMeters();

  Future<List<PendingMeter>> getPendingMeters();

  Future<void> removePendingMeter(String meterId);
}
