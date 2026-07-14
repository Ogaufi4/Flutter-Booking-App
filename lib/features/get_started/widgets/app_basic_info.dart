import 'package:booking_app/resources/themes/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppBasicInfo extends StatelessWidget {
  const AppBasicInfo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 32),
        SvgPicture.asset(
          'assets/images/travel365_logo.svg',
          width: 230,
          semanticsLabel: 'Travel365 logo',
        ),
        const SizedBox(height: 44),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 28),
          decoration: BoxDecoration(
            color: OwnTheme.colorPalette['surfaceAlt'],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: OwnTheme.colorPalette['border']!),
          ),
          child: Column(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3EC),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: OwnTheme.colorPalette['primary']!,
                    width: 2,
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      Icons.flight_takeoff_rounded,
                      color: OwnTheme.colorPalette['secondary'],
                      size: 34,
                    ),
                    Positioned(
                      right: 8,
                      bottom: 8,
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: OwnTheme.colorPalette['primary'],
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              Text(
                'Your journey, thoughtfully arranged.',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: OwnTheme.colorPalette['secondary'],
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Book flights, stays, car rentals and personalised trips '
                'with Travel365.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: OwnTheme.colorPalette['gray'],
                      height: 1.5,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        const _ServiceSummary(),
      ],
    );
  }
}

class _ServiceSummary extends StatelessWidget {
  const _ServiceSummary();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          child: _ServiceItem(icon: Icons.flight_rounded, label: 'Flights'),
        ),
        SizedBox(width: 8),
        Expanded(
          child: _ServiceItem(icon: Icons.hotel_rounded, label: 'Stays'),
        ),
        SizedBox(width: 8),
        Expanded(
          child: _ServiceItem(
            icon: Icons.directions_car_rounded,
            label: 'Car hire',
          ),
        ),
      ],
    );
  }
}

class _ServiceItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ServiceItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: OwnTheme.colorPalette['border']!),
      ),
      child: Column(
        children: [
          Icon(icon, color: OwnTheme.colorPalette['secondary'], size: 24),
          const SizedBox(height: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: OwnTheme.colorPalette['secondary'],
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
