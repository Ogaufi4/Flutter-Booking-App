import 'package:booking_app/core/bottom_navigation/pages/main_screen.dart';
import 'package:booking_app/core/theme/app_colors.dart';
import 'package:booking_app/core/theme/app_typography.dart';
import 'package:booking_app/features/auth/role_service.dart';
import 'package:booking_app/features/owner/pages/owner_main_screen.dart';
import 'package:flutter/material.dart';

class RoleGateScreen extends StatelessWidget {
  const RoleGateScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AppRole>(
      future: const RoleService().currentRole(forceRefresh: true),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(color: AppColors.primary),
                  const SizedBox(height: 18),
                  Text(
                    'Preparing Travel365',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        final role = snapshot.data!;
        if (role == AppRole.owner || role == AppRole.staff) {
          return const OwnerMainScreen();
        }
        return const MainScreen();
      },
    );
  }
}
