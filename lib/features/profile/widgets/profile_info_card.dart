import 'package:booking_app/core/localization/setup/app_localization.dart';
import 'package:booking_app/core/theme/app_colors.dart';
import 'package:booking_app/core/theme/app_spacing.dart';
import 'package:booking_app/core/theme/app_typography.dart';
import 'package:booking_app/data/models/user_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ProfileInfoCard extends StatelessWidget {
  final UserModel user;
  final Function onTap;

  const ProfileInfoCard({required this.user, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        onTap();
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name!.split(' ').first,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.headingMedium,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'view_edit_profile_txt'.tr(context),
                  style: AppTypography.caption,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          user.image != ''
              ? CircleAvatar(
                  radius: 32,
                  backgroundColor: AppColors.accentSoft,
                  backgroundImage: CachedNetworkImageProvider(
                    '${user.image}',
                  ),
                )
              : Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.accentSoft,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    child: Image.asset(
                      'assets/icons/no_img_icon.webp',
                      width: 48,
                      height: 48,
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
