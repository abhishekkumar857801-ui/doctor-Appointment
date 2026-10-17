
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'book_appointment_screen.dart';

class FindDoctorsScreen extends StatelessWidget {
  const FindDoctorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Doctors'),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('doctors')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Firestore error:\n${snapshot.error}',
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

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return const Center(
              child: Text('No doctors found.'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data();

              final String name =
                  data['name']?.toString() ?? 'Unnamed doctor';

              final String specialization =
                  data['specialization']?.toString() ??
                      'Not specified';

              final String qualification =
                  data['qualification']?.toString() ??
                      'Not specified';

              final bool isAvailable =
                  data['available'] == true;

              final String approvalStatus =
                  data['approvalStatus']
                      ?.toString()
                      .toLowerCase() ??
                      'missing';

              final bool isApproved =
                  approvalStatus == 'approved';

              final bool canBook =
                  isAvailable && isApproved;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text('Specialization: $specialization'),
                      Text('Qualification: $qualification'),
                      Text(
                        'Availability: '
                            '${isAvailable ? 'Available' : 'Unavailable'}',
                      ),
                      Text(
                        'Approval: $approvalStatus',
                      ),
                      const SizedBox(height: 12),

                      if (!canBook)
                        const Text(
                          'Booking unavailable: the doctor must '
                              'be approved and available.',
                          style: TextStyle(color: Colors.red),
                        ),

                      const SizedBox(height: 8),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: canBook
                              ? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    BookAppointmentScreen(
                                      doctorId: doc.id,
                                      doctorName: name,
                                      specialization:
                                      specialization,
                                    ),
                              ),
                            );
                          }
                              : null,
                          child: const Text('Book Appointment'),
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
}
