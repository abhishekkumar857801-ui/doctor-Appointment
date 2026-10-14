
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AdminDashboardScreen extends StatelessWidget {
  final String name;

  const AdminDashboardScreen({
    super.key,
    required this.name,
  });

  Future<void> _logout(BuildContext context) async {
    await AuthService().logout();

    if (!context.mounted) return;

    Navigator.of(context).pushNamedAndRemoveUntil(
      '/',
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF176B87);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Welcome, $name!',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text('Manage your appointment system.'),
          const SizedBox(height: 24),
          _adminCard(
            Icons.people_outline,
            'Manage Users',
            'View registered users',
          ),
          _adminCard(
            Icons.medical_services_outlined,
            'Manage Doctors',
            'Review doctor profiles',
          ),
          _adminCard(
            Icons.calendar_month,
            'Manage Appointments',
            'View appointment records',
          ),
        ],
      ),
    );
  }

  Widget _adminCard(
      IconData icon,
      String title,
      String subtitle,
      ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: Icon(
          icon,
          color: const Color(0xFF176B87),
          size: 30,
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

