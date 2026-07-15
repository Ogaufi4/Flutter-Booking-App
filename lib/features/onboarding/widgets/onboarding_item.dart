import 'package:booking_app/core/theme/app_colors.dart';
import 'package:booking_app/core/theme/app_radius.dart';
import 'package:booking_app/core/theme/app_typography.dart';
import 'package:booking_app/data/models/on_boarding_model.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class OnboardingItem extends StatelessWidget {
  final OnBoardingModel row;

  const OnboardingItem({Key? key, required this.row}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: double.infinity,
            height: 278,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.card),
              border: Border.all(color: AppColors.border),
            ),
            child: Center(
              child: Lottie.asset(
                row.image,
                width: 230,
                height: 230,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: 34),
          Text(
            row.title,
            textAlign: TextAlign.center,
            style: AppTypography.displayMedium,
          ),
          const SizedBox(height: 12),
          Text(
            row.subtitle,
            textAlign: TextAlign.center,
            style: AppTypography.bodyMedium,
          ),
        ],
      ),
    );
  }
}
