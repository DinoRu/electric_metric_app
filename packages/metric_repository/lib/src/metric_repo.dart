import 'models/model.dart';

abstract class MetricRepo {
  Future<List<Metric>> getAllMetric();

  Future<List<Meter>> getAllMeters();
}
