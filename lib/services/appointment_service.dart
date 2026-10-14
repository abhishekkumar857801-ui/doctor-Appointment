
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/appointment_model.dart';

class AppointmentService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>>
  get _appointments =>
      _firestore.collection('appointments');

  Future<String> bookAppointment({
    required String doctorId,
    required String doctorName,
    required String specialization,
    required DateTime appointmentDateTime,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('Please log in to book an appointment.');
    }

    if (!appointmentDateTime.isAfter(DateTime.now())) {
      throw Exception('Please select a future date and time.');
    }

    final appointmentRef = _appointments.doc();

    final appointment = AppointmentModel(
      id: appointmentRef.id,
      patientId: user.uid,
      doctorId: doctorId,
      doctorName: doctorName,
      specialization: specialization,
      appointmentDateTime: appointmentDateTime,
      status: 'pending',
    );

    await appointmentRef.set(appointment.toMap());

    return appointmentRef.id;
  }

  Stream<List<AppointmentModel>> getMyAppointments() {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('Please log in to view appointments.');
    }

    return _appointments
        .where('patientId', isEqualTo: user.uid)
        .snapshots()
        .map((snapshot) {
      final appointments = snapshot.docs.map((doc) {
        return AppointmentModel.fromMap(
          doc.id,
          doc.data(),
        );
      }).toList();

      appointments.sort(
            (a, b) => a.appointmentDateTime.compareTo(
          b.appointmentDateTime,
        ),
      );

      return appointments;
    });
  }

  Future<void> cancelAppointment(String appointmentId) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('Please log in to cancel an appointment.');
    }

    final appointmentRef = _appointments.doc(appointmentId);
    final snapshot = await appointmentRef.get();

    if (!snapshot.exists) {
      throw Exception('Appointment not found.');
    }

    final data = snapshot.data()!;

    if (data['patientId'] != user.uid) {
      throw Exception('You cannot cancel another patient’s appointment.');
    }

    if (data['status'] == 'cancelled') {
      throw Exception('This appointment is already cancelled.');
    }

    await appointmentRef.update({
      'status': 'cancelled',
    });
  }
}
