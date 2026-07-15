import 'package:booking_app/core/theme/app_colors.dart';
import 'package:booking_app/core/theme/app_spacing.dart';
import 'package:booking_app/core/theme/app_typography.dart';
import 'package:booking_app/core/utils/widgets/TextBoxNormal.dart';
import 'package:booking_app/resources/constants/constants.dart';
import 'package:flutter/material.dart';

class ProfileDetailsListTile extends StatelessWidget {
  String keyy = '';
  String value = '';
  bool editMode = false;
  Function(String val)? onChange;
  TextEditingController tec;

  ProfileDetailsListTile(
      {required this.keyy,
      required this.value,
      required this.editMode,
      this.onChange,
      required this.tec});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.divider),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              keyy,
              style: AppTypography.caption,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            flex: editMode ? 3 : 2,
            child: editMode
                ? CustomTextBoxNormal(
                    lang: lang,
                    tec: tec,
                    onChange: onChange,
                  )
                : Text(
                    value,
                    textAlign: TextAlign.end,
                    style: AppTypography.label,
                  ),
          ),
        ],
      ),
    );
  }
}
