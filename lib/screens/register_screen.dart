
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _specializationController = TextEditingController();
  final _qualificationController = TextEditingController();
  final _experienceController = TextEditingController();
  final _feeController = TextEditingController();
  final _bioController = TextEditingController();

  final AuthService _authService = AuthService();

  String _role = 'patient';
  bool _loading = false;
  bool _hidePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _specializationController.dispose();
    _qualificationController.dispose();
    _experienceController.dispose();
    _feeController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  String? _requiredValidator(String? value, String field) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter $field';
    }
    return null;
  }


  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      await _authService.register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        role: _role,
        specialization: _role == 'doctor'
            ? _specializationController.text
            : null,
        qualification: _role == 'doctor'
            ? _qualificationController.text
            : null,
        experience: _role == 'doctor'
            ? int.tryParse(_experienceController.text.trim())
            : null,
        consultationFee: _role == 'doctor'
            ? double.tryParse(_feeController.text.trim())
            : null,
        bio: _role == 'doctor' ? _bioController.text : null,
      );

      if (!mounted) return;

      await _authService.logout();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registration successful! Please log in.'),
        ),
      );

      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Registration failed: $e'),
          duration: const Duration(seconds: 10),
        ),
      );

      debugPrint('REGISTRATION ERROR: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }


  Widget _textField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
      validator: validator,
    );
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF176B87);

    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.medical_services_rounded,
                    size: 64,
                    color: primary,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Join us today!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 27,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Create an account to manage appointments.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 28),

                  _textField(
                    controller: _nameController,
                    label: 'Full Name',
                    icon: Icons.person_outline,
                    validator: (v) => _requiredValidator(v, 'your name'),
                  ),
                  const SizedBox(height: 16),

                  _textField(
                    controller: _emailController,
                    label: 'Email Address',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null ||
                          !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                              .hasMatch(value.trim())) {
                        return 'Enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _passwordController,
                    obscureText: _hidePassword,
                    decoration: InputDecoration(
                      labelText: 'Password (minimum 6 characters)',
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _hidePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () {
                          setState(() => _hidePassword = !_hidePassword);
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    'Register as',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),

                  DropdownButtonFormField<String>(
                    value: _role,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.badge_outlined),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'patient',
                        child: Text('Patient'),
                      ),
                      DropdownMenuItem(
                        value: 'doctor',
                        child: Text('Doctor'),
                      ),
                    ],
                    onChanged: _loading
                        ? null
                        : (value) {
                      if (value != null) {
                        setState(() => _role = value);
                      }
                    },
                  ),

                  if (_role == 'doctor') ...[
                    const SizedBox(height: 24),
                    const Divider(),
                    const Text(
                      'Professional Details',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    _textField(
                      controller: _specializationController,
                      label: 'Specialization',
                      icon: Icons.medical_information_outlined,
                      validator: (v) =>
                          _requiredValidator(v, 'your specialization'),
                    ),
                    const SizedBox(height: 16),

                    _textField(
                      controller: _qualificationController,
                      label: 'Qualification',
                      icon: Icons.school_outlined,
                      validator: (v) =>
                          _requiredValidator(v, 'your qualification'),
                    ),
                    const SizedBox(height: 16),

                    _textField(
                      controller: _experienceController,
                      label: 'Years of Experience',
                      icon: Icons.work_outline,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        final n = int.tryParse(value?.trim() ?? '');
                        if (n == null || n < 0) {
                          return 'Enter a valid number of years';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    _textField(
                      controller: _feeController,
                      label: 'Consultation Fee',
                      icon: Icons.currency_rupee,
                      keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        final fee = double.tryParse(value?.trim() ?? '');
                        if (fee == null || !fee.isFinite || fee < 0) {
                          return 'Enter a valid consultation fee';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    _textField(
                      controller: _bioController,
                      label: 'About You (optional)',
                      icon: Icons.description_outlined,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 12),

                    const Text(
                      'Your profile will remain unavailable to patients '
                          'until the admin reviews and approves it.',
                      style: TextStyle(color: Colors.deepOrange),
                    ),
                  ],

                  const SizedBox(height: 24),
                  SizedBox(
                    height: 52,
                    child: FilledButton(
                      onPressed: _loading ? null : _register,
                      style: FilledButton.styleFrom(
                        backgroundColor: primary,
                      ),
                      child: _loading
                          ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                          : const Text(
                        'Create Account',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
