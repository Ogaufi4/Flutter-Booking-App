import 'package:booking_app/core/notifications/notification_service.dart';
import 'package:booking_app/core/theme/app_colors.dart';
import 'package:booking_app/core/theme/app_radius.dart';
import 'package:booking_app/core/theme/app_spacing.dart';
import 'package:booking_app/core/theme/app_typography.dart';
import 'package:booking_app/core/widgets/luxury_button.dart';
import 'package:booking_app/core/widgets/luxury_card.dart';
import 'package:booking_app/core/widgets/luxury_error_state.dart';
import 'package:booking_app/core/widgets/luxury_loading_skeleton.dart';
import 'package:booking_app/core/widgets/luxury_text_field.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NotificationPreferencesScreen extends StatefulWidget {
  const NotificationPreferencesScreen({Key? key}) : super(key: key);

  @override
  State<NotificationPreferencesScreen> createState() =>
      _NotificationPreferencesScreenState();
}

class _NotificationPreferencesScreenState
    extends State<NotificationPreferencesScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _whatsapp = TextEditingController();

  bool _loading = true;
  bool _loadError = false;
  bool _saving = false;
  bool _pushBusy = false;
  bool _pushEnabled = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _email.dispose();
    _whatsapp.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    if (mounted && (!_loading || _loadError)) {
      setState(() {
        _loading = true;
        _loadError = false;
      });
    }
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    try {
      final results = await Future.wait([
        FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
        NotificationService.instance.currentDeviceEnabled(),
      ]);
      final userDoc = results[0] as DocumentSnapshot<Map<String, dynamic>>;
      final enabled = results[1] as bool;
      final data = userDoc.data();
      _email.text = _text(data?['notificationEmail']) ??
          _text(data?['email']) ??
          user.email ??
          '';
      _whatsapp.text =
          _text(data?['notificationWhatsapp']) ?? _text(data?['phone']) ?? '';
      _pushEnabled = enabled;
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
          _loadError = true;
        });
      }
      return;
    }
    if (mounted) setState(() => _loading = false);
  }

  String? _text(Object? value) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? null : text;
  }

  Future<void> _togglePush(bool value) async {
    setState(() => _pushBusy = true);
    final enabled =
        await NotificationService.instance.setCurrentDeviceEnabled(value);
    if (!mounted) return;
    setState(() {
      _pushEnabled = enabled;
      _pushBusy = false;
    });
    if (value && !enabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Notifications were not allowed on this device.'),
        ),
      );
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in first.')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final ref = FirebaseFirestore.instance.collection('users').doc(user.uid);
      final snapshot = await ref.get();
      final payload = <String, Object?>{
        'notificationEmail': _email.text.trim().toLowerCase(),
        'notificationWhatsapp': _whatsapp.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (!snapshot.exists) {
        payload.addAll({
          'role': 'customer',
          'name': user.displayName ?? 'Travel365 Traveller',
          'email': user.email ?? _email.text.trim().toLowerCase(),
        });
      }
      await ref.set(payload, SetOptions(merge: true));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notification preferences saved.')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not save preferences.')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String? _validateEmail(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Enter an email for booking receipts.';
    final valid = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(text);
    return valid ? null : 'Enter a valid email address.';
  }

  String? _validatePhone(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Enter a WhatsApp number for booking receipts.';
    final valid = RegExp(r'^\+?[\d\s-]{6,}$').hasMatch(text);
    return valid ? null : 'Enter a valid WhatsApp number.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Notifications')),
      body: _loading
          ? const LuxurySkeletonList(count: 3)
          : _loadError
              ? LuxuryErrorState(
                  icon: Icons.cloud_off_outlined,
                  title: 'Preferences unavailable',
                  message:
                      "We couldn't load your notification settings right now. Please check your connection and try again.",
                  onRetry: _load,
                )
              : SafeArea(
              top: false,
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screen,
                    18,
                    AppSpacing.screen,
                    32,
                  ),
                  children: [
                    const Text(
                      'Notifications\nand receipts',
                      style: AppTypography.displayMedium,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Choose how Travel365 reaches you after a booking.',
                      style: AppTypography.bodyMedium,
                    ),
                    const SizedBox(height: 24),
                    LuxuryCard(
                      padding: const EdgeInsets.all(18),
                      child: Row(
                        children: [
                          const _IconBubble(
                              icon: Icons.notifications_active_outlined),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Push alerts',
                                    style: AppTypography.sectionTitle),
                                SizedBox(height: 6),
                                Text(
                                  'Booking updates on this device.',
                                  style: AppTypography.caption,
                                ),
                              ],
                            ),
                          ),
                          _pushBusy
                              ? const SizedBox(
                                  width: 28,
                                  height: 28,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.accent,
                                  ),
                                )
                              : Switch.adaptive(
                                  value: _pushEnabled,
                                  activeThumbColor: AppColors.accent,
                                  onChanged: _togglePush,
                                ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    LuxuryCard(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Receipt defaults',
                              style: AppTypography.sectionTitle),
                          const SizedBox(height: 6),
                          const Text(
                            'These details prefill new booking forms. You can still edit each booking before submitting.',
                            style: AppTypography.caption,
                          ),
                          const SizedBox(height: 18),
                          LuxuryTextField(
                            controller: _email,
                            label: 'Receipt email',
                            hintText: 'you@example.com',
                            keyboardType: TextInputType.emailAddress,
                            validator: _validateEmail,
                            prefixIcon: Icons.mail_outline_rounded,
                          ),
                          const SizedBox(height: 16),
                          LuxuryTextField(
                            controller: _whatsapp,
                            label: 'WhatsApp receipt number',
                            hintText: '+267 74 784 067',
                            keyboardType: TextInputType.phone,
                            validator: _validatePhone,
                            prefixIcon: Icons.chat_outlined,
                          ),
                          const SizedBox(height: 20),
                          LuxuryButton(
                            label: _saving ? 'Saving...' : 'Save preferences',
                            icon: Icons.save_outlined,
                            isLoading: _saving,
                            onPressed: _saving ? null : _save,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    const LuxuryCard(
                      padding: EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('What gets sent',
                              style: AppTypography.sectionTitle),
                          SizedBox(height: 14),
                          _DeliveryRow(
                            icon: Icons.receipt_long_outlined,
                            title: 'Customer receipt',
                            subtitle:
                                'Email plus WhatsApp when a booking is submitted.',
                          ),
                          _DeliveryRow(
                            icon: Icons.admin_panel_settings_outlined,
                            title: 'Owner alert',
                            subtitle:
                                'Email plus WhatsApp to Travel365 for review.',
                          ),
                          _DeliveryRow(
                            icon: Icons.update_rounded,
                            title: 'Status updates',
                            subtitle:
                                'Email and push when bookings are approved, declined or completed.',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _IconBubble extends StatelessWidget {
  const _IconBubble({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.accentSoft,
        borderRadius: BorderRadius.circular(AppRadius.medium),
      ),
      child: Icon(icon, color: AppColors.accent),
    );
  }
}

class _DeliveryRow extends StatelessWidget {
  const _DeliveryRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          _IconBubble(icon: icon),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.label),
                const SizedBox(height: 4),
                Text(subtitle, style: AppTypography.caption),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
