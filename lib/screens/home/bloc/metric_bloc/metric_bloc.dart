import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:metric_repository/metric_repository.dart';
import 'package:user_repository/user_repository.dart';

part 'metric_event.dart';
part 'metric_state.dart';

class MetricBloc extends Bloc<MetricEvent, MetricState> {
  final MetricRepository metricRepository;
  List<Metric> metrics = [];
  MetricBloc(this.metricRepository) : super(MetricInitial()) {
    on<FetchAllMetricEvent>((event, emit) async {
      emit(MetricLoading());
      try {
        metrics = await metricRepository.getAllMetric();
        emit(GetAllMetrics(metrics));
      } catch (e) {
        emit(MetricError());
      }
    });

    on<FetchMetricByUser>((event, emit) async {
      emit(MetricLoading());
      try {
        metrics =
            await metricRepository.getMetricByDepartmentFromAll(event.user);
        emit(MetricLoaded(metrics: metrics));
      } catch (e) {
        log('Error fetching metrics: $e');
        emit(MetricError());
      }
    });

    on<RemoveMetric>((event, emit) async {
      final currentState = state;
      if (currentState is MetricLoaded) {
        final updatedMetrics =
            List.of((currentState.metrics)..remove(event.metric));
        emit(MetricLoaded(metrics: updatedMetrics));
        metrics = updatedMetrics;
      }
    });
  }

  List<Metric> getMetrics() {
    return metrics;
  }
}
