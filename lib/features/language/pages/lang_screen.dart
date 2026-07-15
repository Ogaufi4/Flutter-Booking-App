import 'package:booking_app/core/localization/helpers/language_helper.dart';
import 'package:booking_app/core/localization/setup/app_localization.dart';
import 'package:booking_app/core/theme/app_colors.dart';
import 'package:booking_app/core/theme/app_spacing.dart';
import 'package:booking_app/core/theme/app_typography.dart';
import 'package:booking_app/core/widgets/luxury_button.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LangScreen extends StatelessWidget {
  const LangScreen({Key? key}) : super(key: key);

  void _select(BuildContext context, String code) {
    LanguageHelper().setLang(code);
    Navigator.pushReplacementNamed(context, '/getStarted');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final logoSize = constraints.maxWidth * 0.55;
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Lottie.asset(
                            'assets/images/booking.json',
                            width: logoSize,
                            height: logoSize,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          Text(
                            'booking_app_txt'.tr(context),
                            textAlign: TextAlign.center,
                            style: AppTypography.headingLarge,
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
              const Text(
                'الرجاء اختيار اللغة',
                textAlign: TextAlign.center,
                style: AppTypography.bodyLarge,
              ),
              const SizedBox(height: AppSpacing.xs),
              const Text(
                'Please select language',
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.xl),
              LuxuryButton(
                label: 'عربي',
                onPressed: () => _select(context, 'ar'),
              ),
              const SizedBox(height: AppSpacing.md),
              LuxuryButton(
                label: 'English',
                variant: LuxuryButtonVariant.secondary,
                onPressed: () => _select(context, 'en'),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}
