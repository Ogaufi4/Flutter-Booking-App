import 'package:booking_app/features/get_started/widgets/app_basic_info.dart';
import 'package:booking_app/features/get_started/widgets/bottom_controller.dart';
import 'package:booking_app/resources/themes/theme.dart';
import 'package:flutter/material.dart';

class GetStartedScreen extends StatelessWidget {
  const GetStartedScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OwnTheme.colorPalette['bg'],
      body: const SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(24, 24, 24, 20),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: AppBasicInfo(),
                ),
              ),
              SizedBox(height: 24),
              BottomController(),
            ],
          ),
        ),
      ),
    );
  }
}
