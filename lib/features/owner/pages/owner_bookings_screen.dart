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
import 'package:booking_app/features/bookings/pages/booking_details_screen.dart';
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
  int _retryKey = 0;

  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Manage Bookings')),
      body: StreamBuilder<List<TravelBooking>>(
        key: ValueKey(_retryKey),
        stream: BookingRepository().watchAllBookings(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return LuxuryErrorState(
              icon: Icons.cloud_off_outlined,
              title: 'Bookings unavailable',
              message:
                  "We couldn't load bookings right now. Please check your connection and try again.",
              onRetry: () => setState(() => _retryKey++),
            );
          }
          if (!snapshot.hasData) {
            return const LuxurySkeletonList();
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
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screen,
                  10,
                  AppSpacing.screen,
                  12,
                ),
                child: TextField(
                  controller: search,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search_rounded),
                    hintText: 'Search customer, destination or reference',
                  ),
                ),
              ),
              SizedBox(
                height: 44,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
                  children: const [
                    'all',
                    'new',
                    'reviewing',
                    'approved',
                    'declined',
                    'completed',
                    'cancelled',
                  ]
                      .map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _StatusChip(
                            status: item,
                            selected: status == item,
                            onSelected: () => setState(() => status = item),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: filtered.isEmpty
                    ? const LuxuryEmptyState(
                        icon: Icons.manage_search_rounded,
                        title: 'No matches',
                        message: 'No bookings match this filter.',
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.screen,
                          8,
                          AppSpacing.screen,
                          28,
                        ),
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (_, index) {
                          return _OwnerBookingCard(booking: filtered[index]);
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

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.status,
    required this.selected,
    required this.onSelected,
  });

  final String status;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final label = status == 'all' ? 'All' : bookingStatusLabel(status);
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
      selectedColor: AppColors.accentSoft,
      backgroundColor: AppColors.surface,
      labelStyle: AppTypography.caption.copyWith(
        color: selected ? AppColors.accent : AppColors.textSecondary,
        fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
      ),
      side: const BorderSide(color: AppColors.border),
      showCheckmark: false,
    );
  }
}

class _OwnerBookingCard extends StatelessWidget {
  const _OwnerBookingCard({required this.booking});
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
                  '${booking.fullName} - ${DateFormat('dd MMM yyyy').format(booking.departureDate)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.caption,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              LuxuryStatusBadge(status: booking.normalizedStatus),
              const SizedBox(height: 4),
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.textMuted),
            ],
          ),
        ],
      ),
    );
  }
}
