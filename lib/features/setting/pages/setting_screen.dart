import 'package:booking_app/core/localization/setup/app_localization.dart';
import 'package:booking_app/core/utils/extensions/layout_extensions.dart';
import 'package:booking_app/core/utils/extensions/theme_extensions.dart';
import 'package:booking_app/core/utils/widgets/custom_app_bar.dart';
import 'package:booking_app/features/setting/widgets/setting_list_tile.dart';
import 'package:booking_app/resources/constants/constants.dart';
import 'package:booking_app/resources/themes/theme.dart';
import 'package:flutter/material.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OwnTheme.colorPalette['bg'],
      body: Column(
        children: [
          CustomAppBar(
            lang: lang,
            leadingWidget: BackIconAppBar(lang: lang),
          ).safeArea(),
          Padding(
            padding:
                const EdgeInsets.only(bottom: bottom, right: side, left: side),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'setting_txt'.tr(context),
                  style: OwnTheme.avBoldTextStyle(lang: lang)
                      .colorChange(color: 'secondary'),
                ),
                SizedBox(height: space2),
                const SettingListTile(
                  text: 'App language',
                  value: 'English',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}