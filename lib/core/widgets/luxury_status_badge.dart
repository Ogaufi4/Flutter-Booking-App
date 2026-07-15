import 'package:booking_app/core/theme/app_colors.dart';
import 'package:booking_app/core/theme/app_radius.dart';
import 'package:booking_app/core/theme/app_typography.dart';
import 'package:booking_app/features/bookings/booking_presenter.dart';
import 'package:flutter/material.dart';

/// A labeled pill that renders a booking status as text plus color.
///
/// Color is never the only signal: the status word is always shown, so the
/// badge stays readable for screen readers and colorblind customers.
///
/// The label and color mapping are sourced from the shared
/// [bookingStatusLabel] and [bookingStatusColor] helpers; this widget only
/// handles presentation and never contains status logic of its own.
class LuxuryStatusBadge extends StatelessWidget {
  const LuxuryStatusBadge({Key? key, required this.status}) : super(key: key);

  /// Authoritative booking status, e.g. `new`, `reviewing`, `approved`,
  /// `declined`, `completed`, `cancelled`. `submitted` is normalized by the
  /// shared helpers to `new`.
  final String status;

  Color _softBackground() {
    switch (status == 'submitted' ? 'new' : status) {
      case 'approved':
      case 'completed':
        return AppColors.successSoft;
      case 'declined':
      case 'cancelled':
        return AppColors.error.withAlpha(23);
      default:
        return AppColors.accentSoft;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = bookingStatusColor(status);
    final label = bookingStatusLabel(status);
    return Semantics(
      container: true,
      label: 'Booking status: $label',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: _softBackground(),
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: Text(
          label.toUpperCase(),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.caption.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
