import 'package:booking_app/core/theme/app_colors.dart';
import 'package:booking_app/core/theme/app_radius.dart';
import 'package:booking_app/core/theme/app_typography.dart';
import 'package:booking_app/core/widgets/luxury_card.dart';
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
          width: 172,
          semanticsLabel: 'Travel365 logo',
        ),
        const SizedBox(height: 36),
        SizedBox(
          width: double.infinity,
          child: LuxuryCard(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 30),
            child: Column(
              children: [
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    color: AppColors.accentSoft,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.border,
                      width: 1,
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Icon(
                        Icons.flight_takeoff_rounded,
                        color: AppColors.primary,
                        size: 34,
                      ),
                      Positioned(
                        right: 8,
                        bottom: 8,
                        child: Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: AppColors.accent,
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
                const Text(
                  'Your journey, thoughtfully arranged.',
                  style: AppTypography.displayMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Book flights, stays, car rentals and personalised trips '
                  'with Travel365.',
                  style: AppTypography.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
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
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 24),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
