
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DoctorAvailabilityScreen extends StatefulWidget {
  const DoctorAvailabilityScreen({super.key});

  @override
  State<DoctorAvailabilityScreen> createState() =>
      _DoctorAvailabilityScreenState();
}

class _DoctorAvailabilityScreenState
    extends State<DoctorAvailabilityScreen> {
  static const Color primary = Color(0xFF176B87);

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _specialization = TextEditingController();
  final _qualification = TextEditingController();
  final _experience = TextEditingController();
  final _fee = TextEditingController();
  final _bio = TextEditingController();

  String? _doctorId;
  String _approvalStatus = 'pending';
  bool _available = false;
  bool _loading = true;
  bool _saving = false;
  bool _updatingAvailability = false;

  @override
  void initState() {
    super.initState();
    _loadDoctor();
  }

  @override
  void dispose() {
    _name.dispose();
    _specialization.dispose();
    _qualification.dispose();
    _experience.dispose();
    _fee.dispose();
    _bio.dispose();
    super.dispose();
  }

  void _message(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  String _numberText(dynamic value) {
    if (value == null) return '0';
    return value.toString().trim().isEmpty ? '0' : value.toString();
  }

  Future<void> _loadDoctor() async {
    final user = _auth.currentUser;

    if (user == null) {
      if (mounted) {
        setState(() => _loading = false);
        _message('Please log in again.');
      }
      return;
    }

    try {
      // First, find a doctor record owned by this account.
      final result = await _db
          .collection('doctors')
          .where('ownerUid', isEqualTo: user.uid)
          .limit(1)
          .get();

      DocumentSnapshot<Map<String, dynamic>>? doctor;

      if (result.docs.isNotEmpty) {
        doctor = result.docs.first;
      } else {
        // Support records whose document ID is the user's UID.
        final fallback =
        await _db.collection('doctors').doc(user.uid).get();

        if (fallback.exists) {
          doctor = fallback;
        }
      }

      if (doctor == null || !doctor.exists) {
        throw Exception(
          'No doctor profile is linked to this account.',
        );
      }

      final data = doctor.data()!;

      if (!mounted) return;

      setState(() {
        _doctorId = doctor!.id;
        _name.text = data['name']?.toString() ?? '';
        _specialization.text =
            data['specialization']?.toString() ?? '';
        _qualification.text =
            data['qualification']?.toString() ?? '';
        _experience.text = _numberText(data['experience']);
        _fee.text = _numberText(data['consultationFee']);
        _bio.text = data['bio']?.toString() ?? '';
        _available = data['available'] == true;
        _approvalStatus =
            data['approvalStatus']?.toString() ?? 'pending';
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      _message('Failed to load doctor profile: $e');
    }
  }

  Future<void> _changeAvailability(bool value) async {
    final id = _doctorId;

    if (id == null) {
      _message('Doctor profile not loaded.');
      return;
    }

    setState(() => _updatingAvailability = true);

    try {
      await _db.collection('doctors').doc(id).update({
        'available': value,
      });

      if (!mounted) return;

      setState(() => _available = value);

      _message(
        value
            ? 'Availability switched on.'
            : 'Availability switched off.',
      );
    } catch (e) {
      if (!mounted) return;
      _message('Could not update availability: $e');
    } finally {
      if (mounted) {
        setState(() => _updatingAvailability = false);
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final id = _doctorId;
    if (id == null) {
      _message('Doctor profile not loaded.');
      return;
    }

    final years = int.tryParse(_experience.text.trim());
    final fee = double.tryParse(_fee.text.trim());

    if (years == null || fee == null) {
      _message('Enter valid experience and consultation fee.');
      return;
    }

    setState(() => _saving = true);

    try {
      await _db.collection('doctors').doc(id).update({
        'name': _name.text.trim(),
        'specialization': _specialization.text.trim(),
        'qualification': _qualification.text.trim(),
        'experience': years,
        'consultationFee': fee,
        'bio': _bio.text.trim(),
      });

      if (!mounted) return;
      _message('Profile saved successfully.');
    } catch (e) {
      if (!mounted) return;
      _message('Could not save profile: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: primary),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile & Availability'),
        backgroundColor: primary,
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _doctorId == null
          ? Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Doctor profile not found.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  setState(() => _loading = true);
                  _loadDoctor();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      )
          : ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text(
                    'Accept New Appointments',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    _available
                        ? 'Availability is ON'
                        : 'Availability is OFF',
                  ),
                  value: _available,
                  onChanged: _updatingAvailability
                      ? null
                      : _changeAvailability,
                ),
                if (_updatingAvailability)
                  const LinearProgressIndicator(),
                const Divider(),
                ListTile(
                  title: const Text('Admin Approval'),
                  subtitle: Text(
                    _approvalStatus.toUpperCase(),
                  ),
                  leading: Icon(
                    _approvalStatus == 'approved'
                        ? Icons.verified
                        : Icons.pending_actions,
                    color: _approvalStatus == 'approved'
                        ? Colors.green
                        : Colors.orange,
                  ),
                ),
                if (_approvalStatus != 'approved')
                  const Padding(
                    padding: EdgeInsets.all(12),
                    child: Text(
                      'Patients cannot book appointments '
                          'until an admin approves your profile.',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Edit Doctor Profile',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Form(
            key: _formKey,
            child: Column(
              children: [
                _field(
                  controller: _name,
                  label: 'Full Name',
                  icon: Icons.person,
                  validator: (v) =>
                  v == null || v.trim().isEmpty
                      ? 'Enter your name'
                      : null,
                ),
                _field(
                  controller: _specialization,
                  label: 'Specialization',
                  icon: Icons.medical_services,
                  validator: (v) =>
                  v == null || v.trim().isEmpty
                      ? 'Enter specialization'
                      : null,
                ),
                _field(
                  controller: _qualification,
                  label: 'Qualification',
                  icon: Icons.school,
                  validator: (v) =>
                  v == null || v.trim().isEmpty
                      ? 'Enter qualification'
                      : null,
                ),
                _field(
                  controller: _experience,
                  label: 'Experience (years)',
                  icon: Icons.work,
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    final n =
                    int.tryParse(v?.trim() ?? '');
                    return n == null || n < 0
                        ? 'Enter valid years'
                        : null;
                  },
                ),
                _field(
                  controller: _fee,
                  label: 'Consultation Fee',
                  icon: Icons.currency_rupee,
                  keyboardType:
                  const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: (v) {
                    final n =
                    double.tryParse(v?.trim() ?? '');
                    return n == null || n < 0
                        ? 'Enter a valid fee'
                        : null;
                  },
                ),
                _field(
                  controller: _bio,
                  label: 'About You',
                  icon: Icons.description,
                  maxLines: 4,
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed:
                    _saving || _updatingAvailability
                        ? null
                        : _saveProfile,
                    icon: const Icon(Icons.save),
                    label: Text(
                      _saving
                          ? 'Saving...'
                          : 'Save Profile',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
