import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

part 'prelevement_event.dart';
part 'prelevement_state.dart';

class PrelevementBloc extends Bloc<PrelevementEvent, PrelevementState> {
  PrelevementBloc() : super(PrelevementInitial()) {
    on<SubmitEvent>((event, emit) async {
      emit(PrelevementLoading());
      try {
        String meterImageName = '${event.meterName}.jpg';
        UploadTask meterUploadTask = FirebaseStorage.instance
            .ref('meters/${event.meterName}/$meterImageName')
            .putFile(File(event.meterImage.path));

        TaskSnapshot taskSnapshot = await meterUploadTask;
        String meterDownloadUrl = await taskSnapshot.ref.getDownloadURL();

        //Upload metric image to firebase storage
        String metricImageName = '${event.meterName}_1.jpg';
        UploadTask metricUploadTask = FirebaseStorage.instance
            .ref('meters/${event.meterName}/$metricImageName')
            .putFile(File(event.metricImage.path));

        TaskSnapshot metricTaskSnapshot = await metricUploadTask;
        String metricDownloadUrl =
            await metricTaskSnapshot.ref.getDownloadURL();

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
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(data));

        if (response.statusCode == 200) {
          emit(PrelevementSuccess());
        } else {
          log(response.statusCode.toString());
          emit(PrelevementFailure(
              "Повторно загрузите фотографию показаний: \n${response.statusCode}"));
        }
      } catch (e) {
        log(e.toString());
        emit(const PrelevementFailure(
            "Не удалось отправить \n Повторите процесс!"));
      }
    });
  }
}
