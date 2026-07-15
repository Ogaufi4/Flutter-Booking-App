import 'package:booking_app/core/theme/app_colors.dart';
import 'package:booking_app/core/theme/app_radius.dart';
import 'package:booking_app/core/theme/app_spacing.dart';
import 'package:booking_app/core/theme/app_typography.dart';
import 'package:booking_app/core/widgets/luxury_card.dart';
import 'package:booking_app/core/widgets/luxury_empty_state.dart';
import 'package:booking_app/core/widgets/luxury_error_state.dart';
import 'package:booking_app/core/widgets/luxury_loading_skeleton.dart';
import 'package:booking_app/core/widgets/luxury_status_badge.dart';
import 'package:booking_app/features/bookings/booking_presenter.dart';
import 'package:booking_app/features/bookings/data/booking_repository.dart';
import 'package:booking_app/features/bookings/data/travel_booking.dart';
import 'package:booking_app/features/bookings/pages/book_trip_screen.dart';
import 'package:booking_app/features/bookings/pages/booking_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TripsScreen extends StatefulWidget {
  const TripsScreen({Key? key}) : super(key: key);

  @override
  State<TripsScreen> createState() => _TripsScreenState();
}

class _TripsScreenState extends State<TripsScreen> {
  final BookingRepository repository = BookingRepository();
  int _retryKey = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Bookings'),
        actions: [
          TextButton.icon(
            onPressed: () => _book(context),
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Book'),
            style: TextButton.styleFrom(foregroundColor: AppColors.accent),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: StreamBuilder<List<TravelBooking>>(
        key: ValueKey(_retryKey),
        stream: repository.watchMyBookings(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _Error(
              onRetry: () => setState(() => _retryKey++),
            );
          }
          if (!snapshot.hasData) {
            return const LuxurySkeletonList();
          }
          final bookings = snapshot.data!;
          if (bookings.isEmpty) {
            return LuxuryEmptyState(
              icon: Icons.luggage_outlined,
              title: 'No journeys yet',
              message: 'Start planning your next escape with Travel365.',
              actionLabel: 'Book your first trip',
              onAction: () => _book(context),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screen,
              12,
              AppSpacing.screen,
              32,
            ),
            itemCount: bookings.length,
            separatorBuilder: (_, __) => const SizedBox(height: 18),
            itemBuilder: (_, i) => _BookingCard(booking: bookings[i]),
          );
        },
      ),
    );
  }

  Future<void> _book(BuildContext context) {
    return Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const BookTripScreen()),
    );
  }
}

class _BookingCard extends StatelessWidget {
  const _BookingCard({required this.booking});
  final TravelBooking booking;

  @override
  Widget build(BuildContext context) {
    final format = DateFormat('dd MMM yyyy');
    final image = _imageFor(booking.destination);
    return LuxuryCard(
      padding: const EdgeInsets.all(14),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BookingDetailsScreen(
            bookingId: booking.id,
            ownerMode: false,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LuxuryStatusBadge(status: booking.normalizedStatus),
                    const SizedBox(height: 14),
                    Text(
                      booking.destination,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.sectionTitle,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      bookingServiceLabel(booking.serviceType),
                      style: AppTypography.caption,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.medium),
                child: Image.asset(
                  image,
                  width: 86,
                  height: 86,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _DetailLine(label: 'Departure city', value: booking.departureCity),
          _DetailLine(
            label: 'Departure',
            value: format.format(booking.departureDate),
          ),
          _DetailLine(
              label: 'Return', value: format.format(booking.returnDate)),
          _DetailLine(
            label: 'Travellers',
            value: '${booking.adults} Adult - ${booking.children} Children',
          ),
          const Divider(height: 26, color: AppColors.divider),
          Row(
            children: [
              Expanded(
                child: Text('Total (est.)', style: AppTypography.caption),
              ),
              Text(
                _estimate(booking),
                style: AppTypography.sectionTitle,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.medium),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Text(
                  'View details',
                  style: AppTypography.label,
                ),
                const Spacer(),
                const Icon(Icons.arrow_forward_rounded,
                    size: 19, color: AppColors.primary),
              ],
            ),
          ),
          if (booking.ownerResponse.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'Travel365: ${booking.ownerResponse}',
              style: AppTypography.caption.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _estimate(TravelBooking booking) {
    final nights = booking.returnDate.difference(booking.departureDate).inDays;
    final safeNights = nights <= 0 ? 1 : nights;
    final travellers = booking.adults + booking.children;
    final base = booking.serviceType == 'flight'
        ? 2800
        : booking.serviceType == 'car_rental'
            ? 650
            : booking.serviceType == 'accommodation'
                ? 1450
                : 2250;
    final total = base * safeNights * (travellers == 0 ? 1 : travellers);
    return 'P ${NumberFormat('#,##0').format(total)}';
  }

  String _imageFor(String destination) {
    final value = destination.toLowerCase();
    if (value.contains('paris')) return 'assets/images/paris.jpg';
    if (value.contains('namibia')) return 'assets/images/homeImage3.jpg';
    if (value.contains('hotel') || value.contains('silo')) {
      return 'assets/images/hotel.jpg';
    }
    return 'assets/images/homeImage1.jpeg';
  }
}

class _DetailLine extends StatelessWidget {
  const _DetailLine({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTypography.caption),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.label.copyWith(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class _Error extends StatelessWidget {
  const _Error({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return LuxuryErrorState(
      icon: Icons.cloud_off_outlined,
      title: 'Trips unavailable',
      message:
          "We couldn't load your trips right now. Please check your connection and try again.",
      onRetry: onRetry,
    );
  }
}
