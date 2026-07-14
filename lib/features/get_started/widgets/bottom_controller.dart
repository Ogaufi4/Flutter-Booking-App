import 'package:booking_app/core/localization/setup/app_localization.dart';
import 'package:booking_app/resources/buttonkey/button.dart';
import 'package:booking_app/resources/constants/constants.dart';
import 'package:booking_app/resources/themes/theme.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class BottomController extends StatelessWidget {
  const BottomController({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ButtonKey(
          buttonText: 'get_started_btn'.tr(context),
          radius: 8,
          padding: const EdgeInsets.symmetric(vertical: 17),
          function: () {
            Navigator.pushNamed(context, '/onboarding');
          },
        ),
        const SizedBox(height: space2),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: '${'have_account_txt'.tr(context)} ',
                style: OwnTheme.smallTextStyle(lang: lang).copyWith(
                  color: OwnTheme.colorPalette['gray'],
                ),
              ),
              TextSpan(
                text: 'login_btn'.tr(context),
                style: OwnTheme.smallBoldTextStyle(lang: lang).copyWith(
                  color: OwnTheme.colorPalette['secondary'],
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () => Navigator.pushNamed(context, '/login'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
