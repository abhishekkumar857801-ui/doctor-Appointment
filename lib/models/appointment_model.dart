
import 'package:cloud_firestore/cloud_firestore.dart';

class AppointmentModel {
  final String id;
  final String patientId;
  final String doctorId;
  final String doctorName;
  final String specialization;
  final DateTime appointmentDateTime;
  final String status;
  final DateTime? createdAt;

  const AppointmentModel({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.doctorName,
    required this.specialization,
    required this.appointmentDateTime,
    required this.status,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'patientId': patientId,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'specialization': specialization,
      'appointmentDateTime':
      Timestamp.fromDate(appointmentDateTime),
      'status': status,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  factory AppointmentModel.fromMap(
      String id,
      Map<String, dynamic> map,
      ) {
    final dateValue = map['appointmentDateTime'];

    return AppointmentModel(
      id: id,
      patientId: map['patientId'] as String? ?? '',
      doctorId: map['doctorId'] as String? ?? '',
      doctorName: map['doctorName'] as String? ?? 'Doctor',
      specialization:
      map['specialization'] as String? ?? 'Not specified',
      appointmentDateTime: dateValue is Timestamp
          ? dateValue.toDate()
          : DateTime.now(),
      status: map['status'] as String? ?? 'pending',
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : null,
    );
  }
}
