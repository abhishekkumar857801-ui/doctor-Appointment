import 'doctor_appointments_screen.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'find_doctors_screen.dart';
import 'my_appointments_screen.dart';

class DashboardScreen extends StatelessWidget {
  final String name;
  final String role;

  const DashboardScreen({
    super.key,
    required this.name,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF176B87);
    final bool isPatient = role == 'patient';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Appointment'),
        backgroundColor: primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
            onPressed: () async {
              try {
                await AuthService().logout();

                if (!context.mounted) return;

                Navigator.of(context).popUntil(
                      (route) => route.isFirst,
                );
              } catch (e) {
                if (!context.mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Logout failed: $e'),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello, $name!',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF17324D),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isPatient
                    ? 'Welcome to your patient dashboard.'
                    : 'Welcome to your doctor dashboard.',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 28),

              // Welcome card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFDDF3F7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      isPatient
                          ? Icons.health_and_safety_rounded
                          : Icons.medical_services_rounded,
                      size: 48,
                      color: primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      isPatient
                          ? 'Your Health Matters'
                          : 'Manage Your Practice',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isPatient
                          ? 'Find doctors and manage your appointments.'
                          : 'Manage your availability and appointments.',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              const Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              if (isPatient) ...[
                _buildAction(
                  icon: Icons.search,
                  title: 'Find Doctors',
                  subtitle: 'Explore doctors by specialization',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const FindDoctorsScreen(),
                      ),
                    );
                  },
                ),
                _buildAction(
                  icon: Icons.calendar_month,
                  title: 'My Appointments',
                  subtitle: 'View upcoming and past appointments',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const MyAppointmentsScreen(),
                      ),
                    );
                  },
                ),
              ] else ...[
                _buildAction(
                  icon: Icons.event_available,
                  title: 'My Availability',
                  subtitle: 'Manage available time slots',
                  onTap: () {
                    _showComingSoon(context, 'My Availability');
                  },
                ),

                _buildAction(
                  icon: Icons.people_outline,
                  title: 'Patient Appointments',
                  subtitle: 'View and manage bookings',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const DoctorAppointmentsScreen(),
                      ),
                    );
                  },
                ),

              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAction({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: onTap,
        leading: Icon(
          icon,
          color: const Color(0xFF176B87),
          size: 30,
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature feature is coming soon.'),
      ),
    );
  }
}
