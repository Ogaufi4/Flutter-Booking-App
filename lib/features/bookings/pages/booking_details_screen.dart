import 'package:booking_app/core/notifications/booking_messages.dart';
import 'package:booking_app/core/notifications/whatsapp_launcher.dart';
import 'package:booking_app/features/auth/role_service.dart';
import 'package:booking_app/features/bookings/booking_presenter.dart';
import 'package:booking_app/features/bookings/data/booking_repository.dart';
import 'package:booking_app/features/bookings/data/travel_booking.dart';
import 'package:booking_app/resources/themes/theme.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class BookingDetailsArgs {
  const BookingDetailsArgs({required this.bookingId, this.ownerMode});
  final String bookingId;
  final bool? ownerMode;
}

class BookingDetailsScreen extends StatefulWidget {
  const BookingDetailsScreen(
      {Key? key, required this.bookingId, this.ownerMode})
      : super(key: key);
  final String bookingId;
  final bool? ownerMode;
  @override
  State<BookingDetailsScreen> createState() => _BookingDetailsScreenState();
}

class _BookingDetailsScreenState extends State<BookingDetailsScreen> {
  final repository = BookingRepository();
  bool busy = false;

  Future<bool> _isOwner() async =>
      widget.ownerMode ?? await const RoleService().canManageBookings;

  Future<void> _transition(TravelBooking booking, String status) async {
    final response = TextEditingController(text: booking.ownerResponse);
    final decline = TextEditingController();
    final accepted = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(status == 'approved'
                  ? 'Approve booking?'
                  : status == 'declined'
                      ? 'Decline booking?'
                      : 'Update booking?'),
              content: Column(mainAxisSize: MainAxisSize.min, children: [
                if (status == 'declined')
                  TextField(
                      controller: decline,
                      minLines: 2,
                      maxLines: 4,
                      decoration: const InputDecoration(
                          labelText: 'Decline reason (required)')),
                if (status != 'declined')
                  TextField(
                      controller: response,
                      minLines: 2,
                      maxLines: 4,
                      decoration: const InputDecoration(
                          labelText: 'Message to customer (optional)')),
              ]),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel')),
                ElevatedButton(
                    onPressed: () {
                      if (status == 'declined' && decline.text.trim().isEmpty)
                        return;
                      Navigator.pop(context, true);
                    },
                    child: Text(status == 'approved'
                        ? 'Approve'
                        : status == 'declined'
                            ? 'Decline'
                            : 'Confirm'))
              ],
            ));
    if (accepted != true) return;
    setState(() => busy = true);
    try {
      await repository.updateBookingStatus(
          bookingId: booking.id,
          status: status,
          ownerResponse: response.text,
          declineReason: decline.text);
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                'Booking marked ${bookingStatusLabel(status).toLowerCase()}.')));
    } catch (error) {
      _error(error);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> _cancel(TravelBooking booking) async {
    final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('Cancel booking?'),
              content: const Text(
                  'Travel365 will be notified. This action cannot be undone.'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Keep booking')),
                ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Cancel booking'))
              ],
            ));
    if (confirmed != true) return;
    setState(() => busy = true);
    try {
      await repository.cancelBooking(booking.id);
    } catch (error) {
      _error(error);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  void _error(Object error) {
    final message = error is FirebaseFunctionsException
        ? error.message ?? error.code
        : error.toString();
    if (mounted)
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _whatsApp(TravelBooking booking, {required bool asOwner}) async {
    final support = await SupportDetails.load();
    final text = asOwner
        ? BookingMessages.ownerToCustomer(booking, support)
        : BookingMessages.customerShare(booking, support);
    final opened = await WhatsAppLauncher.send(
        phone: asOwner ? booking.phone : null, text: text);
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open WhatsApp.')));
    }
  }

  Future<void> _launch(Uri uri) async {
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication) &&
        mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open this app.')));
    }
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<bool>(
        future: _isOwner(),
        builder: (context, roleSnapshot) => StreamBuilder<TravelBooking?>(
          stream: repository.watchBooking(widget.bookingId),
          builder: (context, snapshot) {
            if (!snapshot.hasData)
              return Scaffold(
                  appBar: AppBar(title: const Text('Booking')),
                  body: const Center(child: CircularProgressIndicator()));
            final booking = snapshot.data!;
            final ownerMode = roleSnapshot.data ?? false;
            final format = DateFormat('dd MMM yyyy');
            return Scaffold(
              appBar: AppBar(
                  title: Text(
                      'Booking ${booking.id.substring(0, booking.id.length.clamp(0, 8))}')),
              body: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 36),
                  children: [
                    Row(children: [
                      Expanded(
                          child: Text(booking.destination,
                              style: TextStyle(
                                  color: OwnTheme.colorPalette['secondary'],
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700))),
                      _Status(status: booking.normalizedStatus)
                    ]),
                    const SizedBox(height: 6),
                    Text(bookingServiceLabel(booking.serviceType),
                        style: TextStyle(color: OwnTheme.colorPalette['gray'])),
                    const SizedBox(height: 24),
                    _Section(title: 'Trip details', children: [
                      _Line(Icons.route_outlined,
                          '${booking.departureCity} → ${booking.destination}'),
                      _Line(Icons.calendar_today_outlined,
                          '${format.format(booking.departureDate)} – ${format.format(booking.returnDate)}'),
                      _Line(Icons.people_outline,
                          '${booking.adults} adult(s), ${booking.children} child(ren)'),
                      if (booking.notes.isNotEmpty)
                        _Line(Icons.notes_rounded, booking.notes),
                    ]),
                    const SizedBox(height: 14),
                    _Section(title: 'Traveller', children: [
                      _Line(Icons.person_outline, booking.fullName),
                      _Line(Icons.email_outlined, booking.email),
                      _Line(Icons.phone_outlined, booking.phone)
                    ]),
                    if (booking.ownerResponse.isNotEmpty ||
                        booking.declineReason.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      _Section(title: 'Travel365 response', children: [
                        if (booking.ownerResponse.isNotEmpty)
                          _Line(
                              Icons.chat_bubble_outline, booking.ownerResponse),
                        if (booking.declineReason.isNotEmpty)
                          _Line(Icons.info_outline, booking.declineReason)
                      ]),
                    ],
                    if (ownerMode) ...[
                      const SizedBox(height: 18),
                      Row(children: [
                        Expanded(
                            child: OutlinedButton.icon(
                                onPressed: () => _launch(
                                    Uri(scheme: 'tel', path: booking.phone)),
                                icon: const Icon(Icons.call_outlined),
                                label: const Text('Call'))),
                        const SizedBox(width: 8),
                        Expanded(
                            child: OutlinedButton.icon(
                                onPressed: () => _launch(Uri(
                                        scheme: 'mailto',
                                        path: booking.email,
                                        queryParameters: {
                                          'subject':
                                              'Travel365 booking ${booking.id}'
                                        })),
                                icon: const Icon(Icons.email_outlined),
                                label: const Text('Email'))),
                      ]),
                      const SizedBox(height: 8),
                      SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () =>
                                _whatsApp(booking, asOwner: true),
                            icon: const Icon(Icons.chat_outlined),
                            label: const Text('Message on WhatsApp'),
                          )),
                      const SizedBox(height: 16),
                      if (busy)
                        const Center(child: CircularProgressIndicator())
                      else
                        ..._ownerActions(booking),
                    ] else ...[
                      const SizedBox(height: 22),
                      OutlinedButton.icon(
                          onPressed: () => _whatsApp(booking, asOwner: false),
                          icon: const Icon(Icons.share_outlined),
                          label: const Text('Share on WhatsApp')),
                      if (booking.canCustomerCancel) ...[
                        const SizedBox(height: 8),
                        OutlinedButton.icon(
                            onPressed: busy ? null : () => _cancel(booking),
                            icon: const Icon(Icons.cancel_outlined),
                            label: const Text('Cancel booking')),
                      ],
                    ],
                  ]),
            );
          },
        ),
      );

  List<Widget> _ownerActions(TravelBooking booking) {
    switch (booking.normalizedStatus) {
      case 'new':
        return [
          ElevatedButton(
              onPressed: () => _transition(booking, 'reviewing'),
              child: const Text('Start Review'))
        ];
      case 'reviewing':
        return [
          Row(children: [
            Expanded(
                child: ElevatedButton.icon(
                    onPressed: () => _transition(booking, 'approved'),
                    icon: const Icon(Icons.check),
                    label: const Text('Approve'))),
            const SizedBox(width: 10),
            Expanded(
                child: OutlinedButton.icon(
                    onPressed: () => _transition(booking, 'declined'),
                    icon: const Icon(Icons.close),
                    label: const Text('Decline')))
          ])
        ];
      case 'approved':
        return [
          ElevatedButton(
              onPressed: () => _transition(booking, 'completed'),
              child: const Text('Mark Completed'))
        ];
      default:
        return const [];
    }
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});
  final String title;
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: OwnTheme.colorPalette['border']!)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title,
            style: TextStyle(
                color: OwnTheme.colorPalette['secondary'],
                fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        ...children
      ]));
}

class _Line extends StatelessWidget {
  const _Line(this.icon, this.text);
  final IconData icon;
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, size: 18, color: OwnTheme.colorPalette['primary']),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: const TextStyle(height: 1.35)))
      ]));
}

class _Status extends StatelessWidget {
  const _Status({required this.status});
  final String status;
  @override
  Widget build(BuildContext context) {
    final color = bookingStatusColor(status);
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
            color: color.withOpacity(.1),
            borderRadius: BorderRadius.circular(20)),
        child: Text(bookingStatusLabel(status),
            style: TextStyle(
                color: color, fontSize: 11, fontWeight: FontWeight.w700)));
  }
}
