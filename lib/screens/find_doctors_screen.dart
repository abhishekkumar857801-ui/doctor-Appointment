
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'book_appointment_screen.dart';

class FindDoctorsScreen extends StatelessWidget {
  const FindDoctorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF176B87);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Doctors'),
        backgroundColor: primary,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('doctors')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Unable to load doctors. Please try again.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final doctors = snapshot.data?.docs ?? [];

          if (doctors.isEmpty) {
            return const Center(
              child: Text('No doctors available yet.'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: doctors.length,
            itemBuilder: (context, index) {
              final doctorDocument = doctors[index];
              final doctor = doctorDocument.data();

              final name =
                  doctor['name'] as String? ?? 'Doctor';
              final specialization =
                  doctor['specialization'] as String? ??
                      'Not specified';
              final qualification =
                  doctor['qualification'] as String? ??
                      'Not specified';
              final experience = doctor['experience'];
              final available = doctor['available'] == true;

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const CircleAvatar(
                            radius: 28,
                            backgroundColor: Color(0xFFDDF3F7),
                            child: Icon(
                              Icons.medical_services,
                              color: primary,
                              size: 30,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              name,
                              style: const TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF17324D),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      _buildDetail(
                        Icons.local_hospital_outlined,
                        'Specialization',
                        specialization,
                      ),
                      const SizedBox(height: 10),

                      _buildDetail(
                        Icons.school_outlined,
                        'Qualification',
                        qualification,
                      ),
                      const SizedBox(height: 10),

                      _buildDetail(
                        Icons.work_outline,
                        'Experience',
                        experience == null
                            ? 'Not specified'
                            : '$experience years',
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Icon(
                            Icons.circle,
                            size: 12,
                            color: available
                                ? Colors.green
                                : Colors.red,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            available
                                ? 'Available'
                                : 'Not available',
                            style: TextStyle(
                              color: available
                                  ? Colors.green
                                  : Colors.red,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: available
                              ? () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    BookAppointmentScreen(
                                      doctorId: doctorDocument.id,
                                      doctorName: name,
                                      specialization: specialization,
                                    ),
                              ),
                            );
                          }
                              : null,
                          icon: const Icon(Icons.calendar_month),
                          label: const Text('Book Appointment'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primary,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Colors.grey.shade300,
                            padding: const EdgeInsets.symmetric(
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
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

  static Widget _buildDetail(
      IconData icon,
      String label,
      String value,
      ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: const Color(0xFF176B87),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            '$label: $value',
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }
}
