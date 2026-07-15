import 'package:booking_app/core/localization/setup/app_localization.dart';
import 'package:booking_app/core/theme/app_colors.dart';
import 'package:booking_app/core/theme/app_typography.dart';
import 'package:booking_app/core/widgets/luxury_icon_button.dart';
import 'package:booking_app/data/models/on_boarding_model.dart';
import 'package:booking_app/features/onboarding/widgets/onboarding_bottom.dart';
import 'package:booking_app/features/onboarding/widgets/onboarding_item.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnBoardScreen extends StatefulWidget {
  const OnBoardScreen({Key? key}) : super(key: key);

  @override
  State<OnBoardScreen> createState() => _OnBoardScreenState();
}

class _OnBoardScreenState extends State<OnBoardScreen> {
  final PageController boardController = PageController();

  @override
  void dispose() {
    boardController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final onBoardingLst = OnBoardingModel.fillLst(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 18, 24, 20),
          child: Column(
            children: [
              Row(
                children: [
                  LuxuryIconButton(
                    icon: Icons.arrow_back_rounded,
                    semanticLabel: 'Back',
                    onPressed: () {
                      if (Navigator.canPop(context)) Navigator.pop(context);
                    },
                  ),
                  const Spacer(),
                  TextButton(
                    child: Text(
                      'skip_btn'.tr(context),
                      style: AppTypography.button.copyWith(
                        color: AppColors.accent,
                      ),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, '/login');
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: PageView.builder(
                  physics: const BouncingScrollPhysics(),
                  controller: boardController,
                  itemBuilder: (context, index) =>
                      OnboardingItem(row: onBoardingLst[index]),
                  itemCount: onBoardingLst.length,
                ),
              ),
              SmoothPageIndicator(
                controller: boardController,
                count: onBoardingLst.length,
                effect: const ExpandingDotsEffect(
                  dotColor: AppColors.border,
                  expansionFactor: 3,
                  activeDotColor: AppColors.accent,
                  spacing: 6,
                  dotHeight: 8,
                  dotWidth: 8,
                ),
              ),
              const SizedBox(height: 24),
              const OnboardingBottom(),
            ],
          ),
        ),
      ),
    );
  }
}
