import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:telehealth_app/ui/features/schedule/schedule_model/medication_model.dart';

class ScheduleController extends GetxController {
  static ScheduleController get to => Get.find();
  final DatabaseReference _database = FirebaseDatabase.instance.reference();

  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController genderController = TextEditingController();
  final TextEditingController contactInfoController = TextEditingController();
  final TextEditingController emergencyContact = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController allergicSubstanceController = TextEditingController();
  final TextEditingController reactionTypeController = TextEditingController();
  final TextEditingController severityController = TextEditingController();

  RxList<MedicalRecord> records = RxList<MedicalRecord>();

  @override
  void onInit() {
    super.onInit();
    fetchRecords();
  }

  @override
  void onClose() {
    fullNameController.dispose();
    genderController.dispose();
    contactInfoController.dispose();
    emergencyContact.dispose();
    dobController.dispose();
    allergicSubstanceController.dispose();
    reactionTypeController.dispose();
    severityController.dispose();
    super.onClose();
  }

  Future<void> saveMedicalRecord() async {
    try {
      final record = {
        "fullName": fullNameController.text.trim(),
        "gender": genderController.text.trim(),
        "contactInfo": contactInfoController.text.trim(),
        "emergencyContact": emergencyContact.text.trim(),
        "dob": dobController.text.trim(),
        "allergicSubstance": allergicSubstanceController.text.trim(),
        "reactionType": reactionTypeController.text.trim(),
        "severity": severityController.text.trim(),
      };

      await _database.child('medical_records').push().set(record).then((_) {
        Get.snackbar("Successful", "Medical record saved successfully.");
      });

      resetFields();
    } catch (e) {
      print("Exception occurred: ${e.toString()}");
      Get.snackbar("Error", "Failed to save medical record. Please try again.");
    }
  }

  void resetFields() {
    fullNameController.clear();
    genderController.clear();
    contactInfoController.clear();
    emergencyContact.clear();
    dobController.clear();
    allergicSubstanceController.clear();
    reactionTypeController.clear();
    severityController.clear();
  }

  void fetchRecords() {
    _database.child('medical_records').onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;

      if (data != null) {
        records.value = data.entries.map((entry) {
          return MedicalRecord.fromRealtimeDatabaseSnapshot(entry.value);
        }).toList();
      } else {
        records.clear();
      }
    });
  }
}
