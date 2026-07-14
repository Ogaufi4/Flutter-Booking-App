import 'package:booking_app/data/models/basic_model.dart';
import 'package:booking_app/features/bookings/data/booking_repository.dart';
import 'package:booking_app/resources/buttonkey/button.dart';
import 'package:booking_app/resources/themes/theme.dart';
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
    } on FirebaseException catch (error) {
      _showMessage(
        error.code == 'permission-denied'
            ? 'Firestore permissions blocked this booking. Update the bookings security rules.'
            : 'Could not save booking. Please try again.',
      );
    } catch (error) {
      _showMessage(error.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy');
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Book a Trip',
          style: TextStyle(
            color: OwnTheme.colorPalette['secondary'],
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 36),
          children: [
            Text(
              'Tell us where you want to go',
              style: TextStyle(
                color: OwnTheme.colorPalette['secondary'],
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Travel365 will review your booking and contact you with the next steps.',
              style:
                  TextStyle(color: OwnTheme.colorPalette['gray'], height: 1.5),
            ),
            const SizedBox(height: 26),
            const FormLabel('Service'),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _serviceType,
              items: services.entries
                  .map((entry) => DropdownMenuItem(
                      value: entry.key, child: Text(entry.value)))
                  .toList(),
              onChanged: (value) =>
                  setState(() => _serviceType = value ?? 'custom_trip'),
            ),
            const SizedBox(height: 18),
            FormLabel('Destination'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _destination,
              decoration: const InputDecoration(
                  hintText: 'e.g. Namibia, Dubai or Paris'),
              validator: requiredValidator,
            ),
            const SizedBox(height: 18),
            const FormLabel('Departure city'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _departureCity,
              decoration: const InputDecoration(hintText: 'e.g. Gaborone'),
              validator: requiredValidator,
            ),
            const SizedBox(height: 18),
            Row(children: [
              Expanded(
                child: DateField(
                  label: 'Departure',
                  value: _departureDate == null
                      ? 'Select date'
                      : dateFormat.format(_departureDate!),
                  onTap: () => _pickDate(true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DateField(
                  label: 'Return',
                  value: _returnDate == null
                      ? 'Select date'
                      : dateFormat.format(_returnDate!),
                  onTap: () => _pickDate(false),
                ),
              ),
            ]),
            const SizedBox(height: 22),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: OwnTheme.colorPalette['surfaceAlt'],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: OwnTheme.colorPalette['border']!),
              ),
              child: Column(children: [
                TravellerCounter(
                  label: 'Adults',
                  value: _adults,
                  onMinus: _adults > 1 ? () => setState(() => _adults--) : null,
                  onPlus: () => setState(() => _adults++),
                ),
                Divider(color: OwnTheme.colorPalette['border']),
                TravellerCounter(
                  label: 'Children',
                  value: _children,
                  onMinus:
                      _children > 0 ? () => setState(() => _children--) : null,
                  onPlus: () => setState(() => _children++),
                ),
              ]),
            ),
            const SizedBox(height: 24),
            const FormLabel('Contact details'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Full name'),
              validator: requiredValidator,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email'),
              validator: (value) {
                if (value == null || !value.contains('@'))
                  return 'Enter a valid email.';
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phone,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Phone number'),
              validator: requiredValidator,
            ),
            const SizedBox(height: 18),
            const FormLabel('Notes (optional)'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _notes,
              minLines: 3,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText:
                    'Airline, hotel, room, budget or accessibility preferences',
              ),
            ),
            const SizedBox(height: 28),
            ButtonKey(
              buttonText: 'Book',
              isLoading: _submitting,
              function: _submitting ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }
}

String? requiredValidator(String? value) {
  if (value == null || value.trim().isEmpty) return 'This field is required.';
  return null;
}

class FormLabel extends StatelessWidget {
  const FormLabel(this.text, {Key? key}) : super(key: key);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: OwnTheme.colorPalette['black'],
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class DateField extends StatelessWidget {
  const DateField({
    Key? key,
    required this.label,
    required this.value,
    required this.onTap,
  }) : super(key: key);

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FormLabel(label),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: OwnTheme.colorPalette['bgGray'],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: OwnTheme.colorPalette['border']!),
            ),
            child: Row(children: [
              Icon(Icons.calendar_today_outlined,
                  size: 18, color: OwnTheme.colorPalette['primary']),
              const SizedBox(width: 8),
              Expanded(
                  child: Text(value,
                      style: TextStyle(color: OwnTheme.colorPalette['black']))),
            ]),
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
    required this.value,
    required this.onMinus,
    required this.onPlus,
  }) : super(key: key);

  final String label;
  final int value;
  final VoidCallback? onMinus;
  final VoidCallback onPlus;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(
        child: Text(
          label,
          style: TextStyle(
              color: OwnTheme.colorPalette['black'],
              fontWeight: FontWeight.w600),
        ),
      ),
      CounterButton(icon: Icons.remove, onTap: onMinus),
      SizedBox(
          width: 42,
          child: Text('$value',
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w700))),
      CounterButton(icon: Icons.add, onTap: onPlus),
    ]);
  }
}

class CounterButton extends StatelessWidget {
  const CounterButton({Key? key, required this.icon, this.onTap})
      : super(key: key);
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      style: IconButton.styleFrom(
        backgroundColor: Colors.white,
        side: BorderSide(color: OwnTheme.colorPalette['border']!),
      ),
      icon: Icon(icon, size: 18),
    );
  }
}
