import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:electric_meter_app/screens/home/bloc/sync_bloc/sync_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:metric_repository/metric_repository.dart';

part 'data_list_event.dart';
part 'data_list_state.dart';

class DataListBloc extends Bloc<DataListEvent, DataListState> {
  final DatabaseHelper databaseHelper = DatabaseHelper();
  List<Metric> metrics = [];
  final SyncBloc syncBloc = SyncBloc();
  DataListBloc() : super(DataListInitial()) {
    on<DataListEvent>((event, emit) async {
      emit(DataListLoading());
      try {
        metrics = await databaseHelper.getPendingMeters();
        emit(DataListLoaded(metrics));
      } catch (e) {
        emit(DataListError());
        throw Exception(e);
      }
    });
    on<UplaodAllMetricsEvent>(_uploadAllMetrics);
  }

  FutureOr<void> _uploadAllMetrics(
      UplaodAllMetricsEvent event, Emitter<DataListState> emit) async {
    emit(DataListLoading());
    try {
      List<Metric> metrics = await databaseHelper.getPendingMeters();
      for (Metric metric in metrics) {
        syncBloc.add(SendDataEvent(metric));
        await Future.delayed(const Duration(seconds: 2));
      }
      emit(DataListLoaded(metrics));
    } catch (e) {
      log("Failed to send all metrics to server");
      emit(DataListError());
    }
  }

  List<Metric> getPendingMetrics() {
    return metrics;
  }
}
