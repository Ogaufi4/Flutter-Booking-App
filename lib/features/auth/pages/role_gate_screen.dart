import 'package:booking_app/core/bottom_navigation/pages/main_screen.dart';
import 'package:booking_app/features/auth/role_service.dart';
import 'package:booking_app/features/owner/pages/owner_main_screen.dart';
import 'package:booking_app/resources/themes/theme.dart';
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
              body: Center(
                  child: CircularProgressIndicator(
                      color: OwnTheme.colorPalette['primary'])));
        }
        final role = snapshot.data!;
        if (role == AppRole.owner || role == AppRole.staff)
          return const OwnerMainScreen();
        return const MainScreen();
      },
    );
  }
}
