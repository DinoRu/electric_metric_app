import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'package:metric_repository/features/database.dart';

class Metricservice {
  final DatabaseHelper databaseHelper = DatabaseHelper();

  Future<void> syncPendingData() async {
    final db = await databaseHelper.database;
    bool isConnected = await _isConnected();
    if (isConnected) {
      List<Map<String, dynamic>> meters =
          await databaseHelper.getMetersByStatus("Провереятся");
      for (final meter in meters) {
        try {
          String meterImageName =
              '${meter['number']}_${DateTime.now().millisecondsSinceEpoch}.jpg';
          String metricImageName =
              '${meter['number']}_${DateTime.now().millisecondsSinceEpoch}_1.jpg';
          final String meterImageUrl = await _uploadImage(
              meter['nearPhotoUrl'], meter['number'], meterImageName);
          final String metricImageUrl = await _uploadImage(
              File(meter['farPhotoUrl']), meter['number'], metricImageName);
          final data = {
            "near_photo_url": meterImageUrl,
            "far_photo_url": metricImageUrl,
            "current_indication": meter["currentIndication"],
            "previous_indication": meter["previousIndication"],
            "comment": meter["comment"] ?? ""
          };
          final url =
              "http://45.84.226.183:5000/tasks/${meter['taskId']}/complete";
          final response = await http.put(Uri.parse(url),
              headers: {"Content-Type": "application/json"},
              body: jsonEncode(data));
          if (response.statusCode == 200) {
            log('Successfully send data to server');
            await db.update('meters', {'status': 'Выполнено'},
                where: 'taskId = ?', whereArgs: [meter['taskId']]);
          } else {
            log("Failed to send to server");
          }
        } catch (e) {
          log(e.toString());
        }
      }
    } else {
      return;
    }
  }

  Future<bool> _isConnected() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult.contains(ConnectivityResult.mobile) ||
        connectivityResult.contains(ConnectivityResult.wifi);
  }

  Future<String> _uploadImage(
      File imageFile, String name, String imageName) async {
    UploadTask uploadTask = FirebaseStorage.instance
        .ref('meters/$name/$imageName')
        .putFile(imageFile);
    TaskSnapshot taskSnapshot = await uploadTask;
    return await taskSnapshot.ref.getDownloadURL();
  }
}
