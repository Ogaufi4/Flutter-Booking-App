import 'dart:math' as math;

import 'package:booking_app/core/theme/app_colors.dart';
import 'package:booking_app/core/theme/app_radius.dart';
import 'package:booking_app/core/theme/app_spacing.dart';
import 'package:booking_app/core/theme/app_typography.dart';
import 'package:booking_app/core/widgets/luxury_button.dart';
import 'package:booking_app/core/widgets/luxury_card.dart';
import 'package:booking_app/core/widgets/luxury_icon_button.dart';
import 'package:booking_app/core/widgets/luxury_section_header.dart';
import 'package:booking_app/features/bookings/pages/book_trip_screen.dart';
import 'package:booking_app/features/search_screen/search_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  static const recent = [
    TravelPlace(
      title: 'Cape Town City',
      subtitle: 'South Africa',
      detail: '2 beds - 4.93',
      image: 'assets/images/homeImage1.jpeg',
      service: 'holiday_package',
      about:
          'From iconic Table Mountain to calm beaches and vibrant culture, Cape Town offers an unforgettable escape.',
    ),
    TravelPlace(
      title: 'Paris',
      subtitle: 'France',
      detail: '3 beds - 4.88',
      image: 'assets/images/paris.jpg',
      service: 'holiday_package',
      about:
          'A refined city break shaped by intimate hotels, quiet cafes, galleries, and evening walks along the Seine.',
    ),
    TravelPlace(
      title: 'Namibia',
      subtitle: 'Desert escape',
      detail: 'Custom trip',
      image: 'assets/images/homeImage3.jpg',
      service: 'tour',
      about:
          'A slow, scenic journey through desert landscapes, lodges, open roads, and dramatic sunsets.',
    ),
  ];

  static const stays = [
    TravelPlace(
      title: 'The Silo Hotel',
      subtitle: 'Cape Town, South Africa',
      detail: 'From P 3,450',
      image: 'assets/images/hotel.jpg',
      service: 'accommodation',
      about:
          'Luxury rooms with ocean views, world-class art, fine dining and exceptional service.',
    ),
    TravelPlace(
      title: 'Coastal Suite',
      subtitle: 'Atlantic Seaboard',
      detail: 'From P 2,890',
      image: 'assets/images/homeImage2.jpg',
      service: 'accommodation',
      about:
          'A calm suite for long mornings, private transfers and easy access to Cape Town highlights.',
    ),
    TravelPlace(
      title: 'Paris Maison',
      subtitle: 'Central Paris',
      detail: 'From P 4,150',
      image: 'assets/images/paris.jpg',
      service: 'accommodation',
      about:
          'A boutique stay with warm service, walkable neighborhoods and curated dinner reservations.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final horizontal = MediaQuery.of(context).size.width < 360
        ? AppSpacing.screenSmall
        : AppSpacing.screen;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: EdgeInsets.fromLTRB(horizontal, 18, horizontal, 8),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _BrandRow(),
                    const SizedBox(height: 34),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 300),
                      child: Text(
                        'Where will\nyou go next?',
                        style: AppTypography.displayLarge,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Discover curated journeys,\nexclusive stays and experiences.',
                      style: AppTypography.bodyMedium,
                    ),
                    const SizedBox(height: 26),
                    _SearchBar(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SearchScreen(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    Row(
                      children: [
                        Expanded(
                          child: _CategoryShortcut(
                            icon: Icons.bed_outlined,
                            label: 'Stays',
                            onTap: () => openBooking(
                              context,
                              service: 'accommodation',
                            ),
                          ),
                        ),
                        Expanded(
                          child: _CategoryShortcut(
                            icon: Icons.flight_takeoff_rounded,
                            label: 'Flights',
                            onTap: () => openBooking(
                              context,
                              service: 'flight',
                            ),
                          ),
                        ),
                        Expanded(
                          child: _CategoryShortcut(
                            icon: Icons.directions_car_outlined,
                            label: 'Cars',
                            onTap: () => openBooking(
                              context,
                              service: 'car_rental',
                            ),
                          ),
                        ),
                        Expanded(
                          child: _CategoryShortcut(
                            icon: Icons.card_travel_outlined,
                            label: 'Packages',
                            onTap: () => openBooking(
                              context,
                              service: 'holiday_package',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    LuxuryButton(
                      label: 'Book any trip',
                      icon: Icons.luggage_outlined,
                      onPressed: () => showBookingTypeSheet(context),
                    ),
                  ],
                ),
              ),
            ),
            const _PlaceSection(
              title: 'Recently viewed',
              places: recent,
              compact: true,
            ),
            const _PlaceSection(title: 'Popular stays', places: stays),
            const _CollectionSection(),
            const SliverToBoxAdapter(child: SizedBox(height: 28)),
          ],
        ),
      ),
    );
  }
}

Future<void> openBooking(
  BuildContext context, {
  String destination = '',
  String service = 'custom_trip',
}) async {
  await Navigator.push<bool>(
    context,
    MaterialPageRoute(
      builder: (_) => BookTripScreen(
        initialDestination: destination,
        initialService: service,
      ),
    ),
  );
}

Future<void> showBookingTypeSheet(BuildContext context) {
  final options = [
    const _BookingOption(
      icon: Icons.explore_outlined,
      title: 'Complete trip',
      subtitle: 'Flights, stays, cars and more',
      service: 'custom_trip',
    ),
    const _BookingOption(
      icon: Icons.flight_takeoff_rounded,
      title: 'Flight only',
      subtitle: 'Book a flight',
      service: 'flight',
    ),
    const _BookingOption(
      icon: Icons.bed_outlined,
      title: 'Hotel stay',
      subtitle: 'Find the perfect stay',
      service: 'accommodation',
    ),
    const _BookingOption(
      icon: Icons.directions_car_outlined,
      title: 'Car rental',
      subtitle: 'Rent a car',
      service: 'car_rental',
    ),
    const _BookingOption(
      icon: Icons.card_travel_outlined,
      title: 'Holiday package',
      subtitle: 'Curated experiences',
      service: 'holiday_package',
    ),
  ];

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child:
                        Text('Book a trip', style: AppTypography.sectionTitle),
                  ),
                  LuxuryIconButton(
                    icon: Icons.close_rounded,
                    semanticLabel: 'Close booking options',
                    onPressed: () => Navigator.pop(sheetContext),
                    filled: false,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              ...options.map(
                (option) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _BookingOptionRow(
                    option: option,
                    onTap: () {
                      Navigator.pop(sheetContext);
                      openBooking(context, service: option.service);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _BrandRow extends StatelessWidget {
  const _BrandRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SvgPicture.asset(
          'assets/images/travel365_logo.svg',
          width: 96,
          semanticsLabel: 'Travel365 logo',
        ),
        const Spacer(),
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: Border.all(color: AppColors.border),
          ),
          child: const Icon(Icons.person_outline_rounded,
              color: AppColors.primary),
        ),
      ],
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.medium),
      onTap: onTap,
      child: Container(
        height: 58,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.medium),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            const Icon(Icons.search_rounded,
                size: 21, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Search destinations',
                overflow: TextOverflow.ellipsis,
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const Icon(Icons.tune_rounded, size: 19, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}

class _CategoryShortcut extends StatelessWidget {
  const _CategoryShortcut({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.medium),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            Icon(icon, size: 25, color: AppColors.primary),
            const SizedBox(height: 10),
            Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.caption.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaceSection extends StatelessWidget {
  const _PlaceSection({
    required this.title,
    required this.places,
    this.compact = false,
  });

  final String title;
  final List<TravelPlace> places;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.only(top: 34),
      sliver: SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
              child: LuxurySectionHeader(title: title, actionLabel: 'View all'),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: compact ? 238 : 282,
              child: ListView.separated(
                padding:
                    const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
                scrollDirection: Axis.horizontal,
                itemCount: places.length,
                separatorBuilder: (_, __) => const SizedBox(width: 14),
                itemBuilder: (_, index) => _PlaceCard(
                  place: places[index],
                  compact: compact,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaceCard extends StatelessWidget {
  const _PlaceCard({required this.place, required this.compact});
  final TravelPlace place;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final width = compact ? 142.0 : 214.0;
    final imageHeight = compact ? 160.0 : 196.0;
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.image),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => compact
              ? DestinationShowcaseScreen(place: place)
              : StayShowcaseScreen(place: place),
        ),
      ),
      child: SizedBox(
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.image),
                  child: Image.asset(
                    place.image,
                    width: width,
                    height: imageHeight,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: AppColors.surface.withAlpha(230),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.favorite_border_rounded,
                      size: 18,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              place.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.label,
            ),
            const SizedBox(height: 3),
            Text(
              place.detail,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CollectionSection extends StatelessWidget {
  const _CollectionSection();

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
      sliver: SliverToBoxAdapter(
        child: LuxuryCard(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.accentSoft,
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                ),
                child: const Icon(
                  Icons.auto_awesome_outlined,
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Curated collections', style: AppTypography.label),
                    const SizedBox(height: 4),
                    Text(
                      'Private stays, flights and experiences planned with care.',
                      style: AppTypography.caption,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BookingOption {
  const _BookingOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.service,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String service;
}

class _BookingOptionRow extends StatelessWidget {
  const _BookingOptionRow({required this.option, required this.onTap});
  final _BookingOption option;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return LuxuryCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.accentSoft,
              borderRadius: BorderRadius.circular(AppRadius.medium),
            ),
            child: Icon(option.icon, size: 22, color: AppColors.accent),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(option.title, style: AppTypography.label),
                const SizedBox(height: 4),
                Text(option.subtitle, style: AppTypography.caption),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DestinationShowcaseScreen extends StatelessWidget {
  const DestinationShowcaseScreen({Key? key, required this.place})
      : super(key: key);

  final TravelPlace place;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final heroHeight = math.min(math.max(size.height * 0.55, 360.0), 480.0);

    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(24, 10, 24, 18),
        child: LuxuryButton(
          label: 'Plan this trip',
          onPressed: () => openBooking(
            context,
            destination: place.title,
            service: place.service,
          ),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: SizedBox(
              height: heroHeight,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(place.image, fit: BoxFit.cover),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0x33000000),
                          Color(0x00000000),
                          Color(0xA8000000),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 12,
                    left: 20,
                    child: LuxuryIconButton(
                      icon: Icons.arrow_back_rounded,
                      semanticLabel: 'Back',
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 12,
                    right: 20,
                    child: LuxuryIconButton(
                      icon: Icons.favorite_border_rounded,
                      semanticLabel: 'Save destination',
                      onPressed: () {},
                    ),
                  ),
                  Positioned(
                    left: 24,
                    right: 24,
                    bottom: 34,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          place.title,
                          style: AppTypography.displayLarge.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          place.subtitle,
                          style: AppTypography.bodyMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Icon(Icons.star_rounded,
                                color: AppColors.accent, size: 18),
                            const SizedBox(width: 4),
                            Text(
                              '4.93 (128 reviews)',
                              style: AppTypography.caption.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('About the destination',
                      style: AppTypography.sectionTitle),
                  const SizedBox(height: 12),
                  Text(place.about, style: AppTypography.bodyMedium),
                  const SizedBox(height: 32),
                  LuxurySectionHeader(
                      title: 'Top stays', actionLabel: 'View all'),
                  const SizedBox(height: 12),
                  _TopStayCard(stay: HomeScreen.stays.first),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class StayShowcaseScreen extends StatelessWidget {
  const StayShowcaseScreen({Key? key, required this.place}) : super(key: key);

  final TravelPlace place;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final heroHeight = math.min(math.max(height * 0.48, 330.0), 430.0);

    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(24, 10, 24, 18),
        child: LuxuryButton(
          label: 'View availability',
          onPressed: () => openBooking(
            context,
            destination: place.title,
            service: place.service,
          ),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: SizedBox(
              height: heroHeight,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(place.image, fit: BoxFit.cover),
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 12,
                    left: 20,
                    child: LuxuryIconButton(
                      icon: Icons.arrow_back_rounded,
                      semanticLabel: 'Back',
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 12,
                    right: 20,
                    child: LuxuryIconButton(
                      icon: Icons.favorite_border_rounded,
                      semanticLabel: 'Save stay',
                      onPressed: () {},
                    ),
                  ),
                  Positioned(
                    bottom: 18,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        5,
                        (index) => Container(
                          width: index == 0 ? 18 : 6,
                          height: 6,
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          decoration: BoxDecoration(
                            color:
                                Colors.white.withAlpha(index == 0 ? 242 : 140),
                            borderRadius: BorderRadius.circular(99),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 26, 24, 30),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(place.title, style: AppTypography.displayMedium),
                  const SizedBox(height: 6),
                  Text(place.subtitle, style: AppTypography.bodyMedium),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded,
                          color: AppColors.accent, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        '4.9 (128 reviews)',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const _AmenityRow(),
                  const SizedBox(height: 28),
                  const Divider(color: AppColors.divider),
                  const SizedBox(height: 24),
                  Text('About this stay', style: AppTypography.sectionTitle),
                  const SizedBox(height: 12),
                  Text(place.about, style: AppTypography.bodyMedium),
                  const SizedBox(height: 22),
                  Text('From', style: AppTypography.caption),
                  Text(
                    '${place.detail} / night',
                    style: AppTypography.headingMedium,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AmenityRow extends StatelessWidget {
  const _AmenityRow();

  static const items = [
    _Amenity(Icons.wifi_rounded, 'Free Wi-Fi'),
    _Amenity(Icons.pool_rounded, 'Pool'),
    _Amenity(Icons.local_cafe_outlined, 'Breakfast'),
    _Amenity(Icons.spa_outlined, 'Spa'),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: items
          .map(
            (item) => Expanded(
              child: Column(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Icon(item.icon, size: 21, color: AppColors.primary),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.label,
                    textAlign: TextAlign.center,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

class _TopStayCard extends StatelessWidget {
  const _TopStayCard({required this.stay});
  final TravelPlace stay;

  @override
  Widget build(BuildContext context) {
    return LuxuryCard(
      padding: const EdgeInsets.all(12),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => StayShowcaseScreen(place: stay)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.medium),
            child: Image.asset(
              stay.image,
              width: 100,
              height: 92,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(stay.title, style: AppTypography.label),
                const SizedBox(height: 5),
                Text('Luxury Hotel', style: AppTypography.caption),
                const SizedBox(height: 9),
                Row(
                  children: [
                    const Icon(Icons.star_rounded,
                        size: 16, color: AppColors.accent),
                    const SizedBox(width: 4),
                    Text('4.9', style: AppTypography.caption),
                  ],
                ),
                const SizedBox(height: 8),
                Text(stay.detail, style: AppTypography.label),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Amenity {
  const _Amenity(this.icon, this.label);
  final IconData icon;
  final String label;
}

class TravelPlace {
  const TravelPlace({
    required this.title,
    required this.subtitle,
    required this.detail,
    required this.image,
    required this.service,
    required this.about,
  });

  final String title;
  final String subtitle;
  final String detail;
  final String image;
  final String service;
  final String about;
}
