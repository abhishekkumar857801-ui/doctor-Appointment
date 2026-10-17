
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'login_screen.dart';
import 'doctor_appointments_screen.dart';
import 'doctor_availability_screen.dart';

class DoctorDashboardScreen extends StatelessWidget {
  const DoctorDashboardScreen({super.key});

  static const Color primary = Color(0xFF176B87);
  static const Color background = Color(0xFFF4F8FB);

  Future<void> _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();

      if (!context.mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        ),
            (route) => false,
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Logout failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('Please log in again.'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: const Text('Doctor Dashboard'),
        backgroundColor: primary,
        foregroundColor: Colors.white,
        actions: [
          // Only one Logout button: top-right icon.
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Unable to load profile: ${snapshot.error}',
              ),
            );
          }

          final profile = snapshot.data?.data();
          final name = profile?['name']?.toString() ?? 'Doctor';

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Welcome card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.medical_services,
                      color: Colors.white,
                      size: 44,
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Welcome, Dr. $name!',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Manage your appointments and doctor profile.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Appointments card
              _menuCard(
                icon: Icons.calendar_month,
                title: 'My Appointments',
                subtitle: 'View and manage patient bookings',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                      const DoctorAppointmentsScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              // Profile and availability card
              _menuCard(
                icon: Icons.person_outline,
                title: 'My Profile & Availability',
                subtitle: 'Update your profile and availability',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                      const DoctorAvailabilityScreen(),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _menuCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 22,
          vertical: 24,
        ),
        leading: CircleAvatar(
          radius: 27,
          backgroundColor: const Color(0xFFE5F2F7),
          child: Icon(
            icon,
            color: primary,
            size: 27,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            subtitle,
            style: const TextStyle(fontSize: 14),
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
