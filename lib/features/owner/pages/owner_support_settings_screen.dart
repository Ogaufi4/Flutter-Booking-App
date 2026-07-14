import 'package:booking_app/resources/themes/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// Edits the two owner-configurable contact documents:
///
/// * settings/support -- the phone and email customers SEE in every booking
///   notification.
/// * settings/company -- where owner alerts are SENT (admin email and the
///   WhatsApp number that receives new-booking alerts).
///
/// Both are restricted to owner/staff by firestore.rules.
class OwnerSupportSettingsScreen extends StatefulWidget {
  const OwnerSupportSettingsScreen({Key? key}) : super(key: key);
  @override
  State<OwnerSupportSettingsScreen> createState() =>
      _OwnerSupportSettingsScreenState();
}

class _OwnerSupportSettingsScreenState
    extends State<OwnerSupportSettingsScreen> {
  static final _settings = FirebaseFirestore.instance.collection('settings');
  static final _support = _settings.doc('support');
  static final _company = _settings.doc('company');

  final _formKey = GlobalKey<FormState>();
  final _supportPhone = TextEditingController();
  final _supportEmail = TextEditingController();
  final _adminWhatsapp = TextEditingController();
  final _adminEmail = TextEditingController();

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
    _supportPhone.dispose();
    _supportEmail.dispose();
    _adminWhatsapp.dispose();
    _adminEmail.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final results = await Future.wait([_support.get(), _company.get()]);
      final support = results[0].data();
      final company = results[1].data();
      _supportPhone.text = (support?['phone'] as String?) ?? '';
      _supportEmail.text = (support?['email'] as String?) ?? '';
      _adminWhatsapp.text = (company?['adminWhatsapp'] as String?) ?? '';
      _adminEmail.text = (company?['adminEmail'] as String?) ?? '';
    } catch (error) {
      _loadError = error.toString();
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final batch = FirebaseFirestore.instance.batch();
      batch.set(
          _support,
          {
            'phone': _supportPhone.text.trim(),
            'email': _supportEmail.text.trim(),
            'updatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true));
      batch.set(
          _company,
          {
            'adminWhatsapp': _adminWhatsapp.text.trim(),
            'adminEmail': _adminEmail.text.trim(),
            'updatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true));
      await batch.commit();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Contact settings updated for new bookings')));
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

  Widget _sectionTitle(String title, String description) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(description,
              style: TextStyle(color: OwnTheme.colorPalette['gray'])),
          const SizedBox(height: 14),
        ],
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contact settings')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle(
                      'Shown to customers',
                      'Included in every booking email and notification the '
                          'customer receives. Leave a field empty to hide it.',
                    ),
                    TextFormField(
                      controller: _supportPhone,
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
                      controller: _supportEmail,
                      keyboardType: TextInputType.emailAddress,
                      validator: _validateEmail,
                      decoration: const InputDecoration(
                        labelText: 'Support email',
                        hintText: 'support@travel365.co.bw',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.mail_outline),
                      ),
                    ),
                    const SizedBox(height: 32),
                    _sectionTitle(
                      'Owner alerts',
                      'Where new-booking and cancellation alerts are sent. '
                          'Customers never see these. Leave the WhatsApp number '
                          'empty to use the default (72425104).',
                    ),
                    TextFormField(
                      controller: _adminWhatsapp,
                      keyboardType: TextInputType.phone,
                      validator: _validatePhone,
                      decoration: const InputDecoration(
                        labelText: 'Owner WhatsApp number',
                        hintText: '72425104',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.chat_outlined),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _adminEmail,
                      keyboardType: TextInputType.emailAddress,
                      validator: _validateEmail,
                      decoration: const InputDecoration(
                        labelText: 'Owner alert email',
                        hintText: 'bookings@travel365.co.bw',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.alternate_email),
                      ),
                    ),
                    if (_loadError != null) ...[
                      const SizedBox(height: 16),
                      Text('Could not load current settings: $_loadError',
                          style: const TextStyle(color: Colors.red)),
                    ],
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _saving ? null : _save,
                        icon: _saving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2))
                            : const Icon(Icons.save_outlined),
                        label: Text(_saving ? 'Saving...' : 'Save settings'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
