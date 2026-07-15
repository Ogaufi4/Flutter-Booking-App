import 'package:booking_app/core/theme/app_colors.dart';
import 'package:booking_app/core/theme/app_spacing.dart';
import 'package:booking_app/core/theme/app_typography.dart';
import 'package:booking_app/core/widgets/luxury_button.dart';
import 'package:booking_app/core/widgets/luxury_card.dart';
import 'package:booking_app/core/widgets/luxury_text_field.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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
        SetOptions(merge: true),
      );
      batch.set(
        _company,
        {
          'adminWhatsapp': _adminWhatsapp.text.trim(),
          'adminEmail': _adminEmail.text.trim(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
      await batch.commit();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Contact settings updated for new bookings'),
        ),
      );
      Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not save contact settings.')),
      );
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
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Contact settings')),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : SafeArea(
              top: false,
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screen,
                    16,
                    AppSpacing.screen,
                    32,
                  ),
                  children: [
                    Text('Messaging\ncontacts',
                        style: AppTypography.displayMedium),
                    const SizedBox(height: 12),
                    Text(
                      'Keep customer-facing support details separate from owner alert destinations.',
                      style: AppTypography.bodyMedium,
                    ),
                    const SizedBox(height: 24),
                    _SettingsSection(
                      title: 'Shown to customers',
                      description:
                          'Included in booking emails and notifications. Leave a field empty to hide it.',
                      children: [
                        LuxuryTextField(
                          controller: _supportPhone,
                          label: 'Support phone',
                          hintText: '+267 71 234 567',
                          keyboardType: TextInputType.phone,
                          validator: _validatePhone,
                          prefixIcon: Icons.phone_outlined,
                        ),
                        const SizedBox(height: 16),
                        LuxuryTextField(
                          controller: _supportEmail,
                          label: 'Support email',
                          hintText: 'support@travel365.co.bw',
                          keyboardType: TextInputType.emailAddress,
                          validator: _validateEmail,
                          prefixIcon: Icons.mail_outline,
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    _SettingsSection(
                      title: 'Owner alerts',
                      description:
                          'Where new-booking and cancellation alerts are sent. Customers never see these.',
                      children: [
                        LuxuryTextField(
                          controller: _adminWhatsapp,
                          label: 'Owner WhatsApp number',
                          hintText: '72184392',
                          keyboardType: TextInputType.phone,
                          validator: _validatePhone,
                          prefixIcon: Icons.chat_outlined,
                        ),
                        const SizedBox(height: 16),
                        LuxuryTextField(
                          controller: _adminEmail,
                          label: 'Owner alert email',
                          hintText: 'owner@travel365.co.bw',
                          keyboardType: TextInputType.emailAddress,
                          validator: _validateEmail,
                          prefixIcon: Icons.alternate_email,
                        ),
                      ],
                    ),
                    if (_loadError != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        'Current settings could not be loaded.',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                    ],
                    const SizedBox(height: 26),
                    LuxuryButton(
                      label: _saving ? 'Saving...' : 'Save settings',
                      icon: Icons.save_outlined,
                      isLoading: _saving,
                      onPressed: _saving ? null : _save,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({
    required this.title,
    required this.description,
    required this.children,
  });

  final String title;
  final String description;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LuxuryCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.sectionTitle),
          const SizedBox(height: 6),
          Text(description, style: AppTypography.caption),
          const SizedBox(height: 18),
          ...children,
        ],
      ),
    );
  }
}
