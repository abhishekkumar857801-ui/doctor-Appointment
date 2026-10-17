
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'admin_doctors_screen.dart';
import 'login_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  final String name;

  const AdminDashboardScreen({
    super.key,
    required this.name,
  });

  static const Color primary = Color(0xFF176B87);
  static const Color background = Color(0xFFF4F8FB);

  static final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

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
        SnackBar(content: Text('Logout failed: $e')),
      );
    }
  }

  void _openCollection(
      BuildContext context,
      String collection,
      String title,
      ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AdminCollectionScreen(
          collection: collection,
          title: title,
        ),
      ),
    );
  }

  Widget _statCard({
    required String title,
    required String collection,
    required IconData icon,
    required Color color,
  }) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _firestore.collection(collection).snapshots(),
      builder: (context, snapshot) {
        final count = snapshot.hasData
            ? snapshot.data!.docs.length
            : 0;

        return Card(
          elevation: 2,
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: color.withValues(alpha: 0.12),
                  child: Icon(icon, color: color),
                ),
                const SizedBox(height: 12),
                Text(
                  '$count',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _menuCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 1,
      color: Colors.white,
      child: ListTile(
        contentPadding: const EdgeInsets.all(14),
        leading: CircleAvatar(
          backgroundColor: primary.withValues(alpha: 0.12),
          child: Icon(icon, color: primary),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            tooltip: 'Logout',
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: primary,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.admin_panel_settings,
                      size: 42,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Welcome, $name!',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Manage doctors, patients and appointments.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'Overview',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              // Statistics
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.35,
                children: [
                  _statCard(
                    title: 'Doctors',
                    collection: 'doctors',
                    icon: Icons.medical_services,
                    color: Colors.blue,
                  ),
                  _statCard(
                    title: 'Patients',
                    collection: 'users',
                    icon: Icons.people,
                    color: Colors.green,
                  ),
                  _statCard(
                    title: 'Appointments',
                    collection: 'appointments',
                    icon: Icons.calendar_month,
                    color: Colors.orange,
                  ),
                  _statCard(
                    title: 'Pending Doctors',
                    collection: 'doctors',
                    icon: Icons.pending_actions,
                    color: Colors.purple,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              const Text(
                'Management',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              _menuCard(
                context: context,
                title: 'Manage Doctors',
                subtitle: 'Review and manage doctor accounts',
                icon: Icons.medical_services_outlined,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const AdminDoctorsScreen(),
                    ),
                  );
                },
              ),

              _menuCard(
                context: context,
                title: 'View Patients',
                subtitle: 'See registered user accounts',
                icon: Icons.people_outline,
                onTap: () => _openCollection(
                  context,
                  'users',
                  'Registered Users',
                ),
              ),

              _menuCard(
                context: context,
                title: 'View Appointments',
                subtitle: 'Review appointment records',
                icon: Icons.calendar_month_outlined,
                onTap: () => _openCollection(
                  context,
                  'appointments',
                  'Appointments',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Reusable screen for viewing Firestore collection records.
class AdminCollectionScreen extends StatelessWidget {
  final String collection;
  final String title;

  const AdminCollectionScreen({
    super.key,
    required this.collection,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminDashboardScreen.background,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: AdminDashboardScreen.primary,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection(collection)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Unable to load records.\n${snapshot.error}',
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
              child: Text('No records found.'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data();

              return Card(
                child: ExpansionTile(
                  title: Text(
                    data['name']?.toString() ??
                        data['doctorName']?.toString() ??
                        doc.id,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text('Document ID: ${doc.id}'),
                  childrenPadding: const EdgeInsets.all(16),
                  children: data.entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              entry.key,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(entry.value.toString()),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
