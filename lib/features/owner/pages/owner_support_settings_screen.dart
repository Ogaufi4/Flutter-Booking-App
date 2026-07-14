import 'package:booking_app/resources/themes/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// Edits settings/support, the phone and email the backend appends to every
/// customer booking notification. Writes are restricted to owner/staff by the
/// settings/support rule in firestore.rules.
class OwnerSupportSettingsScreen extends StatefulWidget {
  const OwnerSupportSettingsScreen({Key? key}) : super(key: key);
  @override
  State<OwnerSupportSettingsScreen> createState() =>
      _OwnerSupportSettingsScreenState();
}

class _OwnerSupportSettingsScreenState
    extends State<OwnerSupportSettingsScreen> {
  static final _document =
      FirebaseFirestore.instance.collection('settings').doc('support');

  final _formKey = GlobalKey<FormState>();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  bool _loading = true;
  bool _saving = false;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _phone.dispose();
    _email.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final snapshot = await _document.get();
      final data = snapshot.data();
      _phone.text = (data?['phone'] as String?) ?? '';
      _email.text = (data?['email'] as String?) ?? '';
    } catch (error) {
      _loadError = error.toString();
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await _document.set({
        'phone': _phone.text.trim(),
        'email': _email.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Support contact updated for new notifications')));
      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Could not save: $error')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String? _validateEmail(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null;
    final valid = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(text);
    return valid ? null : 'Enter a valid email address';
  }

  String? _validatePhone(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null;
    final valid = RegExp(r'^\+?[\d\s-]{6,}$').hasMatch(text);
    return valid ? null : 'Enter a valid phone number';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Support contact')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Customers see these details in every booking email and '
                      'notification. Leave a field empty to hide it.',
                      style: TextStyle(color: OwnTheme.colorPalette['gray']),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _phone,
                      keyboardType: TextInputType.phone,
                      validator: _validatePhone,
                      decoration: const InputDecoration(
                        labelText: 'Support phone',
                        hintText: '+267 71 234 567',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.phone_outlined),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      validator: _validateEmail,
                      decoration: const InputDecoration(
                        labelText: 'Support email',
                        hintText: 'support@travel365.co.bw',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.mail_outline),
                      ),
                    ),
                    if (_loadError != null) ...[
                      const SizedBox(height: 16),
                      Text('Could not load current contact: $_loadError',
                          style: const TextStyle(color: Colors.red)),
                    ],
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _saving ? null : _save,
                        icon: _saving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2))
                            : const Icon(Icons.save_outlined),
                        label: Text(_saving ? 'Saving...' : 'Save contact'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
