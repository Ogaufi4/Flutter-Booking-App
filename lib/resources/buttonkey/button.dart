import 'package:booking_app/resources/constants/constants.dart';
import 'package:booking_app/resources/themes/theme.dart';
import 'package:flutter/material.dart';

class ButtonKey extends StatelessWidget {
  final Function()? function;
  final EdgeInsetsGeometry? padding;
  final String? buttonText;
  final Color? textColor, backgroundColor;
  final double radius;
  final bool isLoading;
  final String? language;

  const ButtonKey({
    Key? key,
    this.function,
    this.buttonText,
    this.textColor,
    this.backgroundColor,
    this.padding,
    this.radius = round,
    this.isLoading = false,
    this.language,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: OwnTheme.colorPalette['primary'],
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: function,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: backgroundColor ?? OwnTheme.colorPalette['primary'],
          foregroundColor: textColor ?? OwnTheme.colorPalette['white'],
          padding: padding ?? const EdgeInsets.all(space1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
        ),
        child: Text(
          buttonText ?? '',
          style: OwnTheme.normalBoldTextStyle(lang: language ?? lang).copyWith(
            color: textColor ?? OwnTheme.colorPalette['white'],
          ),
        ),
      ),
    );
  }
}
