import 'package:booking_app/features/bookings/pages/book_trip_screen.dart';
import 'package:booking_app/features/search_screen/search_screen.dart';
import 'package:booking_app/resources/themes/theme.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  static const recent = [
    Stay('Cape Town City', '2 beds - 4.93', 'assets/images/homeImage1.jpeg'),
    Stay('Paris', '3 beds - 4.88', 'assets/images/paris.jpg'),
    Stay('Namibia', 'Custom trip', 'assets/images/homeImage3.jpg'),
  ];
  static const featured = [
    Stay(
        'Luxury city stay', 'From P1,250 per night', 'assets/images/hotel.jpg'),
    Stay('Weekend in Cape Town', 'From P1,680 per night',
        'assets/images/homeImage2.jpg'),
    Stay('A quiet place in Paris', 'From P1,420 per night',
        'assets/images/paris.jpg'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Expanded(
                        child: Text(
                          'Where will you go next?',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                color: OwnTheme.colorPalette['secondary'],
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                      CircleAvatar(
                        backgroundColor: OwnTheme.colorPalette['surfaceAlt'],
                        child: Icon(Icons.person_outline_rounded,
                            color: OwnTheme.colorPalette['secondary']),
                      ),
                    ]),
                    const SizedBox(height: 20),
                    InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const SearchScreen())),
                      child: Container(
                        height: 58,
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: OwnTheme.colorPalette['border']!),
                          boxShadow: const [
                            BoxShadow(
                                color: Color(0x0F000000),
                                blurRadius: 14,
                                offset: Offset(0, 5))
                          ],
                        ),
                        child: Row(children: [
                          Icon(Icons.search_rounded,
                              color: OwnTheme.colorPalette['primary']),
                          const SizedBox(width: 12),
                          Text('Start your search',
                              style: TextStyle(
                                  color: OwnTheme.colorPalette['black'],
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16)),
                        ]),
                      ),
                    ),
                    const SizedBox(height: 22),
                    Row(children: [
                      Expanded(
                          child: Category(
                              icon: Icons.hotel_outlined,
                              label: 'Stays',
                              onTap: () => openBooking(context,
                                  service: 'accommodation'))),
                      Expanded(
                          child: Category(
                              icon: Icons.flight_takeoff_rounded,
                              label: 'Flights',
                              onTap: () =>
                                  openBooking(context, service: 'flight'))),
                      Expanded(
                          child: Category(
                              icon: Icons.directions_car_outlined,
                              label: 'Cars',
                              onTap: () =>
                                  openBooking(context, service: 'car_rental'))),
                    ]),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => openBooking(context),
                        icon: const Icon(Icons.luggage_outlined),
                        label: const Text('Book any trip'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const StaySection(
                title: 'Recently viewed', stays: recent, compact: true),
            const StaySection(title: 'Popular stays', stays: featured),
            const SliverToBoxAdapter(child: SizedBox(height: 28)),
          ],
        ),
      ),
    );
  }
}

Future<void> openBooking(BuildContext context,
    {String destination = '', String service = 'custom_trip'}) async {
  await Navigator.push<bool>(
    context,
    MaterialPageRoute(
      builder: (_) => BookTripScreen(
          initialDestination: destination, initialService: service),
    ),
  );
}

class Category extends StatelessWidget {
  const Category(
      {Key? key, required this.icon, required this.label, required this.onTap})
      : super(key: key);
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(children: [
          Icon(icon, color: OwnTheme.colorPalette['secondary'], size: 28),
          const SizedBox(height: 7),
          Text(label,
              style: TextStyle(
                  color: OwnTheme.colorPalette['black'],
                  fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }
}

class StaySection extends StatelessWidget {
  const StaySection(
      {Key? key,
      required this.title,
      required this.stays,
      this.compact = false})
      : super(key: key);
  final String title;
  final List<Stay> stays;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.only(top: 30),
      sliver: SliverToBoxAdapter(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(children: [
              Expanded(
                  child: Text(title,
                      style: TextStyle(
                          color: OwnTheme.colorPalette['secondary'],
                          fontSize: 21,
                          fontWeight: FontWeight.w700))),
              Icon(Icons.arrow_forward_rounded,
                  color: OwnTheme.colorPalette['primary']),
            ]),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: compact ? 220 : 292,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              itemCount: stays.length,
              separatorBuilder: (_, __) => const SizedBox(width: 14),
              itemBuilder: (_, index) =>
                  StayCard(stay: stays[index], compact: compact),
            ),
          ),
        ]),
      ),
    );
  }
}

class StayCard extends StatelessWidget {
  const StayCard({Key? key, required this.stay, required this.compact})
      : super(key: key);
  final Stay stay;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final width = compact ? 174.0 : 258.0;
    return InkWell(
      onTap: () => openBooking(context, destination: stay.title),
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: width,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Stack(children: [
            ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(stay.image,
                    width: width,
                    height: compact ? 145 : 208,
                    fit: BoxFit.cover)),
            Positioned(
                right: 10,
                top: 10,
                child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                        color: Colors.white, shape: BoxShape.circle),
                    child: Icon(Icons.favorite_border_rounded,
                        size: 20, color: OwnTheme.colorPalette['secondary']))),
          ]),
          const SizedBox(height: 10),
          Text(stay.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: OwnTheme.colorPalette['black'],
                  fontWeight: FontWeight.w700,
                  fontSize: 15)),
          const SizedBox(height: 4),
          Text(stay.detail,
              style: TextStyle(
                  color: OwnTheme.colorPalette['gray'], fontSize: 13)),
        ]),
      ),
    );
  }
}

class Stay {
  const Stay(this.title, this.detail, this.image);
  final String title;
  final String detail;
  final String image;
}
