import 'package:booking_app/core/theme/app_colors.dart';
import 'package:booking_app/core/theme/app_radius.dart';
import 'package:booking_app/core/theme/app_spacing.dart';
import 'package:booking_app/core/theme/app_typography.dart';
import 'package:booking_app/core/widgets/luxury_button.dart';
import 'package:booking_app/core/widgets/luxury_card.dart';
import 'package:booking_app/core/widgets/luxury_text_field.dart';
import 'package:booking_app/data/models/basic_model.dart';
import 'package:booking_app/features/bookings/data/booking_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BookTripScreen extends StatefulWidget {
  const BookTripScreen({
    Key? key,
    this.initialDestination = '',
    this.initialService = 'custom_trip',
  }) : super(key: key);

  final String initialDestination;
  final String initialService;

  @override
  State<BookTripScreen> createState() => _BookTripScreenState();
}

class _BookTripScreenState extends State<BookTripScreen> {
  final _formKey = GlobalKey<FormState>();
  final _repository = BookingRepository();
  late final TextEditingController _name;
  late final TextEditingController _email;
  final _phone = TextEditingController();
  final _departureCity = TextEditingController(text: 'Gaborone');
  late final TextEditingController _destination;
  final _notes = TextEditingController();

  late String _serviceType;
  DateTime? _departureDate;
  DateTime? _returnDate;
  int _adults = 1;
  int _children = 0;
  bool _submitting = false;

  static const services = <String, String>{
    'custom_trip': 'Complete trip',
    'flight': 'Flight',
    'accommodation': 'Hotel or lodge',
    'car_rental': 'Car rental',
    'holiday_package': 'Holiday package',
    'corporate_travel': 'Corporate travel',
    'group_travel': 'Group travel',
    'tour': 'Tour or activity',
    'insurance': 'Travel insurance',
    'visa_assistance': 'Visa assistance',
  };

  @override
  void initState() {
    super.initState();
    final firebaseUser = FirebaseAuth.instance.currentUser;
    _name = TextEditingController(
      text: firebaseUser?.displayName ??
          (BasicModel.name.isNotEmpty ? BasicModel.name : 'Travel365 Demo'),
    );
    _email = TextEditingController(
      text: firebaseUser?.email ??
          (BasicModel.userToken == 'demo-token' ? 'demo@travel365.com' : ''),
    );
    _destination = TextEditingController(text: widget.initialDestination);
    _serviceType = services.containsKey(widget.initialService)
        ? widget.initialService
        : 'custom_trip';
    _loadReceiptDefaults();
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _departureCity.dispose();
    _destination.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool departure) async {
    final firstDate =
        departure ? DateTime.now() : (_departureDate ?? DateTime.now());
    final initialDate = departure
        ? (_departureDate ?? DateTime.now().add(const Duration(days: 7)))
        : (_returnDate ?? firstDate.add(const Duration(days: 3)));
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(firstDate.year, firstDate.month, firstDate.day),
      lastDate: DateTime.now().add(const Duration(days: 730)),
      initialDate: initialDate.isBefore(firstDate) ? firstDate : initialDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppColors.primary,
                  secondary: AppColors.accent,
                ),
          ),
          child: child!,
        );
      },
    );
    if (picked == null) return;
    setState(() {
      if (departure) {
        _departureDate = picked;
        if (_returnDate != null && _returnDate!.isBefore(picked)) {
          _returnDate = null;
        }
      } else {
        _returnDate = picked;
      }
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_departureDate == null || _returnDate == null) {
      _showMessage('Select departure and return dates.');
      return;
    }

    setState(() => _submitting = true);
    try {
      await _saveReceiptDefaults();
      await _repository.createBooking(
        serviceType: _serviceType,
        fullName: _name.text,
        email: _email.text,
        phone: _phone.text,
        departureCity: _departureCity.text,
        destination: _destination.text,
        departureDate: _departureDate!,
        returnDate: _returnDate!,
        adults: _adults,
        children: _children,
        notes: _notes.text,
      );
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Booking submitted'),
          content: const Text(
            'Travel365 has received your booking. You can follow its status under My Bookings.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Done'),
            ),
          ],
        ),
      );
      if (mounted) Navigator.pop(context, true);
    } catch (_) {
      _showMessage(
          'We could not submit your booking right now. Please try again.');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _loadReceiptDefaults() async {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) return;
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(firebaseUser.uid)
          .get();
      final data = snapshot.data();
      if (data == null || !mounted) return;
      final savedEmail = data['notificationEmail']?.toString().trim() ?? '';
      final savedPhone = data['notificationWhatsapp']?.toString().trim() ??
          data['phone']?.toString().trim() ??
          '';
      setState(() {
        if (savedEmail.isNotEmpty) _email.text = savedEmail;
        if (savedPhone.isNotEmpty) _phone.text = savedPhone;
      });
    } catch (_) {
      // Receipt defaults are a convenience; booking should still work.
    }
  }

  Future<void> _saveReceiptDefaults() async {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) return;
    try {
      final ref =
          FirebaseFirestore.instance.collection('users').doc(firebaseUser.uid);
      final snapshot = await ref.get();
      final payload = <String, Object?>{
        'notificationEmail': _email.text.trim().toLowerCase(),
        'notificationWhatsapp': _phone.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (!snapshot.exists) {
        payload.addAll({
          'role': 'customer',
          'name': _name.text.trim(),
          'email': _email.text.trim().toLowerCase(),
        });
      }
      await ref.set(payload, SetOptions(merge: true));
    } catch (_) {
      // A preferences write must never block a booking receipt.
    }
  }

  @override
  Widget build(BuildContext context) {
    final keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
    final horizontal = MediaQuery.of(context).size.width < 360
        ? AppSpacing.screenSmall
        : AppSpacing.screen;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text('Book a Trip'),
      ),
      bottomNavigationBar: keyboardOpen
          ? null
          : SafeArea(
              minimum: EdgeInsets.fromLTRB(horizontal, 10, horizontal, 18),
              child: LuxuryButton(
                label: 'Continue',
                isLoading: _submitting,
                onPressed: _submitting ? null : _submit,
              ),
            ),
      body: SafeArea(
        top: false,
        child: Form(
          key: _formKey,
          child: ListView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.fromLTRB(
              horizontal,
              18,
              horizontal,
              keyboardOpen ? 28 : 96,
            ),
            children: [
              Text('Tell us where\nyou want to go',
                  style: AppTypography.displayLarge),
              const SizedBox(height: 12),
              Text(
                'Travel365 will review your booking and contact you with the next steps.',
                style: AppTypography.bodyMedium,
              ),
              const SizedBox(height: 28),
              _FormSection(
                title: 'Trip details',
                children: [
                  _ServiceDropdown(
                    value: _serviceType,
                    services: services,
                    onChanged: (value) =>
                        setState(() => _serviceType = value ?? 'custom_trip'),
                  ),
                  const SizedBox(height: 16),
                  LuxuryTextField(
                    controller: _destination,
                    label: 'Destination',
                    hintText: 'Cape Town City',
                    validator: requiredValidator,
                  ),
                  const SizedBox(height: 16),
                  LuxuryTextField(
                    controller: _departureCity,
                    label: 'Departure city',
                    hintText: 'Gaborone',
                    validator: requiredValidator,
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _FormSection(
                title: 'Dates',
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final narrow = constraints.maxWidth < 330;
                      final fields = [
                        Expanded(
                          child: _DateSelector(
                            label: 'Departure',
                            value: _departureDate,
                            onTap: () => _pickDate(true),
                          ),
                        ),
                        SizedBox(
                            width: narrow ? 0 : 12, height: narrow ? 12 : 0),
                        Expanded(
                          child: _DateSelector(
                            label: 'Return',
                            value: _returnDate,
                            onTap: () => _pickDate(false),
                          ),
                        ),
                      ];
                      if (narrow) {
                        return Column(
                          children: fields
                              .map(
                                (child) => child is Expanded
                                    ? SizedBox(
                                        width: double.infinity,
                                        child: child.child)
                                    : child,
                              )
                              .toList(),
                        );
                      }
                      return Row(children: fields);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _FormSection(
                title: 'Travellers',
                children: [
                  TravellerCounter(
                    label: 'Adults',
                    helper: 'Age 13 and above',
                    value: _adults,
                    onMinus:
                        _adults > 1 ? () => setState(() => _adults--) : null,
                    onPlus: () => setState(() => _adults++),
                  ),
                  const Divider(height: 26, color: AppColors.divider),
                  TravellerCounter(
                    label: 'Children',
                    helper: 'Age 12 and below',
                    value: _children,
                    onMinus: _children > 0
                        ? () => setState(() => _children--)
                        : null,
                    onPlus: () => setState(() => _children++),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _FormSection(
                title: 'Contact details',
                children: [
                  LuxuryTextField(
                    controller: _name,
                    label: 'Full name',
                    validator: requiredValidator,
                  ),
                  const SizedBox(height: 16),
                  LuxuryTextField(
                    controller: _email,
                    label: 'Email',
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || !value.contains('@')) {
                        return 'Enter a valid email.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  LuxuryTextField(
                    controller: _phone,
                    label: 'Phone number',
                    keyboardType: TextInputType.phone,
                    validator: requiredValidator,
                  ),
                  const SizedBox(height: 16),
                  LuxuryTextField(
                    controller: _notes,
                    label: 'Special request',
                    hintText:
                        'Airline, hotel, budget or accessibility preferences',
                    minLines: 3,
                    maxLines: 5,
                  ),
                ],
              ),
              if (keyboardOpen) ...[
                const SizedBox(height: 24),
                LuxuryButton(
                  label: 'Continue',
                  isLoading: _submitting,
                  onPressed: _submitting ? null : _submit,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

String? requiredValidator(String? value) {
  if (value == null || value.trim().isEmpty) return 'This field is required.';
  return null;
}

class _FormSection extends StatelessWidget {
  const _FormSection({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LuxuryCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.sectionTitle),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}

class _ServiceDropdown extends StatelessWidget {
  const _ServiceDropdown({
    required this.value,
    required this.services,
    required this.onChanged,
  });

  final String value;
  final Map<String, String> services;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Service', style: AppTypography.label),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: value,
          isExpanded: true,
          decoration: const InputDecoration(),
          items: services.entries
              .map(
                (entry) => DropdownMenuItem(
                  value: entry.key,
                  child: Text(
                    entry.value,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _DateSelector extends StatelessWidget {
  const _DateSelector({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final DateTime? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = value == null
        ? 'Select date'
        : DateFormat('dd MMM yyyy').format(value!);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.label),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.medium),
          child: Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.medium),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_outlined,
                    size: 18, color: AppColors.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    text,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.caption.copyWith(
                      color: value == null
                          ? AppColors.textMuted
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class TravellerCounter extends StatelessWidget {
  const TravellerCounter({
    Key? key,
    required this.label,
    required this.helper,
    required this.value,
    required this.onMinus,
    required this.onPlus,
  }) : super(key: key);

  final String label;
  final String helper;
  final int value;
  final VoidCallback? onMinus;
  final VoidCallback onPlus;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTypography.label),
              const SizedBox(height: 3),
              Text(helper, style: AppTypography.caption),
            ],
          ),
        ),
        _StepperButton(icon: Icons.remove_rounded, onTap: onMinus),
        SizedBox(
          width: 42,
          child: Text(
            '$value',
            textAlign: TextAlign.center,
            style: AppTypography.label,
          ),
        ),
        _StepperButton(icon: Icons.add_rounded, onTap: onPlus),
      ],
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({required this.icon, this.onTap});
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      customBorder: const CircleBorder(),
      onTap: onTap,
      child: Opacity(
        opacity: onTap == null ? 0.38 : 1,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.surface,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.border),
          ),
          child: Icon(icon, size: 18, color: AppColors.primary),
        ),
      ),
    );
  }
}
