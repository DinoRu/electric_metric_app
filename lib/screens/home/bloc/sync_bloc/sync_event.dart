part of 'sync_bloc.dart';

sealed class SyncEvent extends Equatable {
  const SyncEvent();

  @override
  List<Object> get props => [];
}

class SendDataEvent extends SyncEvent {
  final Metric metric;
  const SendDataEvent(this.metric);

  @override
  List<Object> get props => [metric];
}

class SyncAllMetricsEvent extends SyncEvent {}
