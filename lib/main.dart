import 'package:booking_app/core/localization/cubit/locale_cubit.dart';
import 'package:booking_app/core/notifications/notification_service.dart';
import 'package:booking_app/core/localization/setup/app_localizations_setup.dart';
import 'package:booking_app/core/main_blocs/blocs.dart';
import 'package:booking_app/core/main_blocs/providers.dart';
import 'package:booking_app/core/utils/local/cash_helper.dart';
import 'package:booking_app/core/utils/network/remote/dio.dart';
import 'package:booking_app/core/utils/routes/app_router.dart';
import 'package:booking_app/data/models/basic_model.dart';
import 'package:booking_app/features/screens/splash_screen.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'firebase_options.dart';
import 'resources/themes/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await NotificationService.instance.initialize();
  await BasicModel.init();
  DioHelper2.init();
  await CashHelper.init();
  // debugPrint('main=${BasicModel.isLogin}');

  runApp(MyApp(
    connectivity: Connectivity(),
  ));
}

class MyApp extends StatelessWidget {
  final Connectivity connectivity;

  const MyApp({Key? key, required this.connectivity}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: BlocProviders.providers,
      child: BlocBuilder<LocaleCubit, ChangeLocaleState>(
        builder: (context, state) {
          // print('state.locale==${state.locale}' );
          return Sizer(
            builder: (BuildContext context, Orientation orientation,
                DeviceType deviceType) {
              return MaterialApp(
                navigatorKey: NotificationService.navigatorKey,
                debugShowCheckedModeBanner: false,
                title: 'Travel365 App',
                theme: ownThemeData,
                onGenerateRoute: AppRouter.onGenerateRoute,
                locale: state.locale,
                supportedLocales: AppLocalizationsSetup.supportedLocales,
                localizationsDelegates:
                    AppLocalizationsSetup.localizationsDelegates,
                localeResolutionCallback:
                    AppLocalizationsSetup.localeResolutionCallback,
                home: SplashScreen(),
              );
            },
          );
        },
      ),
    );
  }
}
