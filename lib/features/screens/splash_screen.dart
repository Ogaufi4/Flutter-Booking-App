import 'package:booking_app/core/localization/setup/app_localization.dart';
import 'package:booking_app/core/theme/app_colors.dart';
import 'package:booking_app/core/theme/app_spacing.dart';
import 'package:booking_app/core/theme/app_typography.dart';
import 'package:booking_app/data/database/facility_helper.dart';
import 'package:booking_app/data/models/basic_model.dart';
import 'package:booking_app/resources/assets_manager/assets_manager.dart';
import 'package:booking_app/resources/constants/constants.dart';
import 'package:lottie/lottie.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    getStarted();
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        if (lang == '')
          Navigator.pushNamedAndRemoveUntil(
              context, '/lang', (Route<dynamic> route) => false);
        else if (FirebaseAuth.instance.currentUser != null ||
            BasicModel.isLogin)
          Navigator.pushNamedAndRemoveUntil(
              context, '/main', (Route<dynamic> route) => false);
        else
          Navigator.pushNamedAndRemoveUntil(
              context, '/getStarted', (Route<dynamic> route) => false);
      }
    });
  }

  getStarted() async {
    FacilityHelper db = FacilityHelper();
    await db.getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final logoSize = constraints.maxWidth * 0.6;
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Lottie.asset(
                    AssetsManager.splashScreenImage,
                    height: logoSize,
                    width: logoSize,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    'booking_app_txt'.tr(context),
                    textAlign: TextAlign.center,
                    style: AppTypography.headingMedium,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
