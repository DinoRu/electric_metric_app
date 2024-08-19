import 'package:bloc/bloc.dart';
import 'package:electric_meter_app/simple_bloc_observer.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:metric_repository/metric_repository.dart';
import 'package:user_repository/user_repository.dart';
import 'app.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
  );
  final DatabaseHelper databaseHelper = DatabaseHelper();
  await databaseHelper.database;
  Bloc.observer = const SimpleBlocObserver();
  runApp(MyApp(ApiUserRepository()));
}
