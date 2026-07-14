import 'package:booking_app/features/bookings/data/booking_repository.dart';
import 'package:booking_app/features/bookings/data/travel_booking.dart';
import 'package:booking_app/features/bookings/pages/booking_details_screen.dart';
import 'package:booking_app/resources/themes/theme.dart';
import 'package:flutter/material.dart';

class OwnerDashboardScreen extends StatelessWidget {
  const OwnerDashboardScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Travel365 Dashboard')),
        body: StreamBuilder<List<TravelBooking>>(
          stream: BookingRepository().watchAllBookings(),
          builder: (context, snapshot) {
            if (snapshot.hasError)
              return Center(
                  child: Text('Could not load dashboard: ${snapshot.error}'));
            if (!snapshot.hasData)
              return const Center(child: CircularProgressIndicator());
            final bookings = snapshot.data!;
            int count(String status) =>
                bookings.where((b) => b.normalizedStatus == status).length;
            final active = bookings
                .where((b) => ['new', 'reviewing'].contains(b.normalizedStatus))
                .take(5)
                .toList();
            return ListView(padding: const EdgeInsets.all(20), children: [
              Text('Booking overview',
                  style: TextStyle(
                      color: OwnTheme.colorPalette['secondary'],
                      fontSize: 24,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  childAspectRatio: 1.55,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  children: [
                    _CountCard(
                        label: 'New',
                        value: count('new'),
                        icon: Icons.fiber_new_rounded),
                    _CountCard(
                        label: 'Reviewing',
                        value: count('reviewing'),
                        icon: Icons.manage_search_rounded),
                    _CountCard(
                        label: 'Approved',
                        value: count('approved'),
                        icon: Icons.verified_outlined),
                    _CountCard(
                        label: 'All bookings',
                        value: bookings.length,
                        icon: Icons.receipt_long_outlined),
                  ]),
              const SizedBox(height: 24),
              const Text('Needs attention',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),
              if (active.isEmpty)
                Text('No bookings waiting for review.',
                    style: TextStyle(color: OwnTheme.colorPalette['gray']))
              else
                ...active.map((b) => Card(
                        child: ListTile(
                      leading: CircleAvatar(
                          backgroundColor: const Color(0xFFFFF3EC),
                          child: Icon(Icons.flight_takeoff,
                              color: OwnTheme.colorPalette['primary'])),
                      title: Text(b.destination,
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                      subtitle: Text(
                          '${b.fullName} · ${b.normalizedStatus == 'new' ? 'New' : 'Reviewing'}'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => BookingDetailsScreen(
                                  bookingId: b.id, ownerMode: true))),
                    ))),
            ]);
          },
        ),
      );
}

class _CountCard extends StatelessWidget {
  const _CountCard(
      {required this.label, required this.value, required this.icon});
  final String label;
  final int value;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: OwnTheme.colorPalette['border']!)),
      child: Row(children: [
        Icon(icon, color: OwnTheme.colorPalette['primary'], size: 28),
        const SizedBox(width: 12),
        Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('$value',
                  style: TextStyle(
                      color: OwnTheme.colorPalette['secondary'],
                      fontSize: 24,
                      fontWeight: FontWeight.w800)),
              Text(label,
                  style: TextStyle(color: OwnTheme.colorPalette['gray']))
            ])
      ]));
}
