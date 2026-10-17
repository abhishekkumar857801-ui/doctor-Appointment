
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AdminDoctorsScreen extends StatefulWidget {
  const AdminDoctorsScreen({super.key});

  @override
  State<AdminDoctorsScreen> createState() =>
      _AdminDoctorsScreenState();
}

class _AdminDoctorsScreenState extends State<AdminDoctorsScreen> {
  static const Color primary = Color(0xFF176B87);

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _updating = false;
  String? _updatingDoctorId;

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 5),
        ),
      );
  }

  Future<bool> _verifyAdmin() async {
    final user = _auth.currentUser;

    if (user == null) {
      _showMessage('Please log in again.');
      return false;
    }

    try {
      final profile =
      await _db.collection('users').doc(user.uid).get();

      if (profile.data()?['role'] != 'admin') {
        _showMessage(
          'Access denied. Check the admin role in Firestore.',
        );
        return false;
      }

      return true;
    } catch (e) {
      _showMessage('Could not verify admin: $e');
      return false;
    }
  }

  Future<void> _changeAvailability(
      String doctorId,
      bool available,
      ) async {
    if (_updating) return;

    setState(() {
      _updating = true;
      _updatingDoctorId = doctorId;
    });

    try {
      if (!await _verifyAdmin()) return;

      await _db.collection('doctors').doc(doctorId).update({
        'available': available,
      });

      _showMessage(
        available
            ? 'Doctor is now available for booking.'
            : 'Doctor is now unavailable for booking.',
      );
    } on FirebaseException catch (e) {
      _showMessage(
        'Firestore error (${e.code}): ${e.message ?? ''}',
      );
    } catch (e) {
      _showMessage('Failed to update availability: $e');
    } finally {
      if (mounted) {
        setState(() {
          _updating = false;
          _updatingDoctorId = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Doctors'),
        backgroundColor: primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {}),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _db.collection('doctors').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Unable to load doctors:\n${snapshot.error}',
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
              child: Text('No doctors registered yet.'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: doctors.length,
            itemBuilder: (context, index) {
              final doc = doctors[index];
              final data = doc.data();

              final doctorId = doc.id;
              final name =
                  data['name']?.toString() ?? 'Unnamed doctor';
              final specialization =
                  data['specialization']?.toString() ??
                      'Not specified';
              final qualification =
                  data['qualification']?.toString() ??
                      'Not specified';
              final available = data['available'] == true;

              final busy = _updatingDoctorId == doctorId;

              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 14),
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
                            backgroundColor: Color(0xFFE0F2F6),
                            child: Icon(
                              Icons.medical_services,
                              color: primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(specialization),
                                Text(qualification),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SelectableText(
                        'Doctor ID: $doctorId',
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: available
                              ? Colors.green.withAlpha(25)
                              : Colors.red.withAlpha(20),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          available
                              ? 'Available for booking'
                              : 'Unavailable for booking',
                          style: TextStyle(
                            color: available
                                ? Colors.green.shade800
                                : Colors.red.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Doctor Availability'),
                        subtitle: Text(
                          available
                              ? 'Patients can book this doctor'
                              : 'Patients cannot book this doctor',
                        ),
                        value: available,
                        onChanged: _updating
                            ? null
                            : (value) => _changeAvailability(
                          doctorId,
                          value,
                        ),
                      ),
                      if (busy)
                        const LinearProgressIndicator(),
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
