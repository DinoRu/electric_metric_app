import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:api_cache_manager/models/cache_db_model.dart';
import 'package:api_cache_manager/utils/cache_manager.dart';
import 'package:bloc/bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

part 'prelevement_event.dart';
part 'prelevement_state.dart';

class PrelevementBloc extends Bloc<PrelevementEvent, PrelevementState> {
  PrelevementBloc() : super(PrelevementInitial()) {
    on<SubmitEvent>((event, emit) async {
      emit(PrelevementLoading());
      try {
        final List<ConnectivityResult> connectivityResult =
            await (Connectivity().checkConnectivity());
        if (connectivityResult.contains(ConnectivityResult.none)) {
          // Store data to the cache for later synchronization
          await _storeDataInCache(event);
          emit(PrelevementSuccess());
        } else {
          // Proceed with the upload and API call
          await _updateDataAndSendToApi(event);
          emit(PrelevementSuccess());
        }
      } catch (e) {
        log(e.toString());
        emit(const PrelevementFailure(
            "Не удалось отправить \n Повторите процесс!"));
      }
    });
  }

  Future<String> _saveImageLocally(
      XFile image, Directory directory, String imageName) async {
    final path = directory.path;
    final file = File('$path/$imageName');
    return (await File(image.path).copy(file.path)).path;
  }

  Future<void> _storeDataInCache(SubmitEvent e) async {
    final directory = await getApplicationDocumentsDirectory();
    String meterImagePath = await _saveImageLocally(e.meterImage, directory,
        "${e.meterName}_${DateTime.now().microsecondsSinceEpoch}.jpg");
    String metricImagePath = await _saveImageLocally(e.metricImage, directory,
        "${e.meterImage}_${DateTime.now().microsecondsSinceEpoch}_1.jpg");
    final cackeKey = "API_meter_${e.meterId}";
    final data = {
      "meterId": e.meterId,
      "meterName": e.meterName,
      "previousIndication": e.previousIndication,
      "currentIndication": e.currentIndication,
      "meterImagePath": meterImagePath,
      "metricImagePath": metricImagePath,
      "comment": e.comment ?? ""
    };
    await APICacheManager().addCacheData(
        APICacheDBModel(key: cackeKey, syncData: jsonEncode(data)));
    log("Data successfully in cache");
  }

  Future<void> _updateDataAndSendToApi(SubmitEvent event) async {
    log("Data send to API");
    String meterImageName =
        '${event.meterName}_${DateTime.now().microsecondsSinceEpoch}.jpg';
//     UploadTask meterUploadTask = FirebaseStorage.instance
//         .ref('meters/${event.meterName}/$meterImageName')
//         .putFile(File(event.meterImage.path));
//
//     TaskSnapshot taskSnapshot = await meterUploadTask;
    // String meterDownloadUrl = await taskSnapshot.ref.getDownloadURL();
    String meterDownloadUrl = await _uploadImageToStorage(
        File(event.meterImage.path),
        "metrics/${event.meterName}/$meterImageName");

    //Upload metric image to firebase storage
    String metricImageName =
        '${event.meterName}_${DateTime.now().microsecondsSinceEpoch}_1.jpg';
//     UploadTask metricUploadTask = FirebaseStorage.instance
//         .ref('meters/${event.meterName}/$metricImageName')
//         .putFile(File(event.metricImage.path));
//
//     TaskSnapshot metricTaskSnapshot = await metricUploadTask;
//     String metricDownloadUrl = await metricTaskSnapshot.ref.getDownloadURL();
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
