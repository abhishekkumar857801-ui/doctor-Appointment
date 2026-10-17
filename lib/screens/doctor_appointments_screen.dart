
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DoctorAppointmentsScreen extends StatefulWidget {
  const DoctorAppointmentsScreen({super.key});

  @override
  State<DoctorAppointmentsScreen> createState() =>
      _DoctorAppointmentsScreenState();
}

class _DoctorAppointmentsScreenState
    extends State<DoctorAppointmentsScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String? _doctorId;
  String? _doctorName;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _findDoctor();
  }

  Future<void> _findDoctor() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception('No logged-in user. Please log in again.');
      }

      // First, search for legacy and newer profiles by ownerUid.
      final result = await _db
          .collection('doctors')
          .where('ownerUid', isEqualTo: user.uid)
          .limit(1)
          .get();

      if (result.docs.isNotEmpty) {
        final doctor = result.docs.first;
        _doctorId = doctor.id;
        _doctorName = doctor.data()['name']?.toString();
      } else {
        // New profiles may use the Firebase UID as document ID.
        final direct =
        await _db.collection('doctors').doc(user.uid).get();

        if (direct.exists) {
          _doctorId = direct.id;
          _doctorName = direct.data()?['name']?.toString();
        } else {
          throw Exception(
            'Doctor profile not found. Check that the doctor document '
                'ownerUid equals your logged-in Firebase UID (${user.uid}), '
                'or that its document ID equals your UID.',
          );
        }
      }

      debugPrint('Logged-in doctor UID: ${user.uid}');
      debugPrint('Doctor document ID: $_doctorId');
      debugPrint('Doctor name: $_doctorName');
    } catch (e) {
      _error = e.toString();
      debugPrint('FIND DOCTOR ERROR: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _updateStatus(
      String appointmentId,
      String status,
      ) async {
    try {
      await _db.collection('appointments').doc(appointmentId).update({
        'status': status,
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Appointment $status successfully')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not update appointment: $e')),
      );

      debugPrint('UPDATE APPOINTMENT ERROR: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Doctor Appointments')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Doctor Appointments')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Text(_error!, textAlign: TextAlign.center),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Doctor Appointments')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              'Doctor: ${_doctorName ?? "Doctor"}\n'
                  'Document ID: $_doctorId',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _db
                  .collection('appointments')
                  .where('doctorId', isEqualTo: _doctorId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        'Unable to load appointments:\n'
                            '${snapshot.error}',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final appointments = snapshot.data?.docs ?? [];

                if (appointments.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'No appointments found for this doctor.\n\n'
                            'Check that a patient booking exists and its '
                            'doctorId matches the document ID shown above.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: appointments.length,
                  itemBuilder: (context, index) {
                    final doc = appointments[index];
                    final data = doc.data();

                    final patientId =
                        data['patientId']?.toString() ?? 'Unknown';
                    final status =
                        data['status']?.toString() ?? 'pending';
                    final specialization =
                        data['specialization']?.toString() ?? '';
                    final dateValue = data['appointmentDateTime'];

                    String dateText = 'Date not available';

                    if (dateValue is Timestamp) {
                      dateText = dateValue
                          .toDate()
                          .toLocal()
                          .toString();
                    }

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Appointment ${doc.id}',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Text('Patient UID: $patientId'),
                            Text('Specialization: $specialization'),
                            Text('Date: $dateText'),
                            Text('Status: $status'),
                            if (status == 'pending') ...[
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () => _updateStatus(
                                        doc.id,
                                        'approved',
                                      ),
                                      child: const Text('Approve'),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () => _updateStatus(
                                        doc.id,
                                        'rejected',
                                      ),
                                      child: const Text('Reject'),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
