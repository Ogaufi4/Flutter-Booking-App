import 'package:booking_app/core/localization/setup/app_localization.dart';
import 'package:booking_app/core/widgets/luxury_button.dart';
import 'package:flutter/material.dart';

class OnboardingBottom extends StatelessWidget {
  const OnboardingBottom({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LuxuryButton(
          label: 'login_btn'.tr(context),
          icon: Icons.login_rounded,
          onPressed: () {
            Navigator.pushNamed(context, '/login');
          },
        ),
        const SizedBox(height: 12),
        LuxuryButton(
          label: 'create_account_btn'.tr(context),
          variant: LuxuryButtonVariant.secondary,
          icon: Icons.person_add_alt_1_rounded,
          onPressed: () {
            Navigator.pushNamed(context, '/register');
          },
        ),
      ],
    );
  }
}
