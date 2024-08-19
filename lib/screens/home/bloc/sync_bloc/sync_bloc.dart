import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:equatable/equatable.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:metric_repository/metric_repository.dart';

part 'sync_event.dart';
part 'sync_state.dart';

class SyncBloc extends Bloc<SyncEvent, SyncState> {
  final DatabaseHelper databaseHelper = DatabaseHelper();
  SyncBloc() : super(SyncInitial()) {
    on<SendDataEvent>(_syncData);
    on<SyncAllMetricsEvent>(_syncAllMetrics);
  }

  FutureOr<void> _syncData(SendDataEvent event, Emitter<SyncState> emit) async {
    emit(SyncLoading());
    try {
      final result = await Connectivity().checkConnectivity();
      if (result.contains(ConnectivityResult.none)) {
        emit(const SyncError("Интернет не доступны"));
      } else if (result.contains(ConnectivityResult.mobile) ||
          result.contains(ConnectivityResult.wifi)) {
        await _updateDataAndSendToApi(event);
        await databaseHelper.deleteMeter("${event.metric.taskId}");
        emit(SyncSuccess());
      } else {
        emit(const SyncError('Нет обходов'));
      }
    } catch (e) {
      log("Failed to sync Data");
      emit(const SyncError("Error to send to backend"));
    }
  }

  FutureOr<void> _syncAllMetrics(
      SyncAllMetricsEvent event, Emitter<SyncState> emit) async {
    emit(SyncLoading());
    try {
      List<Metric> metrics = await databaseHelper.getPendingMeters();
      if (metrics.isNotEmpty) {
        for (Metric metric in metrics) {
          _updateDataAndSendToApi(SendDataEvent(metric));
          await databaseHelper.deleteMeter("${metric.taskId}");
          Future.delayed(const Duration(seconds: 2));
        }
        emit(SyncSuccess());
      } else {
        emit(const SyncError("Нет обходов"));
        log('Pas de compteurs disponibles');
      }
    } catch (e) {
      log("Failed to upload all metrics to server");
      emit(SyncError(e.toString()));
    }
  }

  Future<void> _updateDataAndSendToApi(SendDataEvent event) async {
    log("Data send to API");
    String meterImageName =
        '${event.metric.number}_${DateTime.now().microsecondsSinceEpoch}.jpg';
    String meterDownloadUrl = await _uploadImageToStorage(
        File('${event.metric.nearPhotoUrl}'),
        "metrics/${event.metric.number}/$meterImageName");

    //Upload metric image to firebase storage
    String metricImageName =
        '${event.metric.number}_${DateTime.now().microsecondsSinceEpoch}_1.jpg';
    String metricDownloadUrl = await _uploadImageToStorage(
        File("${event.metric.farPhotoUrl}"),
        "metrics/${event.metric.number}/$metricImageName");

    Map<String, dynamic> data = {
      "near_photo_url": metricDownloadUrl,
      "far_photo_url": meterDownloadUrl,
      "previous_indication": event.metric.previousIndication,
      "current_indication": event.metric.currentIndication,
      "comment": event.metric.comment ?? ""
    };

    //Send to request
    final url =
        "http://45.84.226.183:5000/tasks/${event.metric.taskId}/complete";
    final response = await http.put(Uri.parse(url),
        headers: {'Content-Type': 'application/json'}, body: jsonEncode(data));
    if (response.statusCode != 200) {
      throw Exception('Failed to upload data');
    }
  }

  Future<String> _uploadImageToStorage(File image, String path) async {
    UploadTask uploadTask = FirebaseStorage.instance.ref(path).putFile(image);
    TaskSnapshot taskSnapshot = await uploadTask;
    String imageUrl = await taskSnapshot.ref.getDownloadURL();
    return imageUrl;
  }
}
