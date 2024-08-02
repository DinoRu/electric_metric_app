import 'dart:async';
import 'dart:convert';

import 'package:api_cache_manager/api_cache_manager.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:metric_repository/metric_repository.dart';

part 'pending_event.dart';
part 'pending_state.dart';

class PendingBloc extends Bloc<PendingEvent, PendingState> {
  PendingBloc() : super(PendingLoading()) {
    on<FetchPendingMeterEvent>(_onFetchPendingMeters);
  }

  Future<void> _onFetchPendingMeters(
      FetchPendingMeterEvent event, Emitter<PendingState> emit) async {
    emit(PendingLoading());
    try {
      var cacheManager = APICacheManager();
      var cacheKeysData = await cacheManager.getCacheData("API_pending_keys");

      if (cacheKeysData == null) {
        emit(PendingEmpty());
        return;
      }

      List<String> cacheKeys =
          List<String>.from(jsonDecode(cacheKeysData.syncData));
      List<PendingMeter> pendingMeters = [];
      for (var key in cacheKeys) {
        var cacheData = await cacheManager.getCacheData(key);
        if (cacheData != null) {
          Map<String, dynamic> data = jsonDecode(cacheData.syncData);
          pendingMeters.add(PendingMeter.fromJson(data));
        }
      }
      if (pendingMeters.isEmpty) {
        emit(PendingEmpty());
      } else {
        emit(PendingLoaded(pendingMeters: pendingMeters));
      }
    } catch (e) {
      emit(const PendingError(error: "Catch error"));
    }
  }
}
