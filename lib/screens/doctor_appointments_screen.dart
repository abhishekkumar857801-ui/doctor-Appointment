
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
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _loading = true;
  String? _doctorId;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDoctorProfile();
  }

  Future<void> _loadDoctorProfile() async {
    try {
      final user = _auth.currentUser;

      if (user == null) {
        throw Exception('Please log in again.');
      }

      final result = await _firestore
          .collection('doctors')
          .where('ownerUid', isEqualTo: user.uid)
          .limit(1)
          .get();

      if (result.docs.isEmpty) {
        throw Exception(
          'No doctor profile is linked to this account. '
              'Check the ownerUid field in Firestore.',
        );
      }

      if (!mounted) return;

      setState(() {
        _doctorId = result.docs.first.id;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _updateStatus(
      String appointmentId,
      String status,
      ) async {
    try {
      await _firestore
          .collection('appointments')
          .doc(appointmentId)
          .update({'status': status});

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            status == 'approved'
                ? 'Appointment approved successfully.'
                : 'Appointment rejected.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to update appointment: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF176B87);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Appointments'),
        backgroundColor: primary,
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            _error!,
            textAlign: TextAlign.center,
          ),
        ),
      )
          : StreamBuilder<
          QuerySnapshot<Map<String, dynamic>>>(
        stream: _firestore
            .collection('appointments')
            .where('doctorId', isEqualTo: _doctorId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Unable to load appointments. '
                      'Check Firestore rules and your connection.',
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

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return const Center(
              child: Text(
                'No appointments found.',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          final appointments = [...docs];

          appointments.sort((a, b) {
            final aDate =
            a.data()['appointmentDateTime'] as Timestamp?;
            final bDate =
            b.data()['appointmentDateTime'] as Timestamp?;

            return (aDate?.millisecondsSinceEpoch ?? 0)
                .compareTo(
              bDate?.millisecondsSinceEpoch ?? 0,
            );
          });

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: appointments.length,
            itemBuilder: (context, index) {
              final doc = appointments[index];
              final data = doc.data();

              final patientId =
                  data['patientId'] as String? ?? 'Unknown';
              final doctorName =
                  data['doctorName'] as String? ?? 'Doctor';
              final specialization =
                  data['specialization'] as String? ?? '';
              final status =
                  data['status'] as String? ?? 'pending';

              final timestamp =
              data['appointmentDateTime'] as Timestamp?;

              final dateTime = timestamp?.toDate();
              final isPending = status == 'pending';

              final statusColor = switch (status) {
                'approved' => Colors.green,
                'rejected' || 'cancelled' => Colors.red,
                _ => Colors.orange,
              };

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text(
                        doctorName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text('Patient ID: $patientId'),
                      const SizedBox(height: 6),
                      Text('Specialization: $specialization'),
                      const SizedBox(height: 6),
                      Text(
                        dateTime == null
                            ? 'Date: Not available'
                            : 'Date: ${dateTime.day}/'
                            '${dateTime.month}/'
                            '${dateTime.year}',
                      ),
                      if (dateTime != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          'Time: ${TimeOfDay.fromDateTime(dateTime).format(context)}',
                        ),
                      ],
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Text('Status: '),
                          Text(
                            status.toUpperCase(),
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      if (isPending) ...[
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () =>
                                    _updateStatus(
                                      doc.id,
                                      'approved',
                                    ),
                                icon: const Icon(
                                  Icons.check,
                                ),
                                label: const Text('Approve'),
                                style:
                                ElevatedButton.styleFrom(
                                  backgroundColor:
                                  Colors.green,
                                  foregroundColor:
                                  Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () =>
                                    _updateStatus(
                                      doc.id,
                                      'rejected',
                                    ),
                                icon: const Icon(
                                  Icons.close,
                                ),
                                label: const Text('Reject'),
                                style:
                                ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor:
                                  Colors.white,
                                ),
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
    );
  }
}
