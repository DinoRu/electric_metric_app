import 'dart:developer';

import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

Future<void> initializeService() async {
  final servcie = FlutterBackgroundService();

  if (await servcie.isRunning()) {
    return;
  }

  await servcie.configure(
      iosConfiguration: IosConfiguration(
        onForeground: onStart,
        autoStart: true,
      ),
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        isForegroundMode: true,
        autoStart: true,
        initialNotificationTitle: "Service running",
        initialNotificationContent: "Tap to return to the app",
      ));
  await servcie.startService();
}

void onStart(ServiceInstance service) async {
  log('Service started..');
  InternetConnectionChecker().onStatusChange.listen((status) {
    switch (status) {
      case InternetConnectionStatus.disconnected:
        log('You are disconnected from the internet.');
        break;

      case InternetConnectionStatus.connected:
        log("You are connected");
        break;
    }
  });
}
