import 'package:firebase_database/firebase_database.dart';

class MedicalRecord {
  final String fullName;
  final String gender;
  final String dob;
  final String contactInfo;
  final String emergencyContact;
  final String allergicSubstance;
  final String reactionType;
  final String severity;

  MedicalRecord({
    required this.fullName,
    required this.gender,
    required this.contactInfo,
    required this.emergencyContact,
    required this.dob,
    required this.allergicSubstance,
    required this.reactionType,
    required this.severity,
  });

  factory MedicalRecord.fromRealtimeDatabaseSnapshot(Map<dynamic, dynamic> snapshot) {
    return MedicalRecord(
      fullName: snapshot['fullName'] ?? '',
      dob: snapshot['dOb'] ?? '',
      contactInfo: snapshot['gender'] ?? '',
      emergencyContact: snapshot['contactInfo'] ?? '',
      gender: snapshot['emergencyContact'] ?? '',
      allergicSubstance: snapshot['allergicSubstance'] ?? '',
      reactionType: snapshot['reactionType'] ?? '',
      severity: snapshot['severity'] ?? '',
    );
  }
}
