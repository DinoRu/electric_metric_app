import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:electric_meter_app/screens/home/bloc/data_list_bloc/data_list_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:metric_repository/metric_repository.dart';
import 'package:path_provider/path_provider.dart';
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
        await _saveDataLocaly(event);
        log("Data store in Local database");
        emit(PrelevementSuccess());
        dataListBloc.add(GetPendingMetricEvent());
        // String meterImageName =
        //     '${event.meterName}_${DateTime.now().microsecondsSinceEpoch}.jpg';
//         UploadTask meterUploadTask = FirebaseStorage.instance
//             .ref('meters/${event.meterName}/$meterImageName')
//             .putFile(File(event.meterImage.path));
//
//         TaskSnapshot taskSnapshot = await meterUploadTask;
//         String meterDownloadUrl = await _uploadImage(
//             File(event.meterImage.path), event.meterName, meterImageName);
//
//         //Upload metric image to firebase storage
//         String metricImageName =
//             '${event.meterName}_${DateTime.now().millisecondsSinceEpoch}_1.jpg';
// //         UploadTask metricUploadTask = FirebaseStorage.instance
// //             .ref('meters/${event.meterName}/$metricImageName')
// //             .putFile(File(event.metricImage.path));
// //
// //         TaskSnapshot metricTaskSnapshot = await metricUploadTask;
//         String metricDownloadUrl = await _uploadImage(
//             File(event.metricImage.path), event.meterName, metricImageName);
//
//         Map<String, dynamic> data = {
//           "near_photo_url": meterDownloadUrl,
//           "far_photo_url": metricDownloadUrl,
//           "previous_indication": event.previousIndication,
//           "current_indication": event.currentIndication,
//           "comment": event.comment ?? ""
//         };
//
//         //Send to request
//         final url = "http://45.84.226.183:5000/tasks/${event.meterId}/complete";
//         final response = await http.put(Uri.parse(url),
//             headers: {'Content-Type': 'application/json'},
//             body: jsonEncode(data));
//
//         if (response.statusCode == 200) {
//           emit(PrelevementSuccess());
        // } else {
        //   // log(response.statusCode.toString());
        //   emit(PrelevementFailure(
        //       "Повторно загрузите фотографию показаний: \n${response.statusCode}"));
        // }
      } catch (e) {
        log(e.toString());
        emit(const PrelevementFailure(
            "Не удалось отправить \n Повторите процесс!"));
      }
    });
  }

  Future<String> _uploadImage(
      File imageFile, String name, String imageName) async {
    UploadTask uploadTask = FirebaseStorage.instance
        .ref('meters/$name/$imageName')
        .putFile(imageFile);
    TaskSnapshot taskSnapshot = await uploadTask;
    return await taskSnapshot.ref.getDownloadURL();
  }

  // Future<void> _saveImageLocally(XFile imageFile, String imageName) async {
  //   final directory = await getApplicationDocumentsDirectory();
  //   final path = "${directory.path}/$imageName";
  //   final file = File(path);
  //   await file.writeAsBytes(await imageFile.readAsBytes());
  // }

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
}
