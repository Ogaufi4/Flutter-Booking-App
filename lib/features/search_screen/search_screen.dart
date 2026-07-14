import 'package:booking_app/features/bookings/pages/book_trip_screen.dart';
import 'package:booking_app/resources/themes/theme.dart';
import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final controller = TextEditingController();
  static const List<List<String>> destinations = [
    ['Cape Town', 'South Africa', 'assets/images/homeImage1.jpeg'],
    ['Paris', 'France', 'assets/images/paris.jpg'],
    ['City hotels', 'Popular stays', 'assets/images/hotel.jpg'],
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Search',
            style: TextStyle(
                color: OwnTheme.colorPalette['secondary'],
                fontWeight: FontWeight.w700)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
        children: [
          TextField(
            controller: controller,
            autofocus: true,
            style: TextStyle(color: OwnTheme.colorPalette['black']),
            decoration: InputDecoration(
              hintText: 'Where are you going?',
              prefixIcon: Icon(Icons.search_rounded,
                  color: OwnTheme.colorPalette['primary']),
              suffixIcon: IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: controller.clear,
              ),
            ),
          ),
          const SizedBox(height: 30),
          Text(
            'Popular searches',
            style: TextStyle(
                color: OwnTheme.colorPalette['secondary'],
                fontSize: 20,
                fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 14),
          ...destinations.map(
            (item) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: OwnTheme.colorPalette['border']!),
              ),
              child: ListTile(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BookTripScreen(initialDestination: item[0]),
                  ),
                ),
                contentPadding: const EdgeInsets.all(10),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.asset(item[2],
                      width: 58, height: 58, fit: BoxFit.cover),
                ),
                title: Text(item[0],
                    style: TextStyle(
                        color: OwnTheme.colorPalette['black'],
                        fontWeight: FontWeight.w700)),
                subtitle: Text(item[1],
                    style: TextStyle(color: OwnTheme.colorPalette['gray'])),
                trailing: Icon(Icons.arrow_forward_ios_rounded,
                    size: 16, color: OwnTheme.colorPalette['primary']),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
