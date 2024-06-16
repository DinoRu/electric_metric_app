part of 'metric_bloc.dart';

sealed class MetricState extends Equatable {
  const MetricState();

  @override
  List<Object> get props => [];
}

final class MetricInitial extends MetricState {}

class MetricLoading extends MetricState {}

class MetricLoaded extends MetricState {
  final List<Metric> metrics;
  final int totalMetrics;
  const MetricLoaded({required this.metrics}) : totalMetrics = metrics.length;

  @override
  List<Object> get props => [metrics];
}

class GetAllMetrics extends MetricState {
  final List<Metric> metrics;
  const GetAllMetrics(this.metrics);

  @override
  List<Object> get props => [metrics];
}

class MetricError extends MetricState {}

// ignore: must_be_immutable
class GetAllMeters extends MetricState {
  List<Meter> meters;
  final int totalMetrics;
  GetAllMeters(this.meters) : totalMetrics = meters.length;

  @override
  List<Object> get props => [meters];
}
