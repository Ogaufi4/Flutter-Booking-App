import 'package:booking_app/core/localization/setup/app_localization.dart';
import 'package:booking_app/core/theme/app_colors.dart';
import 'package:booking_app/core/theme/app_typography.dart';
import 'package:booking_app/core/widgets/luxury_button.dart';
import 'package:booking_app/resources/constants/constants.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class BottomController extends StatelessWidget {
  const BottomController({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LuxuryButton(
          label: 'get_started_btn'.tr(context),
          icon: Icons.luggage_rounded,
          onPressed: () {
            Navigator.pushNamed(context, '/onboarding');
          },
        ),
        const SizedBox(height: space2),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: '${'have_account_txt'.tr(context)} ',
                style: AppTypography.bodyMedium
                    .copyWith(color: AppColors.textSecondary),
              ),
              TextSpan(
                text: 'login_btn'.tr(context),
                style: AppTypography.button.copyWith(color: AppColors.primary),
                recognizer: TapGestureRecognizer()
                  ..onTap = () => Navigator.pushNamed(context, '/login'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
