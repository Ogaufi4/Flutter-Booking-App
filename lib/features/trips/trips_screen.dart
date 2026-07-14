import 'package:booking_app/features/bookings/booking_presenter.dart';
import 'package:booking_app/features/bookings/data/booking_repository.dart';
import 'package:booking_app/features/bookings/data/travel_booking.dart';
import 'package:booking_app/features/bookings/pages/book_trip_screen.dart';
import 'package:booking_app/features/bookings/pages/booking_details_screen.dart';
import 'package:booking_app/resources/themes/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TripsScreen extends StatelessWidget {
  TripsScreen({Key? key}) : super(key: key);
  final BookingRepository repository = BookingRepository();
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
            title: Text('My Bookings',
                style: TextStyle(
                    color: OwnTheme.colorPalette['secondary'],
                    fontWeight: FontWeight.w700)),
            actions: [
              TextButton.icon(
                  onPressed: () => _book(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Book')),
              const SizedBox(width: 8)
            ]),
        body: StreamBuilder<List<TravelBooking>>(
          stream: repository.watchMyBookings(),
          builder: (context, snapshot) {
            if (snapshot.hasError) return _Error(error: snapshot.error);
            if (!snapshot.hasData)
              return const Center(child: CircularProgressIndicator());
            final bookings = snapshot.data!;
            if (bookings.isEmpty) return _Empty(onBook: () => _book(context));
            return ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                itemCount: bookings.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, i) => _BookingCard(booking: bookings[i]));
          },
        ),
        floatingActionButton: FloatingActionButton(
            onPressed: () => _book(context),
            backgroundColor: OwnTheme.colorPalette['primary'],
            foregroundColor: Colors.white,
            shape: const CircleBorder(),
            child: const Icon(Icons.add_rounded)),
      );
  Future<void> _book(BuildContext context) => Navigator.push(
      context, MaterialPageRoute(builder: (_) => const BookTripScreen()));
}

class _BookingCard extends StatelessWidget {
  const _BookingCard({required this.booking});
  final TravelBooking booking;
  @override
  Widget build(BuildContext context) {
    final color = bookingStatusColor(booking.normalizedStatus);
    return Card(
        child: InkWell(
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => BookingDetailsScreen(
                        bookingId: booking.id, ownerMode: false))),
            child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                                color: const Color(0xFFFFF3EC),
                                borderRadius: BorderRadius.circular(8)),
                            child: Icon(bookingServiceIcon(booking.serviceType),
                                color: OwnTheme.colorPalette['primary'])),
                        const SizedBox(width: 12),
                        Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                              Text(booking.destination,
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700)),
                              Text(bookingServiceLabel(booking.serviceType),
                                  style: TextStyle(
                                      color: OwnTheme.colorPalette['gray']))
                            ])),
                        Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 9, vertical: 5),
                            decoration: BoxDecoration(
                                color: color.withOpacity(.1),
                                borderRadius: BorderRadius.circular(20)),
                            child: Text(
                                bookingStatusLabel(booking.normalizedStatus),
                                style: TextStyle(
                                    color: color,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700)))
                      ]),
                      const SizedBox(height: 14),
                      _line(Icons.route_outlined,
                          '${booking.departureCity} → ${booking.destination}'),
                      const SizedBox(height: 8),
                      _line(Icons.calendar_today_outlined,
                          '${DateFormat('dd MMM yyyy').format(booking.departureDate)} – ${DateFormat('dd MMM yyyy').format(booking.returnDate)}'),
                      if (booking.ownerResponse.isNotEmpty) ...[
                        const Divider(height: 24),
                        Text('Travel365: ${booking.ownerResponse}',
                            style: TextStyle(
                                color: OwnTheme.colorPalette['secondary'],
                                fontWeight: FontWeight.w600))
                      ],
                    ]))));
  }

  Widget _line(IconData icon, String text) => Row(children: [
        Icon(icon, size: 18, color: OwnTheme.colorPalette['secondary']),
        const SizedBox(width: 9),
        Expanded(child: Text(text))
      ]);
}

class _Empty extends StatelessWidget {
  const _Empty({required this.onBook});
  final VoidCallback onBook;
  @override
  Widget build(BuildContext context) => Center(
      child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.luggage_outlined,
                size: 64, color: OwnTheme.colorPalette['secondary']),
            const SizedBox(height: 16),
            const Text('No bookings yet',
                style: TextStyle(fontSize: 21, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text('Choose any destination and submit your travel details.',
                textAlign: TextAlign.center,
                style: TextStyle(color: OwnTheme.colorPalette['gray'])),
            const SizedBox(height: 20),
            ElevatedButton.icon(
                onPressed: onBook,
                icon: const Icon(Icons.add),
                label: const Text('Book a Trip'))
          ])));
}

class _Error extends StatelessWidget {
  const _Error({required this.error});
  final Object? error;
  @override
  Widget build(BuildContext context) {
    final denied = error is FirebaseException &&
        (error as FirebaseException).code == 'permission-denied';
    return Center(
        child: Padding(
            padding: const EdgeInsets.all(30),
            child: Text(
                denied
                    ? 'Bookings are blocked by Firestore rules. Deploy the included rules.'
                    : 'Could not load bookings.',
                textAlign: TextAlign.center)));
  }
}
