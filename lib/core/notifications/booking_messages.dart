import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../../features/bookings/booking_presenter.dart';
import '../../features/bookings/data/travel_booking.dart';

/// Support contact shown in customer-facing messages.
/// Editable in Firestore at settings/support (fields: phone, email) so
/// contact details can change without an app release.
class SupportDetails {
  const SupportDetails({required this.phone, required this.email});
  final String phone;
  final String email;

  static const fallback = SupportDetails(
      phone: '+267 71 000 000', email: 'support@travel365.co.bw');
  static SupportDetails? _cached;

  static Future<SupportDetails> load() async {
    if (_cached != null) return _cached!;
    try {
      final doc = await FirebaseFirestore.instance
          .collection('settings')
          .doc('support')
          .get();
      final data = doc.data() ?? const <String, dynamic>{};
      final phone = data['phone']?.toString().trim() ?? '';
      final email = data['email']?.toString().trim() ?? '';
      _cached = SupportDetails(
          phone: phone.isNotEmpty ? phone : fallback.phone,
          email: email.isNotEmpty ? email : fallback.email);
      return _cached!;
    } catch (_) {
      return fallback;
    }
  }
}

/// Single source for booking message text so WhatsApp, share, push and
/// email wording stay aligned. Every message keeps the booking reference,
/// destination, status, and support details visible.
class BookingMessages {
  const BookingMessages._();

  static String reference(String bookingId) =>
      bookingId.substring(0, bookingId.length.clamp(0, 8)).toUpperCase();

  static String _dates(TravelBooking booking) {
    final format = DateFormat('dd MMM yyyy');
    return '${format.format(booking.departureDate)} – ${format.format(booking.returnDate)}';
  }

  static String _supportLine(SupportDetails support) =>
      'Questions? Call ${support.phone} or email ${support.email}.';

  /// Owner/staff manually contacting the customer about their booking.
  static String ownerToCustomer(TravelBooking booking, SupportDetails support) {
    final status = bookingStatusLabel(booking.normalizedStatus);
    final lines = <String>[
      'Hello ${booking.fullName}, this is Travel365 about your booking ${reference(booking.id)} to ${booking.destination}.',
      'Status: $status.',
      if (booking.normalizedStatus == 'declined' &&
          booking.declineReason.isNotEmpty)
        'Reason: ${booking.declineReason}',
      if (booking.ownerResponse.isNotEmpty) booking.ownerResponse,
      _supportLine(support),
    ];
    return lines.join('\n');
  }

  /// Customer sharing their booking summary (receipt-style) on WhatsApp.
  static String customerShare(TravelBooking booking, SupportDetails support) {
    final lines = <String>[
      'Travel365 booking ${reference(booking.id)}',
      'Destination: ${booking.departureCity} → ${booking.destination}',
      'Dates: ${_dates(booking)}',
      'Travellers: ${booking.adults} adult(s), ${booking.children} child(ren)',
      'Status: ${bookingStatusLabel(booking.normalizedStatus)}',
      _supportLine(support),
    ];
    return lines.join('\n');
  }
}
