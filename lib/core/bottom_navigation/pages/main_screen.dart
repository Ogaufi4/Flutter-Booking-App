import 'package:booking_app/core/widgets/luxury_bottom_nav.dart';
import 'package:booking_app/core/main_blocs/blocs.dart';
import 'package:booking_app/features/home/pages/home_screen.dart';
import 'package:booking_app/features/profile/pages/profile_main_screen.dart';
import 'package:booking_app/features/trips/trips_screen.dart';
import 'package:booking_app/core/theme/app_colors.dart';
import 'package:booking_app/resources/constants/constants.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: BlocBuilder<NavigationCubit, NavigationState>(
        builder: (context, state) {
          return LuxuryBottomNav(
            currentIndex: state.index,
            onTap: (index) {
              BlocProvider.of<NavigationCubit>(context)
                  .getNavBarItem(index: index);
            },
          );
        },
      ),
      body: BlocBuilder<NavigationCubit, NavigationState>(
          builder: (context, state) {
        if (state.navbarItem == NavbarItem.home) {
          return HomeScreen();
        } else if (state.navbarItem == NavbarItem.settings) {
          return TripsScreen();
        } else if (state.navbarItem == NavbarItem.profile) {
          return ProfileMainScreen();
        }
        return Container();
      }),
    );
  }
}
