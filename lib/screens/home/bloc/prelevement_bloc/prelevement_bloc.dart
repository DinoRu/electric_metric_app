import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:electric_meter_app/screens/home/bloc/data_list_bloc/data_list_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:metric_repository/metric_repository.dart';
// import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

part 'prelevement_event.dart';
part 'prelevement_state.dart';

class PrelevementBloc extends Bloc<PrelevementEvent, PrelevementState> {
  final DatabaseHelper databaseHelper = DatabaseHelper();
  final Metricservice metricservice = Metricservice();
  DataListBloc dataListBloc = DataListBloc();
  PrelevementBloc() : super(PrelevementInitial()) {
    on<SubmitEvent>((event, emit) async {
      emit(PrelevementLoading());
      try {
        final connectivityResult = await Connectivity().checkConnectivity();
        if (connectivityResult.contains(ConnectivityResult.none)) {
          await _saveDataLocaly(event);
          log("Data store in Local database");
          emit(PrelevementSuccess());
          dataListBloc.add(GetPendingMetricEvent());
        } else {
          try {
            await _updateDataAndSendToApi(event);
            databaseHelper.deleteMeter(event.meterId);
            emit(PrelevementSuccess());
            dataListBloc.add(GetPendingMetricEvent());
          } catch (e) {
            emit(const PrelevementFailure("Ошибка, попробуйте поже"));
          }
        }
      } catch (e) {
        log(e.toString());
        emit(const PrelevementFailure(
            "Не удалось отправить \n Повторите процесс!"));
      }
    });
  }

  Future<void> _saveDataLocaly(SubmitEvent event) async {
    final db = await databaseHelper.database;
    final Map<String, dynamic> updateData = {
      "taskId": event.meterId,
      "currentIndication": event.currentIndication,
      "previousIndication": event.previousIndication,
      "farPhotoUrl": event.meterImage.path,
      "nearPhotoUrl": event.metricImage.path,
      "comment": event.comment,
      "status": 'Проверяется',
    };
    await db.update(
      'meters',
      updateData,
      where: 'taskId = ?',
      whereArgs: [event.meterId],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> _updateDataAndSendToApi(SubmitEvent event) async {
    log("Data send to API");
    String meterImageName =
        '${event.meterName}_${DateTime.now().microsecondsSinceEpoch}.jpg';
    String meterDownloadUrl = await _uploadImageToStorage(
        File(event.meterImage.path),
        "metrics/${event.meterName}/$meterImageName");

    //Upload metric image to firebase storage
    String metricImageName =
        '${event.meterName}_${DateTime.now().microsecondsSinceEpoch}_1.jpg';
    String metricDownloadUrl = await _uploadImageToStorage(
        File(event.metricImage.path),
        "metrics/${event.meterName}/$metricImageName");

    Map<String, dynamic> data = {
      "near_photo_url": meterDownloadUrl,
      "far_photo_url": metricDownloadUrl,
      "previous_indication": event.previousIndication,
      "current_indication": event.currentIndication,
      "comment": event.comment ?? ""
    };

    //Send to request
    final url = "http://45.84.226.183:5000/tasks/${event.meterId}/complete";
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
