part of 'metric_bloc.dart';

sealed class MetricEvent extends Equatable {
  const MetricEvent();

  @override
  List<Object?> get props => [];
}

class FetchMetricEvent extends MetricEvent {
  final String token;
  const FetchMetricEvent({required this.token});

  @override
  List<Object?> get props => [token];
}

class FetchAllMetricEvent extends MetricEvent {}

class FetchMetricByUser extends MetricEvent {
  final User user;
  const FetchMetricByUser(this.user);

  @override
  List<Object?> get props => [user];
}

class RemoveMetric extends MetricEvent {
  final Metric metric;
  const RemoveMetric(this.metric);

  @override
  List<Object?> get props => [metric];
}

class GetCompleteMetricByUser extends MetricEvent {
  final User user;
  const GetCompleteMetricByUser(this.user);

  @override
  List<Object?> get props => [user];
}
