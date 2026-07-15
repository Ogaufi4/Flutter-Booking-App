import 'package:booking_app/core/theme/app_colors.dart';
import 'package:booking_app/core/theme/app_radius.dart';
import 'package:booking_app/core/theme/app_spacing.dart';
import 'package:booking_app/core/theme/app_typography.dart';
import 'package:booking_app/core/widgets/luxury_card.dart';
import 'package:booking_app/core/widgets/luxury_error_state.dart';
import 'package:booking_app/core/widgets/luxury_loading_skeleton.dart';
import 'package:booking_app/features/bookings/booking_presenter.dart';
import 'package:booking_app/features/bookings/data/booking_repository.dart';
import 'package:booking_app/features/bookings/data/travel_booking.dart';
import 'package:booking_app/features/bookings/pages/booking_details_screen.dart';
import 'package:flutter/material.dart';

class OwnerDashboardScreen extends StatefulWidget {
  const OwnerDashboardScreen({Key? key}) : super(key: key);

  @override
  State<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen> {
  int _retryKey = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Travel365 Dashboard')),
      body: StreamBuilder<List<TravelBooking>>(
        key: ValueKey(_retryKey),
        stream: BookingRepository().watchAllBookings(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return LuxuryErrorState(
              icon: Icons.cloud_off_outlined,
              title: 'Dashboard unavailable',
              message:
                  "We couldn't load booking activity right now. Please check your connection and try again.",
              onRetry: () => setState(() => _retryKey++),
            );
          }
          if (!snapshot.hasData) {
            return const LuxurySkeletonList();
          }
          final bookings = snapshot.data!;
          int count(String status) =>
              bookings.where((b) => b.normalizedStatus == status).length;
          final active = bookings
              .where((b) => ['new', 'reviewing'].contains(b.normalizedStatus))
              .take(5)
              .toList();

          return ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screen,
              18,
              AppSpacing.screen,
              32,
            ),
            children: [
              Text('Booking\noverview', style: AppTypography.displayMedium),
              const SizedBox(height: 12),
              Text(
                'A calm view of new requests and bookings that need owner attention.',
                style: AppTypography.bodyMedium,
              ),
              const SizedBox(height: 26),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                childAspectRatio: 1.45,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  _CountCard(
                    label: 'New',
                    value: count('new'),
                    icon: Icons.fiber_new_rounded,
                  ),
                  _CountCard(
                    label: 'Reviewing',
                    value: count('reviewing'),
                    icon: Icons.manage_search_rounded,
                  ),
                  _CountCard(
                    label: 'Approved',
                    value: count('approved'),
                    icon: Icons.verified_outlined,
                  ),
                  _CountCard(
                    label: 'All bookings',
                    value: bookings.length,
                    icon: Icons.receipt_long_outlined,
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Text('Needs attention', style: AppTypography.sectionTitle),
              const SizedBox(height: 12),
              if (active.isEmpty)
                const LuxuryCard(
                  child: Text('No bookings waiting for review.'),
                )
              else
                ...active.map(
                  (booking) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _AttentionCard(booking: booking),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _CountCard extends StatelessWidget {
  const _CountCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final int value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return LuxuryCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.accentSoft,
              borderRadius: BorderRadius.circular(AppRadius.medium),
            ),
            child: Icon(icon, color: AppColors.accent, size: 22),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$value', style: AppTypography.headingLarge),
              const SizedBox(height: 3),
              Text(label, style: AppTypography.caption),
            ],
          ),
        ],
      ),
    );
  }
}

class _AttentionCard extends StatelessWidget {
  const _AttentionCard({required this.booking});
  final TravelBooking booking;

  @override
  Widget build(BuildContext context) {
    return LuxuryCard(
      padding: const EdgeInsets.all(14),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BookingDetailsScreen(
            bookingId: booking.id,
            ownerMode: true,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.accentSoft,
              borderRadius: BorderRadius.circular(AppRadius.medium),
            ),
            child: Icon(
              bookingServiceIcon(booking.serviceType),
              color: AppColors.accent,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking.destination,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.label,
                ),
                const SizedBox(height: 4),
                Text(
                  '${booking.fullName} - ${bookingStatusLabel(booking.normalizedStatus)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.caption,
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
        ],
      ),
    );
  }
}
