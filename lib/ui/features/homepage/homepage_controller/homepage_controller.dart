import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:alarm/alarm.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:telehealth_app/agora_service.dart';
import 'package:telehealth_app/app/resources/app.logger.dart';
import 'package:telehealth_app/ui/shared/global_variables.dart';
import 'package:telehealth_app/video_call_page.dart';
import 'package:url_launcher/url_launcher.dart';

var log = getLogger('HomepageController');

class HomepageController extends GetxController {
  static HomepageController get to => Get.find();

  RxList<Map<String, dynamic>> drugSchedules = <Map<String, dynamic>>[].obs;
  RxList<String> patientNames = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    log.d('Fetching drug schedules...');
    fetchDrugSchedules();
    fetchPatients();

    // Set up a real-time listener for changes in the database
    final ref = FirebaseDatabase.instance.ref('schedule');
    ref.onValue.listen((event) {
      log.d('Database change detected');
      fetchDrugSchedules(); // Fetch drug schedules again when changes occur
    });
    print('myRole..,,.,., ${GlobalVariables.myRole}');

    if (GlobalVariables.myRole == 'doctor') {
      fetchPatientNames();
    }
  }

  Future<void> fetchDrugSchedules() async {
    try {
      final ref = FirebaseDatabase.instance.ref('schedule');
      final schedulesSnapshot = await ref.get();

      // Clear existing schedules before fetching new data
      drugSchedules.clear();

      if (schedulesSnapshot.exists) {
        final List<Map<String, dynamic>> schedules = [];
        final dynamic snapshotValue = schedulesSnapshot.value;

        if (snapshotValue != null && snapshotValue is Map<dynamic, dynamic>) {
          snapshotValue.forEach((key, value) {
            if (value is Map<dynamic, dynamic>) {
              schedules.add(Map<String, dynamic>.from(value));
            }
          });

          drugSchedules.assignAll(schedules);
          log.d('Drug schedules fetched successfully: $schedules');

          // Schedule alarms for drugs that are due
          scheduleAlarmsForDueDrugs(schedules);
        } else {
          log.e('Invalid data format for schedules');
        }
      } else {
        log.e('No schedules found for user ${GlobalVariables.myUsername}');
      }
    } catch (e) {
      log.e('Error fetching drug schedules: $e');
    }
  }

  Future<void> fetchPatientNames() async {
    try {
      final ref = FirebaseDatabase.instance.ref('schedule');
      final schedulesSnapshot = await ref.get();

      if (schedulesSnapshot.exists) {
        final List<String> names = [];
        final dynamic snapshotValue = schedulesSnapshot.value;

        if (snapshotValue != null && snapshotValue is Map<dynamic, dynamic>) {
          snapshotValue.forEach((username, _) {
            names.add(username as String);
          });

          patientNames.assignAll(names);
          log.d('Patient names fetched successfully: $names');
        } else {
          log.e('Invalid data format for schedules');
        }
      } else {
        log.e('No schedules found');
      }
    } catch (e) {
      log.e('Error fetching patient names: $e');
    }
  }

  Future<void> fetchPatients() async {
    try {
      // Access the users node where all users' data is stored
      final ref = FirebaseDatabase.instance.ref('users');
      final usersSnapshot = await ref.get();

      if (usersSnapshot.exists) {
        final List<Map<String, dynamic>> patients = [];
        final dynamic snapshotValue = usersSnapshot.value;

        if (snapshotValue != null && snapshotValue is Map<dynamic, dynamic>) {
          snapshotValue.forEach((key, value) {
            if (value is Map<dynamic, dynamic> && value['role'] == 'patient') {
              // Collect patient details
              patients.add({'username': key, ...Map<String, dynamic>.from(value)});
            }
          });

          // Update the state with the fetched patient data
          drugSchedules.assignAll(patients); // Assuming this is where you want to display patients
          log.d('Patients fetched successfully: $patients');
        } else {
          log.e('Invalid data format for users');
        }
      } else {
        log.e('No users found');
      }
    } catch (e) {
      log.e('Error fetching patients: $e');
    }
  }

  Future<void> makeEmergencyCall() async {
    try {
      final ref = FirebaseDatabase.instance.ref('users/${GlobalVariables.myUsername}');
      final userSnapshot = await ref.get();

      if (userSnapshot.exists) {
        final userData = userSnapshot.value as Map<dynamic, dynamic>?;

        if (userData != null && userData.containsKey('emergencyContact')) {
          final String? emergencyNumber = userData['emergencyContact'] as String?;

          if (emergencyNumber != null && emergencyNumber.isNotEmpty) {
            final Uri launchUri = Uri(scheme: 'tel', path: emergencyNumber);
            if (await canLaunch(launchUri.toString())) {
              await launch(launchUri.toString());
              log.d('Launching $emergencyNumber');
              return;
            } else {
              log.e('Could not launch $emergencyNumber');
            }
          } else {
            log.e('Emergency contact number is null or empty');
          }
        } else {
          log.e('Emergency contact number not found in user data');
        }
      } else {
        log.e('User ${GlobalVariables.myUsername} does not exist');
      }
    } catch (e) {
      log.e('Error fetching emergency contact: $e');
    }
  }

  Future<void> scheduleAlarmsForDueDrugs(List<Map<String, dynamic>> schedules) async {
    final now = DateTime.now();

    for (var schedule in schedules) {
      final scheduleDetails = schedule.values.first;
      final List<String> scheduledTimes = (scheduleDetails['times'] as List<dynamic>).map((e) => e.toString()).toList();

      for (var time in scheduledTimes) {
        try {
          final timeComponents = time.split(' ');
          if (timeComponents.length == 2) {
            final List<String> hmComponents = timeComponents[0].split(':');
            if (hmComponents.length == 2) {
              final int hours = int.parse(hmComponents[0]);
              final int minutes = int.parse(hmComponents[1]);
              final bool isPM = timeComponents[1].toLowerCase() == 'pm';
              final int adjustedHours = (isPM && hours < 12) ? hours + 12 : (hours == 12 ? 0 : hours);

              final DateTime scheduledTime = DateTime(now.year, now.month, now.day, adjustedHours, minutes);

              if (scheduledTime.isAfter(now)) {
                await setAlarm(
                  id: scheduleDetails['id'] ?? 0,
                  scheduleTime: TimeOfDay(hour: adjustedHours, minute: minutes),
                  title: 'Medication Reminder',
                  body: 'It\'s time to take ${scheduleDetails['medicationName']}',
                );
              }
            } else {
              log.e('Invalid time format in $time');
            }
          } else {
            log.e('Invalid time format in $time');
          }
        } catch (e) {
          log.e('Error processing time $time: $e');
        }
      }
    }
  }

  Future<void> setAlarm({
    required int id,
    required TimeOfDay scheduleTime,
    required String title,
    required String body,
  }) async {
    final now = DateTime.now();
    DateTime alarmTime = DateTime(
      now.year,
      now.month,
      now.day,
      scheduleTime.hour,
      scheduleTime.minute,
    );

    // Adjust alarm time if it's already past
    Duration difference = alarmTime.difference(DateTime.now());
    difference = difference + const Duration(minutes: 1);

    if (difference.isNegative == false) {
      // Define Alarm Parameters
      final alarmSettings = AlarmSettings(
        id: id,
        dateTime: alarmTime,
        assetAudioPath: 'assets/alarm.mp3',
        loopAudio: false,
        vibrate: true,
        volume: 0.8,
        fadeDuration: 3.0,
        notificationTitle: title,
        notificationBody: body,
        enableNotificationOnKill: true,
        androidFullScreenIntent: true,
      );

      // Set the alarm
      await Alarm.set(alarmSettings: alarmSettings);
      log.d("Alarm set for $title at ${alarmTime.toIso8601String()}");
    } else {
      log.e("The alarm time $alarmTime is in the past.");
    }
  }
}
