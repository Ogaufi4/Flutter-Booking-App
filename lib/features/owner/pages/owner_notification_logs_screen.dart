import 'package:booking_app/core/theme/app_colors.dart';
import 'package:booking_app/core/theme/app_radius.dart';
import 'package:booking_app/core/theme/app_spacing.dart';
import 'package:booking_app/core/theme/app_typography.dart';
import 'package:booking_app/core/widgets/luxury_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class OwnerNotificationLogsScreen extends StatelessWidget {
  const OwnerNotificationLogsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Delivery logs')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('notification_logs')
            .orderBy('timestamp', descending: true)
            .limit(50)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }
          if (snapshot.hasError) {
            return const _StateMessage(
              icon: Icons.error_outline_rounded,
              title: 'Logs unavailable',
              message:
                  'Check that this account has owner access and Firestore rules are deployed.',
            );
          }
          final logs = snapshot.data?.docs ?? const [];
          if (logs.isEmpty) {
            return const _StateMessage(
              icon: Icons.mark_email_unread_outlined,
              title: 'No deliveries yet',
              message:
                  'Email, WhatsApp and push attempts appear here after bookings are submitted.',
            );
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screen,
              18,
              AppSpacing.screen,
              32,
            ),
            children: [
              const Text('Notification\nactivity',
                  style: AppTypography.displayMedium),
              const SizedBox(height: 10),
              const Text(
                'Recent backend delivery attempts for receipts and owner alerts.',
                style: AppTypography.bodyMedium,
              ),
              const SizedBox(height: 24),
              for (final log in logs) _LogCard(data: log.data()),
            ],
          );
        },
      ),
    );
  }
}

class _LogCard extends StatelessWidget {
  const _LogCard({required this.data});

  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final status = data['status']?.toString() ?? 'failed';
    final sent = status == 'sent';
    final channel = data['channel']?.toString() ?? 'unknown';
    final provider = data['provider']?.toString() ?? '';
    final recipient = data['recipient']?.toString() ?? '';
    final bookingId = data['bookingId']?.toString() ?? '';
    final error = data['error']?.toString() ?? '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: LuxuryCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: sent
                    ? AppColors.successSoft
                    : AppColors.error.withAlpha(18),
                borderRadius: BorderRadius.circular(AppRadius.medium),
              ),
              child: Icon(
                _channelIcon(channel),
                color: sent ? AppColors.success : AppColors.error,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${_label(channel)} - ${sent ? 'Sent' : 'Failed'}',
                          style: AppTypography.label.copyWith(
                            color:
                                sent ? AppColors.textPrimary : AppColors.error,
                          ),
                        ),
                      ),
                      Text(provider, style: AppTypography.caption),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    recipient.isEmpty ? 'No recipient recorded' : recipient,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (bookingId.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text('Booking $bookingId', style: AppTypography.caption),
                  ],
                  if (!sent && error.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      error,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _channelIcon(String channel) {
    switch (channel) {
      case 'email':
        return Icons.mail_outline_rounded;
      case 'whatsapp':
        return Icons.chat_outlined;
      case 'push':
        return Icons.notifications_none_rounded;
      default:
        return Icons.outbox_outlined;
    }
  }

  String _label(String channel) {
    switch (channel) {
      case 'email':
        return 'Email';
      case 'whatsapp':
        return 'WhatsApp';
      case 'push':
        return 'Push';
      default:
        return 'Delivery';
    }
  }
}

class _StateMessage extends StatelessWidget {
  const _StateMessage({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.screen),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: AppColors.accentSoft,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.accent, size: 32),
            ),
            const SizedBox(height: 18),
            Text(title, style: AppTypography.sectionTitle),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
