import 'package:booking_app/resources/constants/constants.dart';
import 'package:booking_app/resources/themes/theme.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class ProfileListTile extends StatelessWidget {
  final String? text;
  final dynamic icon;
  final Color? iconColor;
  final Function? onTap;

  const ProfileListTile({this.text, this.icon, this.iconColor, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: OwnTheme.colorPalette['surface'],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: OwnTheme.colorPalette['border']!),
      ),
      child: ListTile(
        onTap: onTap == null ? null : () => onTap!(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        title: Text(
          text ?? '',
          style: OwnTheme.normalTextStyle(lang: lang).copyWith(
            color: OwnTheme.colorPalette['black'],
          ),
        ),
        leading: icon is IconData
            ? Icon(
                icon,
                color: iconColor ?? OwnTheme.colorPalette['secondary'],
                size: 19.sp,
              )
            : Image.asset(
                icon.toString(),
                width: 19.sp,
                height: 19.sp,
                color: iconColor ?? OwnTheme.colorPalette['secondary'],
              ),
        trailing: Icon(
          Icons.chevron_right_rounded,
          color: OwnTheme.colorPalette['gray'],
        ),
      ),
    );
  }
}
