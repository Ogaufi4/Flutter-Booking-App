import 'package:booking_app/features/bookings/booking_presenter.dart';
import 'package:booking_app/features/bookings/data/booking_repository.dart';
import 'package:booking_app/features/bookings/data/travel_booking.dart';
import 'package:booking_app/features/bookings/pages/booking_details_screen.dart';
import 'package:booking_app/resources/themes/theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OwnerBookingsScreen extends StatefulWidget {
  const OwnerBookingsScreen({Key? key}) : super(key: key);
  @override
  State<OwnerBookingsScreen> createState() => _OwnerBookingsScreenState();
}

class _OwnerBookingsScreenState extends State<OwnerBookingsScreen> {
  String status = 'all';
  final search = TextEditingController();

  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Bookings')),
      body: StreamBuilder<List<TravelBooking>>(
        stream: BookingRepository().watchAllBookings(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
                child: Text('Could not load bookings: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final query = search.text.trim().toLowerCase();
          final filtered = snapshot.data!.where((booking) {
            final statusMatches =
                status == 'all' || booking.normalizedStatus == status;
            final queryMatches = query.isEmpty ||
                booking.fullName.toLowerCase().contains(query) ||
                booking.destination.toLowerCase().contains(query) ||
                booking.id.toLowerCase().contains(query);
            return statusMatches && queryMatches;
          }).toList();
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
                child: TextField(
                  controller: search,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Search customer, destination or reference',
                  ),
                ),
              ),
              SizedBox(
                height: 42,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: const [
                    'all',
                    'new',
                    'reviewing',
                    'approved',
                    'declined',
                    'completed',
                    'cancelled'
                  ]
                      .map((item) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(item == 'all'
                                  ? 'All'
                                  : bookingStatusLabel(item)),
                              selected: status == item,
                              onSelected: (_) => setState(() => status = item),
                            ),
                          ))
                      .toList(),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: filtered.isEmpty
                    ? const Center(
                        child: Text('No bookings match this filter.'))
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (_, index) {
                          final booking = filtered[index];
                          final color =
                              bookingStatusColor(booking.normalizedStatus);
                          return Card(
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(14),
                              leading: CircleAvatar(
                                backgroundColor: const Color(0xFFFFF3EC),
                                child: Icon(
                                  bookingServiceIcon(booking.serviceType),
                                  color: OwnTheme.colorPalette['primary'],
                                ),
                              ),
                              title: Text(
                                booking.destination,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700),
                              ),
                              subtitle: Text(
                                '${booking.fullName}\n${DateFormat('dd MMM yyyy').format(booking.departureDate)}',
                              ),
                              isThreeLine: true,
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    bookingStatusLabel(
                                        booking.normalizedStatus),
                                    style: TextStyle(
                                      color: color,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const Icon(Icons.chevron_right),
                                ],
                              ),
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => BookingDetailsScreen(
                                    bookingId: booking.id,
                                    ownerMode: true,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
