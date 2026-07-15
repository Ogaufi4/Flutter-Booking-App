import 'package:booking_app/core/notifications/booking_messages.dart';
import 'package:booking_app/core/notifications/whatsapp_launcher.dart';
import 'package:booking_app/core/theme/app_colors.dart';
import 'package:booking_app/core/theme/app_radius.dart';
import 'package:booking_app/core/theme/app_spacing.dart';
import 'package:booking_app/core/theme/app_typography.dart';
import 'package:booking_app/core/widgets/luxury_button.dart';
import 'package:booking_app/core/widgets/luxury_card.dart';
import 'package:booking_app/core/widgets/luxury_empty_state.dart';
import 'package:booking_app/core/widgets/luxury_error_state.dart';
import 'package:booking_app/core/widgets/luxury_loading_skeleton.dart';
import 'package:booking_app/core/widgets/luxury_status_badge.dart';
import 'package:booking_app/features/auth/role_service.dart';
import 'package:booking_app/features/bookings/booking_presenter.dart';
import 'package:booking_app/features/bookings/data/booking_repository.dart';
import 'package:booking_app/features/bookings/data/travel_booking.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class BookingDetailsArgs {
  const BookingDetailsArgs({required this.bookingId, this.ownerMode});
  final String bookingId;
  final bool? ownerMode;
}

class BookingDetailsScreen extends StatefulWidget {
  const BookingDetailsScreen({
    Key? key,
    required this.bookingId,
    this.ownerMode,
  }) : super(key: key);

  final String bookingId;
  final bool? ownerMode;

  @override
  State<BookingDetailsScreen> createState() => _BookingDetailsScreenState();
}

class _BookingDetailsScreenState extends State<BookingDetailsScreen> {
  final repository = BookingRepository();
  bool busy = false;
  int _retryKey = 0;

  Future<bool> _isOwner() async =>
      widget.ownerMode ?? await const RoleService().canManageBookings;

  Future<void> _transition(TravelBooking booking, String status) async {
    final response = TextEditingController(text: booking.ownerResponse);
    final decline = TextEditingController();
    final accepted = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          status == 'approved'
              ? 'Approve booking?'
              : status == 'declined'
                  ? 'Decline booking?'
                  : 'Update booking?',
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (status == 'declined')
              TextField(
                controller: decline,
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Decline reason (required)',
                ),
              ),
            if (status != 'declined')
              TextField(
                controller: response,
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Message to customer (optional)',
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (status == 'declined' && decline.text.trim().isEmpty) return;
              Navigator.pop(context, true);
            },
            child: Text(
              status == 'approved'
                  ? 'Approve'
                  : status == 'declined'
                      ? 'Decline'
                      : 'Confirm',
            ),
          ),
        ],
      ),
    );
    if (accepted != true) return;
    setState(() => busy = true);
    try {
      await repository.updateBookingStatus(
        bookingId: booking.id,
        status: status,
        ownerResponse: response.text,
        declineReason: decline.text,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Booking marked ${bookingStatusLabel(status).toLowerCase()}.',
            ),
          ),
        );
      }
    } catch (error) {
      _error(error);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> _cancel(TravelBooking booking) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel booking?'),
        content: const Text(
          'Travel365 will be notified. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep booking'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Cancel booking'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    setState(() => busy = true);
    try {
      await repository.cancelBooking(booking.id);
    } catch (error) {
      _error(error);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  void _error(Object error) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('We could not update this booking right now.'),
        ),
      );
    }
  }

  Future<void> _whatsApp(TravelBooking booking, {required bool asOwner}) async {
    final support = await SupportDetails.load();
    final text = asOwner
        ? BookingMessages.ownerToCustomer(booking, support)
        : BookingMessages.customerShare(booking, support);
    final opened = await WhatsAppLauncher.send(
      phone: asOwner ? booking.phone : null,
      text: text,
    );
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open WhatsApp.')),
      );
    }
  }

  Future<void> _launch(Uri uri) async {
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication) &&
        mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open this app.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _isOwner(),
      builder: (context, roleSnapshot) => StreamBuilder<TravelBooking?>(
        key: ValueKey(_retryKey),
        stream: repository.watchBooking(widget.bookingId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Scaffold(
              backgroundColor: AppColors.background,
              appBar: AppBar(title: const Text('My Booking')),
              body: LuxuryErrorState(
                icon: Icons.cloud_off_outlined,
                title: 'Booking unavailable',
                message:
                    "We couldn't load this booking right now. Please check your connection and try again.",
                onRetry: () => setState(() => _retryKey++),
              ),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return Scaffold(
              backgroundColor: AppColors.background,
              appBar: AppBar(title: const Text('My Booking')),
              body: const LuxurySkeletonList(count: 3),
            );
          }
          final booking = snapshot.data;
          if (booking == null) {
            return Scaffold(
              backgroundColor: AppColors.background,
              appBar: AppBar(title: const Text('My Booking')),
              body: const LuxuryEmptyState(
                icon: Icons.event_busy_outlined,
                title: 'Booking not found',
                message:
                    'This booking is no longer available. It may have been cancelled or removed.',
              ),
            );
          }
          final ownerMode = roleSnapshot.data ?? false;
          final format = DateFormat('dd MMM yyyy');
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(title: const Text('My Booking')),
            body: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screen,
                14,
                AppSpacing.screen,
                34,
              ),
              children: [
                _HeroCard(booking: booking),
                const SizedBox(height: 18),
                _Section(
                  title: 'Trip details',
                  children: [
                    _Line('Departure city', booking.departureCity),
                    _Line('Departure', format.format(booking.departureDate)),
                    _Line('Return', format.format(booking.returnDate)),
                    _Line(
                      'Travellers',
                      '${booking.adults} Adult - ${booking.children} Children',
                    ),
                    if (booking.notes.isNotEmpty)
                      _Line('Special request', booking.notes),
                  ],
                ),
                const SizedBox(height: 14),
                _Section(
                  title: 'Contact person',
                  children: [
                    _Line('Name', booking.fullName),
                    _Line('Email', booking.email),
                    _Line('Phone', booking.phone),
                  ],
                ),
                if (booking.ownerResponse.isNotEmpty ||
                    booking.declineReason.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  _Section(
                    title: 'Travel365 response',
                    children: [
                      if (booking.ownerResponse.isNotEmpty)
                        _Line('Message', booking.ownerResponse),
                      if (booking.declineReason.isNotEmpty)
                        _Line('Reason', booking.declineReason),
                    ],
                  ),
                ],
                const SizedBox(height: 20),
                if (ownerMode) ...[
                  Row(
                    children: [
                      Expanded(
                        child: LuxuryButton(
                          label: 'Call',
                          icon: Icons.call_outlined,
                          variant: LuxuryButtonVariant.secondary,
                          onPressed: () =>
                              _launch(Uri(scheme: 'tel', path: booking.phone)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: LuxuryButton(
                          label: 'Email',
                          icon: Icons.email_outlined,
                          variant: LuxuryButtonVariant.secondary,
                          onPressed: () => _launch(
                            Uri(
                              scheme: 'mailto',
                              path: booking.email,
                              queryParameters: {
                                'subject': 'Travel365 booking ${booking.id}',
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  LuxuryButton(
                    label: 'Message on WhatsApp',
                    icon: Icons.chat_outlined,
                    variant: LuxuryButtonVariant.secondary,
                    onPressed: () => _whatsApp(booking, asOwner: true),
                  ),
                  const SizedBox(height: 18),
                  if (busy)
                    const Center(
                      child:
                          CircularProgressIndicator(color: AppColors.primary),
                    )
                  else
                    ..._ownerActions(booking),
                ] else ...[
                  LuxuryButton(
                    label: 'Share on WhatsApp',
                    icon: Icons.share_outlined,
                    variant: LuxuryButtonVariant.secondary,
                    onPressed: () => _whatsApp(booking, asOwner: false),
                  ),
                  if (booking.canCustomerCancel) ...[
                    const SizedBox(height: 10),
                    LuxuryButton(
                      label: 'Cancel booking',
                      icon: Icons.cancel_outlined,
                      variant: LuxuryButtonVariant.destructive,
                      onPressed: busy ? null : () => _cancel(booking),
                    ),
                  ],
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  List<Widget> _ownerActions(TravelBooking booking) {
    switch (booking.normalizedStatus) {
      case 'new':
        return [
          LuxuryButton(
            label: 'Start review',
            onPressed: () => _transition(booking, 'reviewing'),
          ),
        ];
      case 'reviewing':
        return [
          Row(
            children: [
              Expanded(
                child: LuxuryButton(
                  label: 'Approve',
                  icon: Icons.check_rounded,
                  onPressed: () => _transition(booking, 'approved'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: LuxuryButton(
                  label: 'Decline',
                  icon: Icons.close_rounded,
                  variant: LuxuryButtonVariant.secondary,
                  onPressed: () => _transition(booking, 'declined'),
                ),
              ),
            ],
          ),
        ];
      case 'approved':
        return [
          LuxuryButton(
            label: 'Mark completed',
            onPressed: () => _transition(booking, 'completed'),
          ),
        ];
      default:
        return const [];
    }
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.booking});
  final TravelBooking booking;

  @override
  Widget build(BuildContext context) {
    return LuxuryCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LuxuryStatusBadge(status: booking.normalizedStatus),
                const SizedBox(height: 16),
                Text(
                  booking.destination,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.sectionTitle,
                ),
                const SizedBox(height: 6),
                Text(
                  bookingServiceLabel(booking.serviceType),
                  style: AppTypography.caption,
                ),
                const SizedBox(height: 14),
                Text(
                  'Ref ${_reference(booking.id)}',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.medium),
            child: Image.asset(
              _imageFor(booking.destination),
              width: 92,
              height: 92,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }

  String _reference(String id) {
    final count = id.length < 8 ? id.length : 8;
    return id.substring(0, count).toUpperCase();
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

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LuxuryCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.sectionTitle),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line(this.label, this.text);
  final String label;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTypography.caption),
          const SizedBox(height: 4),
          Text(text,
              style: AppTypography.label.copyWith(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

