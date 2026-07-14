import 'package:booking_app/features/owner/pages/owner_bookings_screen.dart';
import 'package:booking_app/features/owner/pages/owner_dashboard_screen.dart';
import 'package:booking_app/features/owner/pages/owner_support_settings_screen.dart';
import 'package:booking_app/resources/themes/theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class OwnerMainScreen extends StatefulWidget {
  const OwnerMainScreen({Key? key}) : super(key: key);
  @override
  State<OwnerMainScreen> createState() => _OwnerMainScreenState();
}

class _OwnerMainScreenState extends State<OwnerMainScreen> {
  int index = 0;
  final pages = const [
    OwnerDashboardScreen(),
    OwnerBookingsScreen(),
    _OwnerProfile()
  ];
  @override
  Widget build(BuildContext context) => Scaffold(
        body: IndexedStack(index: index, children: pages),
        bottomNavigationBar: NavigationBar(
          selectedIndex: index,
          onDestinationSelected: (value) => setState(() => index = value),
          destinations: const [
            NavigationDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard),
                label: 'Dashboard'),
            NavigationDestination(
                icon: Icon(Icons.receipt_long_outlined),
                selectedIcon: Icon(Icons.receipt_long),
                label: 'Bookings'),
            NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person),
                label: 'Profile'),
          ],
        ),
      );
}

class _OwnerProfile extends StatelessWidget {
  const _OwnerProfile();
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(title: const Text('Owner Profile')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          CircleAvatar(
              radius: 34,
              backgroundColor: OwnTheme.colorPalette['secondary'],
              child: const Icon(Icons.admin_panel_settings_outlined,
                  color: Colors.white, size: 34)),
          const SizedBox(height: 18),
          Text(user?.displayName ?? 'Travel365 Owner',
              style:
                  const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(user?.email ?? '',
              style: TextStyle(color: OwnTheme.colorPalette['gray'])),
          const SizedBox(height: 24),
          const Divider(),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.support_agent_outlined),
            title: const Text('Support contact'),
            subtitle:
                const Text('Phone and email shown to customers in bookings'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => const OwnerSupportSettingsScreen())),
          ),
          const Divider(),
          const Spacer(),
          SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  if (context.mounted)
                    Navigator.pushNamedAndRemoveUntil(
                        context, '/getStarted', (_) => false);
                },
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Sign out'),
              )),
        ]),
      ),
    );
  }
}
