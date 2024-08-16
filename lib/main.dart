import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:telehealth_app/app/resources/app.locator.dart';
import 'package:telehealth_app/app/resources/app.router.dart';
import 'package:telehealth_app/telehealth_app.dart';
import 'package:telehealth_app/ui/features/homepage/homepage_controller/homepage_controller.dart';

import 'firebase_options.dart';

// void main() {
//   runApp(const MyApp());
// }

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );



  await setupLocator();

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,

  );

  Get.put(HomepageController());
  final router = await AppRouter.createRouter(); // Create the router dynamically



  runApp(TelehealthApp(router: router));
}
