import 'package:booking_app/core/utils/shared_preferences/shared_preferences_helper.dart';
import 'package:booking_app/data/models/basic_model.dart';
import 'package:booking_app/features/bookings/pages/book_trip_screen.dart';
import 'package:booking_app/resources/themes/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ProfileMainScreen extends StatelessWidget {
  const ProfileMainScreen({Key? key}) : super(key: key);

  String get _name {
    final user = FirebaseAuth.instance.currentUser;
    if (user?.displayName?.trim().isNotEmpty == true) {
      return user!.displayName!.trim();
    }
    if (BasicModel.name.trim().isNotEmpty) return BasicModel.name.trim();
    return 'Travel365 Traveller';
  }

  String get _email {
    final email = FirebaseAuth.instance.currentUser?.email;
    if (email?.isNotEmpty == true) return email!;
    if (BasicModel.userToken == 'demo-token') return 'demo@travel365.com';
    return 'Signed-in customer';
  }

  Future<void> _signOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text(
            'You can sign in again at any time to view your bookings.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Sign out')),
        ],
      ),
    );
    if (confirmed != true) return;
    await FirebaseAuth.instance.signOut();
    await addStringToSF('userID', '');
    await addStringToSF('name', '');
    await addStringToSF('userToken', '');
    BasicModel.userID = '';
    BasicModel.name = '';
    BasicModel.userToken = '';
    BasicModel.isLogin = false;
    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/getStarted', (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    return Scaffold(
      backgroundColor: OwnTheme.colorPalette['bg'],
      appBar: AppBar(
        title: Text(
          'Profile',
          style: TextStyle(
            color: OwnTheme.colorPalette['secondary'],
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: OwnTheme.colorPalette['surfaceAlt'],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: OwnTheme.colorPalette['border']!),
            ),
            child: Column(
              children: [
                SvgPicture.asset(
                  'assets/images/travel365_logo.svg',
                  width: 150,
                  semanticsLabel: 'Travel365 logo',
                ),
                const SizedBox(height: 22),
                CircleAvatar(
                  radius: 38,
                  backgroundColor: const Color(0xFFFFF3EC),
                  backgroundImage: firebaseUser?.photoURL?.isNotEmpty == true
                      ? NetworkImage(firebaseUser!.photoURL!)
                      : null,
                  child: firebaseUser?.photoURL?.isNotEmpty == true
                      ? null
                      : Icon(
                          Icons.person_rounded,
                          size: 42,
                          color: OwnTheme.colorPalette['primary'],
                        ),
                ),
                const SizedBox(height: 14),
                Text(
                  _name,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: OwnTheme.colorPalette['secondary'],
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                Text(_email,
                    style: TextStyle(color: OwnTheme.colorPalette['gray'])),
                const SizedBox(height: 12),
                _RoleBadge(userId: firebaseUser?.uid),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Travel account',
            style: TextStyle(
              color: OwnTheme.colorPalette['secondary'],
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          _ProfileTile(
            icon: Icons.add_circle_outline_rounded,
            title: 'Book a Trip',
            subtitle: 'Plan flights, stays, cars or complete packages',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BookTripScreen()),
            ),
          ),
          const _ProfileTile(
            icon: Icons.notifications_none_rounded,
            title: 'Booking notifications',
            subtitle: 'Push alerts are enabled for status updates',
          ),
          _ProfileTile(
            icon: Icons.settings_outlined,
            title: 'Settings',
            subtitle: 'English app preferences',
            onTap: () => Navigator.pushNamed(context, '/setting'),
          ),
          const _ProfileTile(
            icon: Icons.help_outline_rounded,
            title: 'Help & support',
            subtitle: 'Contact Travel365 for assistance',
          ),
          const _ProfileTile(
            icon: Icons.verified_user_outlined,
            title: 'Privacy & security',
            subtitle: 'Your booking information stays protected',
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: () => _signOut(context),
            icon: Icon(Icons.logout_rounded,
                color: OwnTheme.colorPalette['danger']),
            label: Text('Sign out',
                style: TextStyle(color: OwnTheme.colorPalette['danger'])),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              side: BorderSide(color: OwnTheme.colorPalette['danger']!),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Travel365 App Ãƒâ€šÃ‚Â· Botswana',
            textAlign: TextAlign.center,
            style:
                TextStyle(color: OwnTheme.colorPalette['gray'], fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  const _RoleBadge({required this.userId});
  final String? userId;

  @override
  Widget build(BuildContext context) {
    if (userId == null) return const _Badge(label: 'Demo customer');
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .snapshots(),
      builder: (context, snapshot) {
        final role = snapshot.data?.data()?['role']?.toString() ?? 'customer';
        return _Badge(
            label: role == 'staff'
                ? 'Travel365 staff'
                : role == 'owner'
                    ? 'Travel365 owner'
                    : 'Travel365 customer');
      },
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF3EC),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: OwnTheme.colorPalette['primary']!),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: OwnTheme.colorPalette['primary'],
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: OwnTheme.colorPalette['border']!),
        ),
        child: ListTile(
          onTap: onTap,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3EC),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: OwnTheme.colorPalette['primary']),
          ),
          title: Text(
            title,
            style: TextStyle(
              color: OwnTheme.colorPalette['black'],
              fontWeight: FontWeight.w700,
            ),
          ),
          subtitle: Text(subtitle,
              style: TextStyle(color: OwnTheme.colorPalette['gray'])),
          trailing: onTap == null
              ? Icon(Icons.check_circle_outline,
                  color: OwnTheme.colorPalette['secondary'])
              : Icon(Icons.chevron_right_rounded,
                  color: OwnTheme.colorPalette['gray']),
        ),
      );
}
